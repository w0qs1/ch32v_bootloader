.section .custom_boot, "ax"  // Executable code section
.global custom_boot

custom_boot:
    // Initialize UART
    // Set Baud rate to 115200 8N1 config
    // Transmit "POST Starting.."
    // Compute and Check CRC32 of Application
    // Print the status of Peripherals Tested
    // Print "POST Success.." if fimrware is not corrupted
    // Print "CRC failed" if firmware is corrupted

    // Setup Stack (for proper return)
    li sp, 0x20000300
    addi sp, sp, -4
    sw ra, 0(sp)    // Save return address

    jal ra, uart_init

    la a0, msg1
    jal ra, print_uart

    // [GPIOD_CFGLR] in t0
    lui t0, 0x40011
    addi t0, t0, 0x400

    // set bit 0 and 1 (mode to output at 30MHz) and clear bit 2 and 3 (output push pull configuration)
    lw t1, 0(t0)
    ori t1, t1, 0x003
    addi t2, zero, -1
    addi t2, t2, -12
    and t1, t1, t2
    sw t1, 0(t0)

    // [GPIOD_BSRR] in t0
    addi t0, t0, 0x010

    // // Set bit (PD0 = 1) by setting 1 to bit pos 0
    // add t1, t1, zero
    // ori t1, t1, 1
    // sw t1, 0(t0)

    // Clear bit (PD0 = 0) by setting 1 to bit pos 16
    addi t1, zero, 1
    slli t1, t1, 16
    or t1, t1, t2
    sub t1, zero, t1
    sw t1, 0(t0)

    // Jump to the standard startup code
    lw ra, 0(sp)
    addi sp, sp, 4
    jalr x0, 0(ra)  // Ensure execution flows into the standard startup

print_uart:
    addi sp, sp, -4
    sw ra, 0(sp)         # Save return address
    # a0 contains the address of the string
    mv t0, a0         # Load base address into t0
1:
    lw t1, 0(t0)      # Load 4 bytes (little-endian)

    # Extract and send each byte in sequence
    andi t2, t1, 0xFF        # Byte 0
    beqz t2, done
    jal ra, uart_putc        # Call uart_putc (assuming it preserves ra)

    srli t1, t1, 8
    andi t2, t1, 0xFF        # Byte 1
    beqz t2, done
    jal ra, uart_putc

    srli t1, t1, 8
    andi t2, t1, 0xFF        # Byte 2
    beqz t2, done
    jal ra, uart_putc

    srli t1, t1, 8
    andi t2, t1, 0xFF        # Byte 3
    beqz t2, done
    jal ra, uart_putc

    addi t0, t0, 4    # Move to next word
    j 1b              # Loop

done:
    lw ra, 0(sp)
    addi sp, sp, 4
    jalr x0, 0(ra)    # Return from subroutine

uart_putc:
    addi sp, sp, -4
    sw ra, 0(sp)         # Save return address

    li s0, 0x40013800    # Load UART status register address
2:
    lb s1, 0(s0)         # Check UART status register
    andi s1, s1, (1 << 6)  # Check if TX buffer is empty
    beqz s1, 2b         # Wait if not empty

    sb t2, 4(s0)         # Write character to UART TX

    // Delay (This is VERY, VERY Important. Otherwise, the last 2 characters are skipped; idk why)
    li a2, 0x000000C0
3:
    addi a2, a2, -1
    bne a2, zero, 3b

    lw ra, 0(sp)
    addi sp, sp, 4
    jalr x0, 0(ra)      # Return from uart_putc


uart_init:
    addi sp, sp, -4
    sw ra, 0(sp)         # Save return address
    // Initialize UART
    // [RCC_APB2_ENR] in t0
    li t0, 0x40021018

    // Enable clock for UART1
    lw t1, 0(t0)
    addi t2, zero, 1
    slli t2, t2, 14
    or t1, t1, t2
    sw t1, 0(t0)

    // Address of USART_BRR
    li t0, 0x40013808

    // Set M = 4, D = 5
    addi t1, zero, 0x045
    sw t1, 0(t0)

    // Set Transmit Enable, USART Enable in USART_CTRL1
    addi t0, t0, 4
    addi t1, zero, 1
    slli t1, t1, 13
    addi t1, t1, 8
    sw t1, 0(t0)

    // Set GPIO D5 as output for TX
    // [RCC_APB2_ENR] in t0
    lui t0, 0x40021
    addi t0, t0, 0x018

    // set bit 5 (enable clock for gpio d)
    lw t1, 0(t0)
    ori t1, t1, 32
    sw t1, 0(t0)

    // [GPIOD_CFGLR] in t0
    lui t0, 0x40011
    addi t0, t0, 0x400

    // set bit 20, 21 and 23 (mode to output at 30MHz) and clear bit 22 (multiplexed output push pull configuration)
    lw t1, 0(t0)              // Load current value
    li t2, 0xF << 20          // Mask for bits 20-23 (0xF00000)
    not t2, t2                // Invert mask: bits 20-23 become 0, others 1
    and t1, t1, t2            // Clear bits 20-23
    li t2, 0xB                // 0xB = 1011; bits: 23,21,20 set; 22 clear
    slli t2, t2, 20           // Move into position
    or t1, t1, t2             // Set bits 20-23 to desired value
    sw t1, 0(t0)

    lw ra, 0(sp)
    addi sp, sp, 4
    jalr x0, 0(ra)

.section .rodata, "a", @progbits
msg1: .asciz "POST Starting..\n"
// msg1: .asciz "Post Starting..\n"
msg2: .asciz "POST Success..\n"