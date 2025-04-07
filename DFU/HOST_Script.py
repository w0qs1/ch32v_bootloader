import serial
import time
import argparse
import struct
import binascii

class MCUFlasher:
    def __init__(self, port, baudrate=115200, timeout=1):
        """Initialize the serial connection to the MCU."""
        self.ser = serial.Serial(port, baudrate=baudrate, timeout=timeout)
        time.sleep(0.1)  # Give some time for the connection to establish
        
    def close(self):
        """Close the serial connection."""
        if self.ser and self.ser.is_open:
            self.ser.close()
            
    def _send_byte(self, byte):
        """Send a single byte to the MCU."""
        self.ser.write(bytes([byte]))
        time.sleep(0.001)

                
    def _read_byte(self):
        """Read a single byte from the MCU."""
        response = self.ser.read(1)
        if len(response) < 1:
            raise TimeoutError("MCU did not respond in time")
        return response[0]
    
    def _read_bytes(self, count):
        """Read multiple bytes from the MCU."""
        response = self.ser.read(count)
        if len(response) < count:
            raise TimeoutError(f"MCU did not send enough bytes. Expected {count}, got {len(response)}")
        return response
    
    def ping(self):
        """
        Send PING command (0x02) and expect ACK (0x01).
        Sequence: 0x02H, 0x01M
        """
        self._send_byte(0x02)  # PING command
        response = self._read_byte()
        return response == 0x01  # Check if ACK
    
    def flash_unlock(self):
        """
        Unlock the flash memory for flashing.
        Sequence: 0x03H, 0x01M
        """
        self._send_byte(0x03)  # CMD_FLASH_UNLOCK
        response = self._read_byte()
        return response == 0x01  # Check if ACK
    
    def flash_lock(self):
        """
        Lock the flash memory from flashing/erasing.
        Sequence: 0x04H, 0x01M
        """
        self._send_byte(0x04)  # CMD_FLASH_LOCK
        response = self._read_byte()
        return response == 0x01  # Check if ACK
    
    def flash_read_page(self, page_addr):
        """
        Read a page (64B) from the flash.
        Sequence: 0x05H, 0xPQH, 0x01M, 0xaaM, 0xbbM, ....
        
        Args:
            page_addr: Page address in hex (range from 0x30 to 0xFF)
            
        Returns:
            The page data (64 bytes)
        """
        if not (0x30 <= page_addr <= 0xFF):
            raise ValueError("Page address must be between 0x30 and 0xFF")
            
        self._send_byte(0x05)  # CMD_FLASH_PR
            
        # Send page address
        self._send_byte(page_addr)

        # Check for ACK
        response = self._read_byte()
        if response != 0x01:
            raise RuntimeError(f"MCU did not acknowledge the command. Got: 0x{response:02X}")
        
        # Read page data (64 bytes)
        page_data = self._read_bytes(64)

        crc_bytes = self._read_bytes(4)
        received_crc = struct.unpack('<I', crc_bytes)[0]  # Little-endian

        # Calculate CRC32 using Ethernet polynomial
        calculated_crc = binascii.crc32(page_data) & 0xFFFFFFFF

        if received_crc != calculated_crc:
            raise RuntimeError(f"CRC mismatch! Received: 0x{received_crc:08X}, Calculated: 0x{calculated_crc:08X}")
        
        return page_data
    
    def flash_erase_page(self, page_addr):
        """
        Erase a page (64B) from the flash.
        Sequence: 0x06H, 0x01M
        
        Args:
            page_addr: Page address in hex (range from 0x30 to 0xFF)
        """
        if not (0x30 <= page_addr <= 0xFF):
            raise ValueError("Page address must be between 0x30 and 0xFF")
            
        self._send_byte(0x06)  # CMD_FLASH_PE
        
        # Send page address
        self._send_byte(page_addr)

        # Check for ACK
        response = self._read_byte()
        if response != 0x01:
            return False
        
        return True

    def flash_write_page(self, page_addr, file_path):
        """
        Write a page (64B) into the flash with CRC32 appended.
        Sequence: 0x07H, 0xYYH, <64 bytes>, <4-byte CRC>, 0x01M

        Args:
            page_addr: Page address in hex (range from 0x30 to 0xFF)
            file_path: Path to binary file (must contain exactly 64 bytes)
        """
        if not (0x30 <= page_addr <= 0xFF):
            raise ValueError("Page address must be between 0x30 and 0xFF")

        # Read data from file
        with open(file_path, 'rb') as f:
            data = f.read(64)
            if len(data) != 64:
                raise ValueError(f"File must contain exactly 64 bytes, found {len(data)} bytes")

        # Compute CRC32 (Ethernet polynomial, default init/final XORs)
        crc = binascii.crc32(data) & 0xFFFFFFFF
        crc_bytes = struct.pack('<I', crc)  # Little-endian

        full_payload = data + crc_bytes  # 64B data + 4B CRC

        # Unlock and erase the page
        if not self.flash_unlock():
            raise RuntimeError("Failed to unlock flash before write")
        if not self.flash_erase_page(page_addr):
            raise RuntimeError("Failed to erase flash page before write")

        # Send write command
        self._send_byte(0x07)           # CMD_FLASH_PW
        self._send_byte(page_addr)      # Page address

        # Send data + CRC
        for byte in full_payload:
            self._send_byte(byte)

        # Wait for ACK
        response = self._read_byte()
        if response != 0x01:
            raise RuntimeError(f"MCU did not acknowledge page write. Got: 0x{response:02X}")

        return True

    def flash_write_file(self, file_path):
        """
        Write an entire binary file to flash memory starting from page 0x30.
        The file is written in 64-byte pages, one page at a time.
        
        Args:
            file_path: Path to binary file
        """
        self.flash_unlock()
        with open(file_path, 'rb') as f:
            page_addr = 0x30
            while True:
                chunk = f.read(64)
                if not chunk:
                    break  # End of file

                if len(chunk) < 64:
                    # Pad the last chunk with 0xFF (erased flash value)
                    chunk += b'\xFF' * (64 - len(chunk))

                # Write the 64-byte chunk to a temporary file
                temp_path = 'temp_page.bin'
                with open(temp_path, 'wb') as temp_f:
                    temp_f.write(chunk)

                print(f"Writing page 0x{page_addr:02X}...")
                self.flash_write_page(page_addr, temp_path)

                page_addr += 1
                if page_addr > 0xFF:
                    break
                # if page_addr > 0xFF:
                #     raise RuntimeError("File too large to fit in available flash pages (0x30 to 0xFF)")

        self.recompute_crc()

    def recompute_crc(self):
        """
        Request MCU to recompute the firmware CRC and store it in flash.

        Sequence: 0x0BH, 0x01M
        MCU will respond with 0x01 if successful.
        """
        self._send_byte(0x0A)  # CMD_RECOMPUTE_CRC

        response = self._read_byte()
        if response != 0x01:
            raise RuntimeError(f"MCU did not acknowledge CRC recomputation. Got: 0x{response:02X}")

        return True

    def disable_application(self):
        """
        Disable the bootloader from running the application by erasing the last page
        """
        self.flash_erase_page(0xFF)
        response = self._read_byte()
        return response == 0x01  # Check if ACK

    def erase_application(self):
        """
        Erase the entire application partition (erases pages 0x30 to 0xFF)
        """
        self.flash_unlock()
        for i in range(0x30, 0x100):
            print(f"Erasing page 0x{i:02X}...")
            self.flash_erase_page(i)

    def exit_fw_upgrade(self):
        """
        Exit the Firmware upgrade mode.
        Sequence: 0x00H
        """
        self._send_byte(0x00)  # EXIT command
        # No response expected for this command according to the protocol
        return True

