/********************************** (C) COPYRIGHT *******************************
 * File Name          : main.c
 * Author             : WCH
 * Version            : V1.0.0
 * Date               : 2023/12/25
 * Description        : Main program body.
 *********************************************************************************
 * Copyright (c) 2021 Nanjing Qinheng Microelectronics Co., Ltd.
 * Attention: This software (modified or not) and binary are used for 
 * microcontroller manufactured by Nanjing Qinheng Microelectronics.
 *******************************************************************************/

// #include <ch32v00x.h>
// #include <ch32v00x_gpio.h>

// /* Global define */

// /* Global Variable */

// /*********************************************************************
//  * @fn      main
//  *
//  * @brief   Main program.
//  *
//  * @return  none
//  */
// int main(void)
// {
//     // Turn on Clocks for GPIOD Peripheral in APB2 Bus
//     RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOD, ENABLE);

//     // Create a Init structure
//     GPIO_InitTypeDef GPIOInitStructure = {0};
//     GPIOInitStructure.GPIO_Pin = GPIO_Pin_0;
//     GPIOInitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
//     GPIOInitStructure.GPIO_Speed = GPIO_Speed_30MHz;

//     // Initialize GPIO
//     GPIO_Init(GPIOD, &GPIOInitStructure);
//     Delay_Init();

//     while(1)
//     {
//         GPIO_WriteBit(GPIOD, GPIO_Pin_0, Bit_SET);
//         Delay_Ms(500);
//         GPIO_WriteBit(GPIOD, GPIO_Pin_0, Bit_RESET);
//         Delay_Ms(500);
//     }
// }

#include <stdint.h>

#define RCC_BASE            0x40021000UL
#define RCC_APB2_CLK_EN     (RCC_BASE + 0x18)
#define GPIOD_BASE          0x40011400UL
#define GPIOD_CFGLR         (GPIOD_BASE + 0x00)
#define GPIOD_BSRR         (GPIOD_BASE + 0x10)

void delay_ms(int n) {
    for(volatile uint32_t i = 0; i < n; i++) {
        for(volatile uint32_t j = 0; j < 3000; j++);    // ~1ms
    }
}

int main(void) {
    // Enable Clock for GPIOD in APB2
    volatile uint32_t *rcc_apb2_clk_en = (uint32_t *) RCC_APB2_CLK_EN;
    *rcc_apb2_clk_en |= (1 << 5);

    volatile uint32_t *gpiod_cfglr = (uint32_t *) GPIOD_CFGLR;
    *gpiod_cfglr |= (1 << 9) | (1 << 8);    // Output mode with max speed 30MHz
    *gpiod_cfglr &= ~((1 << 10) | (1 << 11)); // Output mode with Push pull configuration

    volatile uint32_t *gpiod_bsrr = (uint32_t *) GPIOD_BSRR;
    
    while(1) {
        *gpiod_bsrr |= (1 << 18);
        delay_ms(500);
        *gpiod_bsrr |= (1 << 2);
        delay_ms(500);
    }
}


// int main(void) {
//     while(1);
// }