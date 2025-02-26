import sys
import intelhex
import crcmod.predefined
import random

# def hex_to_bin(input_hex, output_bin):
#     """Convert Intel HEX to binary."""
#     ih = intelhex.IntelHex(input_hex)
#     ih.tofile(output_bin, format='bin')

def corrupt(input_bin):
    """Corrupt a random number of bytes (1-5) in the binary file."""
    with open(input_bin, 'r+b') as f:
        data = bytearray(f.read())
        num_bytes = random.randint(1, 2)  # Choose how many bytes to corrupt
        file_size = min(len(data), 0x3E0) # Corrupt only the application
        
        for _ in range(num_bytes):
            index = random.randint(0, file_size - 1)  # Choose a random index
            data[index] = random.randint(0, 255)  # Change to a random byte value
        
        f.seek(0)
        f.write(data)

def compute_crc32(binary_file):
    """Compute Ethernet CRC32 of the binary file using polynomial 0x04C11DB7."""
    with open(binary_file, 'rb') as f:
        data = f.read()

    # Create a CRC function using the Ethernet polynomial.
    # The 'crc-32' predefined in crcmod uses polynomial 0x04C11DB7.
    crc32_func = crcmod.predefined.Crc('crc-32')
    crc32_func.update(data)
    crc_int = crc32_func.crcValue & 0xFFFFFFFF
    crc_bytes = crc_int.to_bytes(4, byteorder='little')
    return crc_int, crc_bytes

def append_crc32_to_bin(binary_file, crc_bytes):
    """Append CRC32 checksum to binary file."""
    with open(binary_file, 'ab') as f:
        f.write(crc_bytes)

def bin_to_hex(input_bin, output_hex):
    """Convert binary back to Intel HEX format."""
    ih = intelhex.IntelHex()
    ih.loadbin(input_bin, offset=0)
    ih.tofile(output_hex, format='hex')

def main(input_bin, output_hex):

    # Compute Ethernet CRC32
    crc_int, crc_bytes = compute_crc32(input_bin)

    # Print the CRC in hexadecimal
    print(f"CRC32 added to FW: 0x{crc_int:08X}")

    # Append CRC32 to binary
    append_crc32_to_bin(input_bin, crc_bytes)

    # Change some random bytes to random values
    corrupt(input_bin)

    # Print
    print("Corrupted the firmware")

    # Convert binary back to HEX
    bin_to_hex(input_bin, output_hex)

    #print(f"CRC32 appended and saved to {output_hex}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python corrupt_firmware.py <input.bin> <output.hex>")
        sys.exit(1)

    input_bin_file = sys.argv[1]
    output_hex_file = sys.argv[2]

    main(input_bin_file, output_hex_file)
