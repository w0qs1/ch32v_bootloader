#include <ch32v00x_flash.h>

extern void uart_putc(uint32_t);
extern uint32_t uart_getc(void);
extern void print_uart(uint8_t *);
extern void gpio_init(void);
extern uint32_t gpio_check(void);

#define NACK                0x00
#define ACK                 0x01
#define PING                0x02
#define CMD_FLASH_UNLOCK    0x03
#define CMD_FLASH_LOCK      0x04
#define CMD_FLASH_PR        0x05
#define CMD_FLASH_PE        0x06
#define CMD_FLASH_EA        0x07
#define CMD_FLASH_WH        0x08

__attribute__((section(".rodata.bootloader")))
uint8_t fw_msg_1[] = "Entering Firmware Upgrade mode..\n";

__attribute__((section(".text.bootloader")))
void handle_fw_upgrade(void) {
    uint32_t fw_button;
    uint32_t uart_rx;
    gpio_init();
    fw_button = gpio_check();
    if(fw_button == 1) {
        return;
    }

    // Print "Entering Firmware Upgrade mode.."
    print_uart(fw_msg_1);

    while(1) {
        uart_rx = uart_getc();
        switch(uart_rx) {
            case PING:
                uart_putc(0x01);
                break;

            case 
            default:
                break;
        }
    }


    return;
}