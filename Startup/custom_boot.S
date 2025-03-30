#include "boot_config.S"

.ifdef FW_UPGDE
#include "fw_upgrade.S"
.endif

.section .text.bootloader, "ax"  // Executable code section
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

.if FW_UPGDE
    jal ra, fw_upgrade
.endif

post_start:
    // Check for GPIO here
    la a0, msg1     // Print "POST Starting.."
    jal ra, print_uart

    .if FW_CHECK
    la a0, msg2     // Firmware Check Enabled
    jal ra, print_uart

    la a0, FW_BASE
    la a1, FW_LEN
    lw a1, 0(a1)
    li t1, 0x3F
    not t1, t1
    and a2, a1, t1
    bge a2, a1, next
    addi a1, a2, 64
next:
    // Compute CRC32
    jal ra, compute_crc

    li t0, CRC_LOC
    lw t1, 0(t0)
    beq a0, t1, fw_correct1
    .else
    la a0, msg3     // No firmware Check Enabled
    jal ra, print_uart
    jal x0, fw_correct
    .endif

.if FW_CHECK
fw_wrong:
    la a0, msg4
    jal ra, print_uart

inf_loop:
    jal x0, inf_loop
.endif

// Redundant check to ensure that the beq instruction itself is not corrupted
fw_correct1:
    li t0, CRC_LOC
    lw t0, 0(t0)
    beq a0, t0, fw_correct

fw_correct:
    .if FW_CHECK
    la a0, msg5
    jal ra, print_uart
    .endif
    // Jump to the standard startup code
    lw ra, 0(sp)
    addi sp, sp, 4
    jalr x0, 0(ra)  // Ensure execution flows into the standard startup

.global print_uart
print_uart:
    addi sp, sp, -4
    sw ra, 0(sp)         # Save return address
    # a0 contains the address of the string
    mv t0, a0         # Load base address into t0
1:
    lw t1, 0(t0)      # Load 4 bytes (little-endian)

    # Extract and send each byte in sequence
    andi a0, t1, 0xFF        # Byte 0
    beqz a0, done
    jal ra, uart_putc        # Call uart_putc (assuming it preserves ra)

    srli t1, t1, 8
    andi a0, t1, 0xFF        # Byte 1
    beqz a0, done
    jal ra, uart_putc

    srli t1, t1, 8
    andi a0, t1, 0xFF        # Byte 2
    beqz a0, done
    jal ra, uart_putc

    srli t1, t1, 8
    andi a0, t1, 0xFF        # Byte 3
    beqz a0, done
    jal ra, uart_putc

    addi t0, t0, 4    # Move to next word
    j 1b              # Loop

done:
    lw ra, 0(sp)
    addi sp, sp, 4
    jalr x0, 0(ra)    # Return from subroutine

.global uart_putc
uart_putc:
    addi sp, sp, -4
    sw ra, 0(sp)         # Save return address

    li s0, 0x40013800    # Load UART status register address
2:
    lb s1, 0(s0)         # Check UART status register
    andi s1, s1, (1 << 6)  # Check if TX buffer is empty
    beqz s1, 2b         # Wait if not empty

    sb a0, 4(s0)         # Write character to UART TX

    // Delay (This is VERY, VERY Important. Otherwise, the last 2 characters are skipped; idk why)
    li a2, 0x000000C0
3:
    addi a2, a2, -1
    bne a2, zero, 3b

    lw ra, 0(sp)
    addi sp, sp, 4
    jalr x0, 0(ra)      # Return from uart_putc


.if FW_UPGDE
.global uart_getc
// Blocking UART read function
uart_getc:
    addi sp, sp, -4
    sw ra, 0(sp)

    // USART_STATR
    li t0, 0x40013800
