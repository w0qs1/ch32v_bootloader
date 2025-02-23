// #include <stdint.h>

// #define RCC_BASE            0x40021000UL
// #define RCC_APB2_CLK_EN     (RCC_BASE + 0x18)
// #define GPIOD_BASE          0x40011400UL
// #define GPIOD_CFGLR         (GPIOD_BASE + 0x00)
// #define GPIOD_BSRR         (GPIOD_BASE + 0x10)

// volatile uint8_t msg[] = "Hello, World!";

// void delay_ms(int n) {
//     for(volatile uint32_t i = 0; i < n; i++) {
//         for(volatile uint32_t j = 0; j < 2400; j++);    // ~1ms
//     }
// }

// void app(void) {
//     msg[0]++;
//     // Enable Clock for GPIOD in APB2
//     volatile uint32_t *rcc_apb2_clk_en = (uint32_t *) RCC_APB2_CLK_EN;
//     *rcc_apb2_clk_en |= (1 << 5);

//     volatile uint32_t *gpiod_cfglr = (uint32_t *) GPIOD_CFGLR;
//     *gpiod_cfglr |= (1 << 1) | (1 << 0);    // Output mode with max speed 30MHz
//     *gpiod_cfglr &= ~((1 << 2) | (1 << 3)); // Output mode with Push pull configuration

//     volatile uint32_t *gpiod_bsrr = (uint32_t *) GPIOD_BSRR;
    
//     while(1) {
//         *gpiod_bsrr |= (1 << 0);
//         delay_ms(500);
//         *gpiod_bsrr |= (1 << 16);
//         delay_ms(500);
//     }
// }