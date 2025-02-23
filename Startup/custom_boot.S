.section .custom_boot, "ax"  // Executable code section
.global custom_boot

.data
msg1: .word 

custom_boot:
    // Initialize UART
    // Set Baud rate to 115200 8N1 config
    // Transmit "POST Starting.."
    // Print the status of Peripherals Tested
    // Compute and Check CRC32 of Application
    // Print "POST Success.." if fimrware is not corrupted
    // Print "CRC failed" if firmware is corrupted

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

    // Set Transmit Enable in USART_CTRL1
    addi t0, t0, 4
    addi t1, zero, 8
    sw t1, 0(t0)



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

    // set bit 0 and 1 (mode to output at 30MHz) and clear bit 2 and 3 (output push pull configuration)
    lw t1, 0(t0)
    ori t1, t1, 0x003
    addi t2, zero, -1
    addi t2, t2, -12
    and t1, t1, t2
    sw t1, 0(t0)

    // [GPIOD_BSRR] in t0
    addi t0, t0, 0x010

    // Set bit (PD0 = 1) by setting 1 to bit pos 0
    add t1, t1, zero
    ori t1, t1, 1
    sw t1, 0(t0)

    // Clear bit (PD0 = 0) by setting 1 to bit pos 16
    addi t1, zero, 1
    slli t1, t1, 16
    or t1, t1, t2
    sub t1, zero, t1
    sw t1, 0(t0)

    // Jump to the standard startup code
    jalr x0, 0(ra)  // Ensure execution flows into the standard startup
