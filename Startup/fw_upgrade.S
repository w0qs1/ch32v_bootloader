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
.equ    ENTER_PIN,          0xFE
.equ    EXIT,               0xFF

// Functions from ch32v00x_flash.c
.extern FLASH_ErasePage_Fast
.extern FLASH_Unlock_Fast
.extern FLASH_Lock_Fast

fw_upgrade:
    // save ra in stack
    addi sp, sp, -4
    sw ra, 0(sp)

    // initialize and check for button press
    jal ra, gpio_init
    jal ra, gpio_check

    beq a0, zero, loop0

    // If button is not pressed, return without any msg
    // also restores ra from stack
return_to_caller_no_msg:
    lw ra, 0(sp)
    addi sp, sp, 4
    jalr x0, 0(ra)

// return with a message
return_to_caller:
    la a0, fw_msg_2
    jal ra, print_uart
    beq zero, zero, return_to_caller_no_msg

// Additional Starts here
loop0:
    li a0, ENTER_PIN
    jal ra, uart_putc

    la a0, fw_msg_3
    jal ra, print_uart

    li s1, 0x00000000

    // Get 4B pin in little endian format
    jal ra, uart_getc
    mv s1, a0

    jal ra, uart_getc
    slli s1, s1, 8
    or s1, s1, a0

    jal ra, uart_getc
    slli s1, s1, 8
    or s1, s1, a0

    jal ra, uart_getc
    slli s1, s1, 8
    or s1, s1, a0

    // Get 64 bits of CHIP_UID
    li t0, 0x1FFFF7E8
    lw t1, 0(t0)
    lw t2, 4(t0)

    // Simple XOR operation is performed here, change it to something else to increase security
    xor t1, t1, t2

    // 0x00000000 pin exits the bootloader
    beq s1, zero, return_to_caller

    // a correct pin enables the bootloader commands
    bne s1, t1, loop0

    li a0, ACK
    jal ra, uart_putc
// Additional Ends here

// prints "Entering Firmware Upgrade Mode.."
button_pressed:
    la a0, fw_msg_1
    jal ra, print_uart

// while(1) loop for the handler
loop:
    // get a command byte
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
    beq a0, t1, cmd_flash_pw
    
    li t1, CMD_SET_SINI
    beq a0, t1, cmd_set_sini
    
    li t1, CMD_SET_MAIN
    beq a0, t1, cmd_set_main
    
    li t1, CMD_FLASH_CRC
    beq a0, t1, cmd_flash_crc

    // return if an incorrect command is supplied
    beq a0, zero, return_to_caller

// To check if firmware upgrading mode is responsive
ping:
    li a0, ACK
    jal ra, uart_putc
    beq x0, x0, loop

// To unlock the flash memory for erasing
cmd_flash_unlock:
    jal ra, FLASH_Unlock_Fast
    li a0, ACK
    jal ra, uart_putc
    beq x0, x0, loop

// To lock the flash memory
cmd_flash_lock:
    jal ra, FLASH_Lock_Fast
    li a0, ACK
    jal ra, uart_putc
    beq x0, x0, loop

// To read a page from flash, compute crc and print over uart
cmd_flash_pr:
    // Get page address
    jal ra, uart_getc
    mv a3, a0
    
    // check limits for the page
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

    // call read_flash function that copies the flash
    // memory into sram
    jal ra, read_flash

// To print a memory array over uart
print_mem_to_uart:
    la a1, page_in_mem
    li t0, 0x010

    // print each word in little endian format
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

    // compute crc of the page read
    mv a0, a3
    li a1, 64
    jal ra, compute_crc

    // print the crc word in little endian format
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

// To erase a page in flash memory
cmd_flash_pe:
    // Get page address
    jal ra, uart_getc
    mv a3, a0
    
    // check limits for the page
    li t0, 0x030
    li t1, 0x100
    
    blt a0, t0, fail
    bge a0, t1, fail

    li t1, 0x08000000
    slli a4, a3, 6
    add t1, t1, a4

    mv a0, t1
    jal ra, FLASH_ErasePage_Fast

    li a0, ACK
    jal ra, uart_putc
    beq x0, x0, loop

// To write a page in flash memory
cmd_flash_pw:
    // Get page address
    jal ra, uart_getc
    mv a3, a0
    
    // check limits for the page
    li t0, 0x030
    li t1, 0x100
    
    blt a0, t0, fail
    bge a0, t1, fail

    addi sp, sp, -4
    sw a3, 0(sp)

    // Get 16 words (1 page) and store it in SRAM
    la a2, page_in_mem
    addi s1, a2, 64