def main():
    parser = argparse.ArgumentParser(description='MCU Flash Programmer via UART')
    parser.add_argument('--port', required=True, help='Serial port to use (e.g., COM3 or /dev/ttyUSB0)')
    parser.add_argument('--baudrate', type=int, default=115200, help='Baud rate (default: 115200)')
    
    subparsers = parser.add_subparsers(dest='command', help='Command to execute')
    
    # Ping command
    subparsers.add_parser('ping', help='Check if MCU is in FW Upgrade mode')
    
    # Unlock command
    subparsers.add_parser('unlock', help='Unlock the flash memory for flashing')
    
    # Lock command
    subparsers.add_parser('lock', help='Lock the flash memory from flashing/erasing')

    # Read page command
    read_parser = subparsers.add_parser('read', help='Read a page from flash')
    read_parser.add_argument('page', type=lambda x: int(x, 16), help='Page address (0x30-0xFF)')

    # Erase page command
    erase_parser = subparsers.add_parser('erase', help='Erase a page from flash')
    erase_parser.add_argument('page', type=lambda x: int(x, 16), help='Page address (0x30-0xFF)')

    # Write page command
    write_parser = subparsers.add_parser('write', help='Write a 64-byte page to flash')
    write_parser.add_argument('page', type=lambda x: int(x, 16), help='Page address (0x30-0xFF)')
    write_parser.add_argument('file', type=str, help='Path to 64-byte binary file')

    # Write full file command
    full_write_parser = subparsers.add_parser('program', help='Write full binary file to flash starting from 0x30')
    full_write_parser.add_argument('file', type=str, help='Path to binary file')

    # Recompute CRC command
    subparsers.add_parser('crc', help='Recompute the flash contents')

    # Disable application command
    subparsers.add_parser('disable', help='Disable application from running')

    # Erase application command
    subparsers.add_parser('clean', help='Erase the application partition')
    
    # Exit command
    subparsers.add_parser('exit', help='Exit the Firmware upgrade mode')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        return
    
    try:
        mcu = MCUFlasher(args.port, baudrate=args.baudrate)
        
        if args.command == 'ping':
            if mcu.ping():
                print("Ping successful, MCU is in FW Upgrade mode.")
            else:
                print("Ping failed, MCU did not respond with ACK.")
                
        elif args.command == 'unlock':
            if mcu.flash_unlock():
                print("Flash memory unlocked successfully.")
            else:
                print("Failed to unlock flash memory.")
                
        elif args.command == 'lock':
            if mcu.flash_lock():
                print("Flash memory locked successfully.")
            else:
                print("Failed to lock flash memory.")
                
        elif args.command == 'read':
            try:
                data = mcu.flash_read_page(args.page)
                print(f"Page data (hex): {data.hex()}")
            except ValueError as e:
                print(f"Error: {e}")
                    
        elif args.command == 'erase':
            if mcu.flash_erase_page(args.page):
                print(f"Page 0x{args.page:02X} erased successfully.")
            else:
                print(f"Failed to erase page 0x{args.page:02X}.")

        elif args.command == 'write':
            if mcu.flash_write_page(args.page, args.file):
                print(f"Page 0x{args.page:02X} written successfully.")
            else:
                print(f"Error during flash write")

        elif args.command == 'program':
            mcu.flash_write_file(args.file)
            print("Full file written successfully.")

        elif args.command == 'crc':
            mcu.recompute_crc()
            print("New CRC Computed")

        elif args.command == 'disable':
            mcu.disable_application()
            print("Disabled Application")

        elif args.command == 'clean':
            mcu.erase_application()
            print("Erased Application Partition")
                    
        elif args.command == 'exit':
            mcu.flash_lock()
            mcu.exit_fw_upgrade()
            print("Exited firmware upgrade mode.")
            
    except Exception as e:
        print(f"Error: {e}")
    finally:
        if 'mcu' in locals():
            mcu.close()

if __name__ == "__main__":
    main()