1:
    // Check for RXNE bit
    addi t2, zero, 0x010
    lw t1, 0(t0)
    and t2, t1, t2
    beq t2, zero, 1b

    // Clear RXNE bit
    li s0, 0xFFFFFFEF
    and t1, t1, s0
    sw t1, 0(t0)

    // USART_DATAR
    li t0, 0x40013804
    lbu a0, 0(t0)

    lw ra, 0(sp)
    addi sp, sp, 4
    jalr x0, 0(ra)
.endif

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

    // Set M and F
    li t1, ((UART_B_M << 4) | UART_B_F)
    // addi t1, zero, ((UART_B_M << 4) | UART_B_F)
    sw t1, 0(t0)

    // Set Transmit Enable, Receive Enable (only if FW_UPGDE), USART Enable in USART_CTRL1
    addi t0, t0, 4
    addi t1, zero, 1
    slli t1, t1, 13

    .if FW_UPGDE
    addi t1, t1, 12
    .else
    addi t1, t1, 8
    .endif

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

.if FW_UPGDE
.global gpio_init
gpio_init:
    addi sp, sp, -4
    sw ra, 0(sp)

    // [RCC_APB2_ENR] in t0
    lui t0, 0x40021
    addi t0, t0, 0x018

    // set bit 5 (enable clock for gpio d)
    lw t1, 0(t0)
    ori t1, t1, 32
    sw t1, 0(t0)
    
    // Set Input Mode for PD0 in GPIOD_CFGLR
    li t0, 0x40011400
    lw t1, 0(t0)
    li t2, 0xFFFFFFF0
    and t1, t1, t2
    ori t1, t1, 0x008
    sw t1, 0(t0)

    // Set Pull up Mode in GPIOD_ODR
    lw t1, 12(t0)
    ori t1, t1, 0x001
    sw t1, 12(t0)

    lw ra, 0(sp)
    addi sp, sp, 4
    jalr x0, 0(ra)


.global gpio_check
gpio_check:
    // Get GPIOD_IDR
    li t0, 0x40011408
    lw t1, 0(t0)

    // Mask Bit 0
    addi t2, zero, 0x001
    // Return Value of Bit 0 (PD0)
    and a0, t2, t1
    
    jalr x0, 0(ra)

.global read_flash
read_flash:
    addi sp, sp, -4
    sw ra, 0(sp)

1:
    beq a0, a2, 2f
    lw s1, 0(a0)
    sw s1, 0(a1)
    addi a0, a0, 4
    addi a1, a1, 4
    beq x0, x0, 1b

2:
    lw ra, 0(sp)
    addi sp, sp, 4
    jalr x0, 0(ra)
.endif

.if FW_CHECK
.global compute_crc
compute_crc:
    addi sp, sp, -4
    sw ra, 0(sp)

    lui a3, 0xedb88
    li a4, 0
    li a5, -1
    addi a3, a3, 0x320
1:
    bne a4, a1, 2f
    not a0, a5
    lw ra, 0(sp)
    addi sp, sp, 4
    jalr x0, 0(ra)
2:
    add a2, a0, a4
    lbu a2, 0(a2)
    xor a5, a5, a2
    li a2, 8
3:
    srli t1, a5, 0x1
    andi a5, a5, 1
    neg a5, a5
    and a5, a5, a3
    addi a2, a2, -1
    xor a5, t1, a5
    bnez a2, 3b
    addi a4, a4, 1
    j 1b
.endif

.section .rodata.bootloader, "a", @progbits
.align 4
msg1: .asciz "POST Starting..\n"
.if FW_CHECK
.align 4
msg2: .asciz "Running Firmware Check..\n"
.endif
.align 4
msg3: .asciz "No Firmware Check enabled..\n"

.if FW_CHECK
.align 4
msg4: .asciz "Firmware corrupted!\n"
.align 4
msg5: .asciz "Firmware OK..\n"
.endif

// .section .rodata.bootcfg, "a", @progbits
// .align 4
// .if FW_CHECK
// FW_LEN: .word _etext
// .endif