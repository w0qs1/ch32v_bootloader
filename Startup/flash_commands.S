// .section .text.bootloader, "ax"

// .equ    FLASH_ACTRL,            0x40022000
// .equ    FLASH_KEYR,             0x40022004
// .equ    FLASH_OBKEYR,           0x40022008
// .equ    FLASH_STATR,            0x4002200C
// .equ    FLASH_CTRL,             0x40022010
// .equ    FLASH_ADDR,             0x40022014
// .equ    FLASH_OBR,              0x4002201C
// .equ    FLASH_WPR,              0x40022020
// .equ    FLASH_MODEKEYR,         0x40022024
// .equ    FLASH_BOOT_MODEKEYR,    0x40022028

// .global flash_cmd_unlock 
// flash_cmd_unlock:
//     addi sp, sp, -4
//     sw ra, 0(sp)

//     li t0, FLASH_KEYR
//     li t1, 0x45670123
//     li t2, 0xCDEF89AB

//     // Unlock
//     sw t1, 0(t0)
//     sw t2, 0(t0)

//     li t0, FLASH_MODEKEYR

//     // Unlock fast programming mode
//     sw t1, 0(t0)
//     sw t2, 0(t0)

//     lw ra, 0(sp)
//     addi sp, sp, 4
//     jalr x0, 0(ra)

// .global flash_cmd_lock
// flash_cmd_lock:
//     addi sp, sp, -4
//     sw ra, 0(sp)

//     li t0, FLASH_CTRL
//     li t1, 0x00008000
//     lw t2, 0(t0)
//     or t2, t2, t1

//     // Lock the flash
//     sw t2, 0(t0)

//     lw ra, 0(sp)
//     addi sp, sp, 4
//     jalr x0, 0(ra)

// .global flash_cmd_erasepage
// flash_cmd_erasepage:
//     addi sp, sp, -4
//     sw ra, 0(sp)

//     // Set Page Erase Bit
//     li t0, FLASH_CTRL
//     lw t1, 0(t0)
//     li t2, 0x00020000
//     or t1, t1, t2
//     sw t1, 0(t0)

//     // Set Address
//     li t2, FLASH_ADDR
//     sw a0, 0(t2)

//     // Set STRT bit
//     lw t1, 0(t0)
//     li t2, 0x00000040
//     or t1, t1, t2
//     sw t1, 0(t0)

//     // Wait while flash is busy
//     li t2, FLASH_STATR
// 1:
//     lw s1, 0(t2)
//     andi s1, s1, 0x001
//     bne s1, zero, 1b

//     // Clear Page Erase Bit
//     li t1, ~(0x00020000)
//     sw t1, 0(t0)

//     lw ra, 0(sp)
//     addi sp, sp, 4
//     jalr x0, 0(ra)

// .global flash_cmd_writepage
// flash_cmd_writepage:
//     addi sp, sp, -4
//     sw ra, 0(sp)

//     mv s0, a0

//     li t0, FLASH_CTRL
//     li t1, 0x00010000
//     sw t1, 0(t0)
//     li t1, 0x00080000
//     sw t1, 0(t0)

// 1:
//     li t1, 0x00000010
//     sw a1, 0(a0)

//     li t2, 0x00040000
//     sw t2, 0(t0)

//     // Wait while flash is busy
//     li t2, FLASH_STATR
// 2:
//     lw s1, 0(t2)
//     andi s1, s1, 0x001
//     bne s1, zero, 2b

//     addi a0, a0, 4
//     addi a1, a1, 4
//     addi t1, t1, -1
//     bne t1, zero, 1b

//     li t1, 0x00010000
//     sw t1, 0(t0)
//     li t2, FLASH_ADDR
//     sw s0, 0(t2)
//     li t1, 0x00000040
//     sw t1, 0(t0)

//     // Wait while flash is busy
//     li t2, FLASH_STATR
// 3:
//     lw s1, 0(t2)
//     andi s1, s1, 0x001
//     bne s1, zero, 3b

//     // Clear Page Erase Bit
//     li t1, ~(0x00020000)
//     sw t1, 0(t0)

//     lw ra, 0(sp)
//     addi sp, sp, 4
//     jalr x0, 0(ra)

