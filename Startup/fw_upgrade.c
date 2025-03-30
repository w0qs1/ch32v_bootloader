// #include <ch32v00x_flash.h>
// #include <stdint.h>

// // Fuctions from custom_boot
// extern void uart_putc(uint32_t);
// extern uint32_t uart_getc(void);
// extern void print_uart(const uint8_t *);
// extern void gpio_init(void);
// extern uint32_t gpio_check(void);
// extern uint32_t compute_crc(volatile uint32_t *, volatile uint32_t);
// extern void read_flash(volatile uint32_t *, volatile uint32_t *, volatile uint32_t *);

// #define NACK                0x00
// #define ACK                 0x01
// #define PING                0x02
// #define CMD_FLASH_UNLOCK    0x03
// #define CMD_FLASH_LOCK      0x04
// #define CMD_FLASH_PR        0x05
// #define CMD_FLASH_PE        0x06
// #define CMD_FLASH_PW        0x07
// // #define CMD_SET_SINI        0x08
// // #define CMD_SET_MAIN        0x09
// // #define CMD_FLASH_CRC       0x0A
// #define EXIT                0xFF

// __attribute__((section(".rodata.bootloader")))
// const uint8_t fw_msg_1[] = "Entering Firmware Upgrade mode..\n";

// __attribute__((section(".rodata.bootloader")))
// const uint8_t fw_msg_2[] = "Exiting Firmware Upgrade mode!\n";

// __attribute__((section(".text.bootloader")))
// void handle_fw_upgrade(void) {
//     uint32_t fw_button;
//     volatile uint32_t uart_rx;
//     volatile uint32_t *page_start;
//     volatile uint32_t page_in_mem[64];
//     volatile uint32_t buf[16];
//     volatile uint32_t crc_checksum, temp, page_address;

//     gpio_init();
//     fw_button = gpio_check();
//     if(fw_button == 1) {
//         return;
//     }

//     // Print "Entering Firmware Upgrade mode.."
//     print_uart(fw_msg_1);

//     while(1) {
//         uart_rx = uart_getc();
//         switch(uart_rx) {
//             case PING:
//                 uart_putc(ACK);
//                 break;

//             case CMD_FLASH_UNLOCK:
//                 FLASH_Unlock_Fast();
//                 uart_putc(ACK);
//                 break;

//             case CMD_FLASH_LOCK:
//                 FLASH_Lock_Fast();
//                 uart_putc(ACK);
//                 break;

//             case CMD_FLASH_PR:
//                 // Get page address (0x30 - 0xFF)
//                 uart_rx = uart_getc();

//                 // Trying to read bootloader or location out of flash
//                 if (uart_rx < 0x30 || uart_rx > 0xFF) {
//                     uart_putc(NACK);
//                     break;
//                 }

//                 uart_putc(ACK);

//                 page_start = (uint32_t *) (0x08000000 + ((uart_rx & 0xFF) * 64));

//                 read_flash(page_start, page_in_mem, page_start + 16);

//                 // print as per the bin file order
//                 for(volatile uint8_t i = 0; i < 16; i++) {
//                     temp = page_in_mem[i];
//                     uart_putc(temp & 0x000000FF);
//                     uart_putc((temp & 0x0000FF00) >> 8);
//                     uart_putc((temp & 0x00FF0000) >> 16);
//                     uart_putc((temp & 0xFF000000) >> 24);
//                 }

//                 // Set page_start again as this is getting changed
//                 page_start = (uint32_t *) (0x00000000 + ((uart_rx & 0xFF) * 64));

//                 temp = compute_crc(page_start, 64);
//                 uart_putc((temp & 0xFF000000) >> 24);
//                 uart_putc((temp & 0x00FF0000) >> 16);
//                 uart_putc((temp & 0x0000FF00) >> 8);
//                 uart_putc(temp & 0x000000FF);

//                 break;

//             case CMD_FLASH_PE:
//                 // Get page address
//                 uart_rx = uart_getc();

//                 // Trying to read bootloader or location out of flash
//                 if (uart_rx < 0x30 || uart_rx > 0xFF) {
//                     uart_putc(NACK);
//                     break;
//                 }

//                 FLASH_ErasePage_Fast(0x08000000 + ((uart_rx & 0xFF) * 64));

//                 uart_putc(ACK);

//                 break;

//             case CMD_FLASH_PW:
//                 // Get page address
//                 page_address = uart_getc();

//                 // Trying to write bootloader or location out of flash
//                 if (page_address < 0x30 || page_address > 0xFF) {
//                     uart_putc(NACK);
//                     break;
//                 }

//                 // Get data (64B) and CRC32 checksum in big endian
//                 for(uint8_t i = 0; i < 17; i++) {
//                     if(i == 16) {
//                         for(uint8_t j = 0; j < 4; j++) {
//                             uart_rx = uart_getc();
//                             crc_checksum = crc_checksum << 8;
//                             crc_checksum |= uart_rx & 0xFF;
//                         }
//                         break;
//                     }

//                     for(uint8_t j = 0; j < 4; j++) {
//                         uart_rx = uart_getc();
//                         buf[i] = buf[i] << 8;
//                         buf[i] |= uart_rx & 0xFF;
//                     }
//                 }

//                 temp = compute_crc(buf, 64);

//                 if(temp == crc_checksum) {
//                     FLASH_ROM_WRITE(0x08000000 + ((page_address & 0xFF) * 64), (uint32_t *) buf, 64);
//                     uart_putc(ACK);
//                 } else {
//                     uart_putc(NACK);
//                 }
//                 break;

//             // case CMD_SET_SINI:
//             //     // To set the location of SystemInit function in flash
//             //     for(uint8_t i = 0; i < 4; i++) {
//             //         temp = temp << 8;
//             //         uart_rx = uart_getc();
//             //         temp |= uart_rx & 0xFF;
//             //     }

//             //     // Copy last page to memory
//             //     page_start = (uint32_t *) 0x08003FC0;

//             //     read_flash(page_start, page_in_mem, page_start + 16);

//             //     page_in_mem[1] = temp;

//             //     // Fix the address issue
//             //     FLASH_ErasePage_Fast(0x08003FC0);
//             //     FLASH_ROM_WRITE(0x08003FC0, (uint32_t *) page_in_mem, 64);

//             //     // Write location of SystemInit into 0x08003FC4
//             //     // uart_rx = FLASH_ProgramWord(0x08003FC4, temp);
//             //     uart_putc(uart_rx);
//             //     break;

//             // case CMD_SET_MAIN:
//             //     // To set the location of main function in flash
//             //     for(uint8_t i = 0; i < 4; i++) {
//             //         temp = temp << 8;
//             //         uart_rx = uart_getc();
//             //         temp |= uart_rx & 0xFF;
//             //     }

//             //     // Write location of main into 0x08003FC8
//             //     FLASH_ProgramWord(0x08003FC8, temp);
//             //     uart_putc(ACK);
//             //     break;

//             // case CMD_FLASH_CRC:
//             //     // To recompute and store the CRC after application modification
//             //     break;

//             case EXIT:
//                 print_uart(fw_msg_2);
//                 return;
//             default:
//                 uart_putc(NACK);
//                 continue;
//         }
//     }


//     return;
// }