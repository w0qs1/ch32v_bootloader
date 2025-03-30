.section .text.bootloader, "ax"
.global fw_upgrade

.equ    NACK,               0x00
.equ    ACK,                0x01
.equ    PING,               0x02
.equ    CMD_FLASH_UNLOCK,   0x03
.equ    CMD_FLASH_LOCK,     0x04
.equ    CMD_FLASH_PR,       0x05
.equ    CMD_FLASH_PE,       0x06
.equ    CMD_FLASH_PW,       0x07
.equ    CMD_SET_SINI,       0x08
.equ    CMD_SET_MAIN,       0x09
.equ    CMD_FLASH_CRC,      0x0A
.equ    EXIT,               0xFF

fw_upgrade:
    addi sp, sp, -4
    sw ra, 0(sp)
    jal ra, gpio_init
    jal ra, gpio_check

    beq a0, zero, button_pressed

    // If button is not pressed, return
return_to_caller_no_msg:
    lw ra, 0(sp)
    addi sp, sp, 4
    jalr x0, 0(ra)

return_to_caller:
    la a0, fw_msg_2
    jal ra, print_uart
    beq zero, zero, return_to_caller_no_msg

button_pressed:
    la a0, fw_msg_1
    jal ra, print_uart
    jal ra, uart_getc
    beq a0, zero, return_to_caller

ping:
    li a0, ACK
    jal ra, uart_putc
    beq x0, x0, button_pressed

cmd_flash_unlock:
    jal ra, flash_cmd_unlock
    li a0, ACK
    jal ra, uart_putc
    beq x0, x0, button_pressed

cmd_flash_lock:
    jal ra, flash_cmd_lock
    li a0, ACK
    jal ra, uart_putc
    beq x0, x0, button_pressed

cmd_flash_pr:
    jal ra, uart_getc
    // Fill here
    li a0, ACK
    jal ra, uart_putc
    beq x0, x0, button_pressed

cmd_flash_pe:
    jal ra, uart_getc
    // Fill here
    li a0, ACK
    jal ra, uart_putc
    beq x0, x0, button_pressed

cmd_flash_pw:
    jal ra, uart_getc
    // Fill here
    li a0, ACK
    jal ra, uart_putc
    beq x0, x0, button_pressed

cmd_set_sini:
    jal ra, uart_getc
    // Fill here
    li a0, ACK
    jal ra, uart_putc
    beq x0, x0, button_pressed

cmd_set_main:
    jal ra, uart_getc
    // Fill here
    li a0, ACK
    jal ra, uart_putc
    beq x0, x0, button_pressed

cmd_flash_crc:
    jal ra, uart_getc
    // Fill here
    li a0, ACK
    jal ra, uart_putc
    beq x0, x0, button_pressed

exit:
    // return
    beq x0, x0, return_to_caller

.section .rodata.bootloader, "a", @progbits
.align 4
fw_msg_1: .asciz "Entering Firmware Upgrade Mode..\n"
.align 4
fw_msg_2: .asciz "Exiting Firmware Upgrade Mode..\n"