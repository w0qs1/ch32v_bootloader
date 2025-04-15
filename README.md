CH32V003 Bootloader for CH32V003XXXX microcontrollers

Find the application code at (https://github.com/w0qs1/ch32v_application_boot).

This is bootloader made for low-cost and resource constrained RISC-V MCUs. It supports:
1. Firmware Integrity check using CRC32.
2. Firmware Upgrade functionality via UART.
3. Firmware Upgrade also supports CRC check to ensure proper firmware upgrade.
4. The above features can be configured as per requirement in the boot_config.S file.

Steps to use the bootloader:
1. Find the Unique ID of the mcu (2 32-bit words) using WCH-LinkUtility. Computing XOR on the 2 words will give the 32-bit key.
2. Pull the PD0 pin to ground and RESET the MCU.
3. Run the HOST_Script.py in the DFU directory with the necessary options or run it with the 'help' argument for more info.
4. Run the HOST_Script.py with the argument 'pin AABBCCDD' where AABBCCDD is the 32-bit key computed. This unlocks the bootloader.
5. Use the argument 'clean' to erase the entire application section.
6. Use the argument 'program application.bin' to flash the application code generated as per https://github.com/w0qs1/ch32v_application_boot. This unlocks the flash for writing, writes the application, computes the crc and locks the flash.
7. Use the argument 'exit' to run the application.
8. Remove the connection from PD0 to ground to let the application run automatically (after firmware integrity check if enabled).
9. Note that for erasing the application, after using 'clean', use the argument 'crc' to recompute the crc for the bootloader; else the bootloader will not run (if FW_CHECK is enabled in the boot_config.S)