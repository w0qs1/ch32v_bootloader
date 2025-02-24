// Configuration parameters for Boot

// Check for Firmware Integrity using CRC32
.equ FW_CHECK,      1               // set 1 for checking firmware
.equ FW_BASE,       0x00000000      // set the starting location of the firmware to be checked
.equ FW_END,        0x00000000      // set the ending location
.equ CRC_LOC,       0x00000000      // set the location of CRC remainder (FLASH)

// UART Parameters
// Use the below table to set the baud rate UART during boot
// The UART uses the 8N1 configuration
// The boot runs at 24MHz using the High Speed Internal (HSI) Oscillator
// -----------------+----------+---------
// UART Baud Rate   | Mantissa | Fraction
// -----------------+----------+---------
// 9600             |    -     |     -
// 19200            |    -     |     -
// 28400            |    -     |     -
// 115200           |    4     |     5
// -----------------+----------+---------
.equ UART_B_M,      4               // UART Baudrate Mantissa
.equ UART_B_F,      5               // UART Baudrate Fraction

