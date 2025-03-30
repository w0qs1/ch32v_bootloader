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

loop:
    jal ra, uart_getc

    // Switch case statement here
    li t1, PING
    beq a0, t1, ping
    
    li t1, CMD_FLASH_UNLOCK
    beq a0, t1, cmd_flash_unlock
    
    li t1, CMD_FLASH_LOCK
    beq a0, t1, cmd_flash_lock
    
    li t1, CMD_FLASH_PR
    beq a0, t1, cmd_flash_pr
    
    li t1, CMD_FLASH_PE
    beq a0, t1, cmd_flash_pe
    
    li t1, CMD_FLASH_PW
    beq a0, t1, cmd_flash_pe
    
    li t1, CMD_SET_SINI
    beq a0, t1, cmd_set_sini
    
    li t1, CMD_SET_MAIN
    beq a0, t1, cmd_set_main
    
    li t1, CMD_FLASH_CRC
    beq a0, t1, cmd_flash_crc

    beq a0, zero, return_to_caller

ping:
    li a0, ACK
    jal ra, uart_putc
    beq x0, x0, loop

cmd_flash_unlock:
    jal ra, flash_cmd_unlock
    li a0, ACK
    jal ra, uart_putc
    beq x0, x0, loop

cmd_flash_lock:
    jal ra, flash_cmd_lock
    li a0, ACK
    jal ra, uart_putc
    beq x0, x0, loop

cmd_flash_pr:
    // Get page address
    jal ra, uart_getc
    mv a3, a0
    
    li t0, 0x030
    li t1, 0x100
    
    blt a0, t0, fail
    bge a0, t1, fail

    li a0, ACK
    jal ra, uart_putc

    // compute flash starting address
    li t0, 0x08000000
    slli a3, a3, 6
    add a0, t0, a3
    la a1, page_in_mem
    addi a2, a0, 64

    jal ra, read_flash

print_mem_to_uart:
    la a1, page_in_mem
    li t0, 0x010
1:    
    lw a2, 0(a1)
    andi a0, a2, 0x0FF
    jal ra, uart_putc

    lw a2, 0(a1)
    srli a0, a2, 8
    jal ra, uart_putc

    lw a2, 0(a1)
    srli a0, a2, 16
    jal ra, uart_putc

    lw a2, 0(a1)
    srli a0, a2, 24
    jal ra, uart_putc

    addi a1, a1, 4
    addi t0, t0, -1
    bne t0, zero, 1b

    mv a0, a3
    li a1, 64
    jal ra, compute_crc

    mv a3, a0
    andi a0, a3, 0x0FF
    jal ra, uart_putc

    srli a0, a3, 8
    jal ra, uart_putc

    srli a0, a3, 16
    jal ra, uart_putc

    srli a0, a3, 24
    jal ra, uart_putc

    beq x0, x0, loop

fail:
    li a0, NACK
    jal ra, uart_putc
    beq x0, x0, loop

cmd_flash_pe:
    jal ra, uart_getc
    // Fill here
    beq x0, x0, loop

cmd_flash_pw:
    jal ra, uart_getc
    // Fill here
    beq x0, x0, loop

cmd_set_sini:
    jal ra, uart_getc
    // Fill here
    beq x0, x0, loop

cmd_set_main:
    jal ra, uart_getc
    // Fill here
    beq x0, x0, loop

cmd_flash_crc:
    jal ra, uart_getc
    // Fill here
    beq x0, x0, loop

.section .rodata.bootloader, "a", @progbits
.align 4
fw_msg_1: .asciz "Entering Firmware Upgrade Mode..\n"
.align 4
fw_msg_2: .asciz "Exiting Firmware Upgrade Mode..\n"

.section .data.bootloader, "a"
.align 4
page_in_mem: .space 64