import sys
import intelhex
import crcmod.predefined
import time

# def hex_to_bin(input_hex, output_bin):
#     """Convert Intel HEX to binary."""
#     ih = intelhex.IntelHex(input_hex)
#     ih.tofile(output_bin, format='bin')

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

def main(input_bin, output_hex, print_chk):
    # Compute Ethernet CRC32
    crc_int, crc_bytes = compute_crc32(input_bin)

    # Print the CRC in hexadecimal
    if print_chk:
        print(f"CRC32 added to FW: 0x{crc_int:08X}")

    # Append CRC32 to binary
    append_crc32_to_bin(input_bin, crc_bytes)

    # Convert binary back to HEX
    bin_to_hex(input_bin, output_hex)

    #print(f"CRC32 appended and saved to {output_hex}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python add_crc32_end.py <input.bin> <output.hex>")
        sys.exit(1)

    input_bin_file = sys.argv[1]
    output_hex_file = sys.argv[2]

    # Running it twice computes the correct CRC (sync issue)
    main(input_bin_file, output_hex_file, 0)
    main(input_bin_file, output_hex_file, 1)