2:
    jal ra, uart_getc
    mv a3, a0

    jal ra, uart_getc
    slli a0, a0, 8
    or a3, a3, a0

    jal ra, uart_getc
    slli a0, a0, 16
    or a3, a3, a0

    jal ra, uart_getc
    slli a0, a0, 24
    or a3, a3, a0

    sw a3, 0(a2)
    addi a2, a2, 4
    bne a2, s1, 2b

    // Get the CRC checksum of the 16 words (little endian format)
    jal ra, uart_getc
    mv a2, a0

    jal ra, uart_getc
    slli a0, a0, 8
    or a2, a2, a0

    jal ra, uart_getc
    slli a0, a0, 16
    or a2, a2, a0

    jal ra, uart_getc
    slli a0, a0, 24
    or a2, a2, a0
    mv s1, a2
    
    la a0, page_in_mem
    li a1, 64

    jal ra, compute_crc

    // return if crc check fails
    bne a0, s1, fail

    // Get page address
    lw a3, 0(sp)
    addi sp, sp, 4

    // Compute page address
    li t0, 0x08000000
    slli a3, a3, 6
    add a0, t0, a3

page_write_int:
    // write the page to flash memory
    la a1, page_in_mem
    li a2, 64

    jal ra, FLASH_ROM_WRITE

    li a0, ACK
    jal ra, uart_putc

    beq x0, x0, loop

// To set the location of SystemInit function
cmd_set_sini:
    // Get the location of SystemInit function (4B)
    jal ra, uart_getc
    mv a2, a0

    jal ra, uart_getc
    slli a0, a0, 8
    or a2, a2, a0

    jal ra, uart_getc
    slli a0, a0, 16
    or a2, a2, a0

    jal ra, uart_getc
    slli a0, a0, 24
    or a2, a2, a0
    mv s1, a2

    // compute flash starting address
    li a0, 0x08003FC0
    la a1, page_in_mem
    addi a2, a0, 64

    // call read_flash function that copies the flash
    // memory into sram
    jal ra, read_flash

    // Erase the page
    li a0, 0x08003FC0
    jal ra, FLASH_ErasePage_Fast

    // store the location of SystemInit in memory
    la a1, page_in_mem
    sw s1, 4(a1)

    // Write the page to FLASH
    beq x0, x0, page_write_int

// To set the location of main function
cmd_set_main:
    // Get the location of main function (4B)
    jal ra, uart_getc
    mv a2, a0

    jal ra, uart_getc
    slli a0, a0, 8
    or a2, a2, a0

    jal ra, uart_getc
    slli a0, a0, 16
    or a2, a2, a0

    jal ra, uart_getc
    slli a0, a0, 24
    or a2, a2, a0
    mv s1, a2

    // compute flash starting address
    li a0, 0x08003FC0
    la a1, page_in_mem
    addi a2, a0, 64

    // call read_flash function that copies the flash
    // memory into sram
    jal ra, read_flash

write_main_int:
    // Erase the page
    li a0, 0x08003FC0
    jal ra, FLASH_ErasePage_Fast
    
    // store the location of main in memory
    la a1, page_in_mem
    sw s1, 8(a1)

    // Write the page to FLASH
    beq x0, x0, page_write_int

// To recompute and store the crc in flash memory
cmd_flash_crc:
    // compute flash starting address
    li a0, 0x08003FC0
    la a1, page_in_mem
    addi a2, a0, 64

    // call read_flash function that copies the flash
    // memory into sram
    jal ra, read_flash

    la a0, FW_BASE
    // get the end of text pointer
    li t0, 0x08003FC0
    lw a1, 0(t0)
    li t1, 0x3F
    not t1, t1
    and a2, a1, t1
    bge a2, a1, next
    addi a1, a2, 64

    jal ra, compute_crc

    la a1, page_in_mem
    sw a0, 60(a1)

    // Erase the page
    li a0, 0x08003FC0
    jal ra, FLASH_ErasePage_Fast

    la a1, page_in_mem
    // Write the page to FLASH
    beq x0, x0, page_write_int

    la a0, ACK
    jal ra, uart_putc

    beq x0, x0, loop

// This is if the page range is outside the limits
fail:
    li a0, NACK
    jal ra, uart_putc
    beq x0, x0, loop

.section .rodata.bootloader, "a", @progbits
.align 4
fw_msg_1: .asciz "Entering Firmware Upgrade Mode..\n"
.align 4
fw_msg_2: .asciz "Exiting Firmware Upgrade Mode..\n"
.align 4
fw_msg_3: .asciz "Enter pin or supply 0x00000000 to exit:\n"

.section .data.bootloader, "a"
.align 4
page_in_mem: .space 64