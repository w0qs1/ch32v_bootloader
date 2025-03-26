import serial
import time
import argparse

class MCUFlasher:
    def __init__(self, port, baudrate=115200, timeout=1):
        """Initialize the serial connection to the MCU."""
        self.ser = serial.Serial(port, baudrate=baudrate, timeout=timeout)
        time.sleep(2)  # Give some time for the connection to establish
        
    def close(self):
        """Close the serial connection."""
        if self.ser and self.ser.is_open:
            self.ser.close()
            
    def _send_byte(self, byte):
        """Send a single byte to the MCU."""
        self.ser.write(bytes([byte]))
                
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
        Sequence: 0x05H, 0x01M, 0xPQH, 0xaaM, 0xbbM, ....
        
        Args:
            page_addr: Page address in hex (range from 0x30 to 0xFF)
            
        Returns:
            The page data (64 bytes)
        """
        if not (0x30 <= page_addr <= 0xFF):
            raise ValueError("Page address must be between 0x30 and 0xFF")
            
        self._send_byte(0x05)  # CMD_FLASH_PR
        
        # Check for ACK
        response = self._read_byte()
        if response != 0x01:
            raise RuntimeError(f"MCU did not acknowledge the command. Got: 0x{response:02X}")
            
        # Send page address
        self._send_byte(page_addr)
        
        # Read page data (64 bytes)
        page_data = self._read_bytes(64)
        
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
        
        # Check for ACK
        response = self._read_byte()
        if response != 0x01:
            return False
        
        # Send page address
        self._send_byte(page_addr)
        
        return True
    
    def flash_write_word(self, address, data):
        """
        Write a word to flash.
        Sequence: 0x07H, 0xPQH, 0xRSH, 0xTUH, 0xVWH, 0xOPH, 0xMNH, 0xKLH, 0xIJH, 0x01M
        
        Args:
            address: 32-bit address (0xPQRSTUVW)
            data: 32-bit data (0xIJKLMNOP)
        """
        self._send_byte(0x07)  # CMD_FLASH_PW
        
        # Send address (32 bits, big-endian)
        addr_bytes = address.to_bytes(4, byteorder='big')
        for b in addr_bytes:
            self._send_byte(b)
            
        # Send data (32 bits, little-endian according to the sequence)
        data_bytes = data.to_bytes(4, byteorder='little')
        for b in data_bytes:
            self._send_byte(b)
            
        response = self._read_byte()
        return response == 0x01  # Check if ACK
    
    def exit_fw_upgrade(self):
        """
        Exit the Firmware upgrade mode.
        Sequence: 0xFFH
        """
        self._send_byte(0xFF)  # EXIT command
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
    
    # Write word command
    write_parser = subparsers.add_parser('write', help='Write a word to flash')
    write_parser.add_argument('address', type=lambda x: int(x, 16), help='32-bit address')
    write_parser.add_argument('data', type=lambda x: int(x, 16), help='32-bit data')
    
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
            if mcu.flash_write_word(args.address, args.data):
                print(f"Word written successfully to address 0x{args.address:08X}.")
            else:
                print(f"Failed to write word to address 0x{args.address:08X}.")
                    
        elif args.command == 'exit':
            mcu.exit_fw_upgrade()
            print("Exited firmware upgrade mode.")
            
    except Exception as e:
        print(f"Error: {e}")
    finally:
        if 'mcu' in locals():
            mcu.close()

if __name__ == "__main__":
    main()