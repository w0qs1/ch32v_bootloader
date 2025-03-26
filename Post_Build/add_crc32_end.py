# # import sys
# # import intelhex
# # import crcmod.predefined
# # import shutil

# # def compute_crc32(binary_file):
# #     """Compute Ethernet CRC32 of the binary file using polynomial 0x04C11DB7."""
# #     with open(binary_file, 'rb') as f:
# #         data = f.read()

# #     # Create a CRC function using the Ethernet polynomial.
# #     crc32_func = crcmod.predefined.Crc('crc-32')
# #     crc32_func.update(data)
# #     crc_int = crc32_func.crcValue & 0xFFFFFFFF
# #     crc_bytes = crc_int.to_bytes(4, byteorder='little')
# #     return crc_int, crc_bytes

# # def append_crc32_to_bin(original_bin, new_bin, crc_bytes):
# #     """Create a new binary file with the CRC32 checksum appended."""
# #     shutil.copyfile(original_bin, new_bin)  # Copy original binary to avoid modification
# #     with open(new_bin, 'ab') as f:
# #         f.write(crc_bytes)

# # def bin_to_hex(input_bin, output_hex):
# #     """Convert binary back to Intel HEX format."""
# #     ih = intelhex.IntelHex()
# #     ih.loadbin(input_bin, offset=0)
# #     ih.tofile(output_hex, format='hex')

# # def main(input_bin, output_bin, output_hex):
# #     # Compute Ethernet CRC32
# #     crc_int, crc_bytes = compute_crc32(input_bin)

# #     # Print the CRC in hexadecimal
# #     print(f"CRC32 added to FW: 0x{crc_int:08X}")

# #     # Append CRC32 to a new binary file
# #     append_crc32_to_bin(input_bin, output_bin, crc_bytes)

# #     # Convert binary back to HEX
# #     bin_to_hex(output_bin, output_hex)

# # if __name__ == "__main__":
# #     if len(sys.argv) != 4:
# #         print("Usage: python add_crc32_end.py <input.bin> <output.bin> <output.hex>")
# #         sys.exit(1)

# #     input_bin_file = sys.argv[1]
# #     output_bin_file = sys.argv[2]  # New binary file with CRC
# #     output_hex_file = sys.argv[3]

# #     main(input_bin_file, output_bin_file, output_hex_file)

# # import sys
# # import intelhex
# # import crcmod.predefined
# # import shutil
# # import os

# # def compute_crc32(binary_file, page_size=64, crc_address=0x00003FFC, end_of_text_address=0x00003FC0):
# #     """Compute Ethernet CRC32 of the binary file using polynomial 0x04C11DB7 in 64B pages."""
# #     with open(binary_file, 'rb') as f:
# #         data = f.read()
    
# #     # Read the end of data address from the specified location
# #     if len(data) >= end_of_text_address + 4:
# #         end_of_data = int.from_bytes(data[end_of_text_address:end_of_text_address+4], 'little')
# #     else:
# #         raise ValueError("End of text address is out of bounds in the binary file.")
    
# #     # Align end_of_data to the nearest lower multiple of 64B
# #     end_of_data = (end_of_data // page_size) * page_size
    
# #     # Truncate data up to the last valid 64B-aligned page
# #     data = data[:end_of_data]
    
# #     # Create a CRC function using the Ethernet polynomial.
# #     crc32_func = crcmod.predefined.Crc('crc-32')
# #     crc32_func.update(data)
# #     crc_int = crc32_func.crcValue & 0xFFFFFFFF
# #     crc_bytes = crc_int.to_bytes(4, byteorder='little')
# #     return crc_int, crc_bytes, data

# # def write_crc32_at_address(original_bin, new_bin, crc_bytes, crc_address=0x00003FFC, flash_size=0x00004000):
# #     """Write the CRC32 checksum at a fixed address within the binary."""
# #     if original_bin != new_bin:
# #         shutil.copyfile(original_bin, new_bin)  # Copy original binary to avoid modification
    
# #     # Ensure the file is large enough to contain the CRC location
# #     with open(new_bin, 'rb+') as f:
# #         f.seek(0, os.SEEK_END)
# #         file_size = f.tell()
        
# #         if file_size < flash_size:
# #             # Pad the file with 0xFF to reach the flash size
# #             f.write(b'\xFF' * (flash_size - file_size))
        
# #         # Write CRC at the specified address
# #         f.seek(crc_address)
# #         f.write(crc_bytes)

# # def bin_to_hex(input_bin, output_hex):
# #     """Convert binary back to Intel HEX format."""
# #     ih = intelhex.IntelHex()
# #     ih.loadbin(input_bin, offset=0)
# #     ih.tofile(output_hex, format='hex')

# # def main(input_bin, output_bin, output_hex):
# #     # Compute Ethernet CRC32 in 64B pages up to the valid data range
# #     crc_int, crc_bytes, truncated_data = compute_crc32(input_bin)

# #     # Print the CRC in hexadecimal
# #     print(f"CRC32 added to FW at 0x00003FFC: 0x{crc_int:08X}")

# #     # Write the truncated data to a new binary file
# #     with open(output_bin, 'wb') as f:
# #         f.write(truncated_data)
    
# #     # Write CRC32 at the fixed location in the new binary file
# #     write_crc32_at_address(output_bin, output_bin, crc_bytes)

# #     # Convert binary back to HEX
# #     bin_to_hex(output_bin, output_hex)

# # if __name__ == "__main__":
# #     if len(sys.argv) != 4:
# #         print("Usage: python add_crc32_fixed.py <input.bin> <output.bin> <output.hex>")
# #         sys.exit(1)

# #     input_bin_file = sys.argv[1]
# #     output_bin_file = sys.argv[2]  # New binary file with CRC at fixed address
# #     output_hex_file = sys.argv[3]

# #     main(input_bin_file, output_bin_file, output_hex_file)

# # import sys
# # import intelhex
# # import crcmod.predefined
# # import shutil
# # import os

# # def compute_crc32(binary_file, page_size=64, crc_address=0x00003FFC, end_of_text_address=0x00003FC0):
# #     """Compute Ethernet CRC32 of the binary file using polynomial 0x04C11DB7 in 64B pages."""
# #     with open(binary_file, 'rb') as f:
# #         data = f.read()
    
# #     # Read the end of data address from the specified location
# #     if len(data) >= end_of_text_address + 4:
# #         end_of_data = int.from_bytes(data[end_of_text_address:end_of_text_address+4], 'little')
# #     else:
# #         raise ValueError("End of text address is out of bounds in the binary file.")
    
# #     # Align end_of_data to the nearest lower multiple of 64B
# #     end_of_data = (end_of_data // page_size) * page_size
    
# #     # Truncate data up to the last valid 64B-aligned page
# #     data = data[:end_of_data]
    
# #     # Create a CRC function using the Ethernet polynomial.
# #     crc32_func = crcmod.predefined.Crc('crc-32')
# #     crc32_func.update(data)
# #     crc_int = crc32_func.crcValue & 0xFFFFFFFF
# #     crc_bytes = crc_int.to_bytes(4, byteorder='little')
# #     return crc_int, crc_bytes, data

# # def write_crc32_at_address(original_bin, new_bin, crc_bytes, crc_address=0x00003FFC, flash_size=0x00004000, end_of_text_address=0x00003FC0):
# #     """Write the CRC32 checksum at a fixed address within the binary without overwriting 4B at 0x00003FC0."""
# #     if original_bin != new_bin:
# #         shutil.copyfile(original_bin, new_bin)  # Copy original binary to avoid modification
    
# #     # Ensure the file is large enough to contain the CRC location
# #     with open(new_bin, 'rb+') as f:
# #         f.seek(0, os.SEEK_END)
# #         file_size = f.tell()
        
# #         if file_size < flash_size:
# #             # Pad the file with 0xFF to reach the flash size, avoiding 0x00003FC0
# #             padding_start = max(file_size, end_of_text_address + 4)
# #             if padding_start < flash_size:
# #                 f.seek(padding_start)
# #                 for addr in range(padding_start, flash_size):
# #                     if addr < end_of_text_address or addr >= end_of_text_address + 4:
# #                         f.write(b'\xFF')
        
# #         # Ensure we do NOT modify 0x00003FC0
# #         if crc_address >= end_of_text_address and crc_address < end_of_text_address + 4:
# #             raise ValueError(f"CRC address (0x{crc_address:X}) overlaps with reserved address (0x{end_of_text_address:X}).")
        
# #         # Write CRC at the specified address only if it does not overlap 0x00003FC0
# #         f.seek(crc_address)
# #         f.write(crc_bytes)

# # def bin_to_hex(input_bin, output_hex):
# #     """Convert binary back to Intel HEX format."""
# #     ih = intelhex.IntelHex()
# #     ih.loadbin(input_bin, offset=0)
# #     ih.tofile(output_hex, format='hex')

# # def main(input_bin, output_bin, output_hex):
# #     # Compute Ethernet CRC32 in 64B pages up to the valid data range
# #     crc_int, crc_bytes, truncated_data = compute_crc32(input_bin)

# #     # Print the CRC in hexadecimal
# #     print(f"CRC32 added to FW at 0x00003FFC: 0x{crc_int:08X}")

# #     # Write the truncated data to a new binary file
# #     with open(output_bin, 'wb') as f:
# #         f.write(truncated_data)
    
# #     # Write CRC32 at the fixed location in the new binary file
# #     write_crc32_at_address(output_bin, output_bin, crc_bytes)

# #     # Convert binary back to HEX
# #     bin_to_hex(output_bin, output_hex)

# # if __name__ == "__main__":
# #     if len(sys.argv) != 4:
# #         print("Usage: python add_crc32_fixed.py <input.bin> <output.bin> <output.hex>")
# #         sys.exit(1)

# #     input_bin_file = sys.argv[1]
# #     output_bin_file = sys.argv[2]  # New binary file with CRC at fixed address
# #     output_hex_file = sys.argv[3]

# #     main(input_bin_file, output_bin_file, output_hex_file)

# # import sys
# # import intelhex
# # import crcmod.predefined
# # import shutil
# # import os

# # def compute_crc32(binary_file, page_size=64, crc_address=0x00003FFC, end_of_text_address=0x00003FC0):
# #     """Compute Ethernet CRC32 of the binary file using polynomial 0x04C11DB7 in 64B pages."""
# #     with open(binary_file, 'rb') as f:
# #         data = f.read()
    
# #     # Read the end of data address from the specified location
# #     if len(data) >= end_of_text_address + 4:
# #         end_of_data = int.from_bytes(data[end_of_text_address:end_of_text_address+4], 'little')
# #     else:
# #         raise ValueError("End of text address is out of bounds in the binary file.")
    
# #     # Align end_of_data to the nearest lower multiple of 64B
# #     end_of_data = (end_of_data // page_size) * page_size
    
# #     # Truncate data up to the last valid 64B-aligned page
# #     data = data[:end_of_data]
    
# #     # Create a CRC function using the Ethernet polynomial.
# #     crc32_func = crcmod.predefined.Crc('crc-32')
# #     crc32_func.update(data)
# #     crc_int = crc32_func.crcValue & 0xFFFFFFFF
# #     crc_bytes = crc_int.to_bytes(4, byteorder='little')
# #     return crc_int, crc_bytes, data

# # def write_crc32_at_address(original_bin, new_bin, crc_bytes, crc_address=0x00003FFC, flash_size=0x00004000, end_of_text_address=0x00003FC0):
# #     """Write the CRC32 checksum at a fixed address within the binary without overwriting 4B at 0x00003FC0."""
# #     if original_bin != new_bin:
# #         shutil.copyfile(original_bin, new_bin)  # Copy original binary to avoid modification
    
# #     # Ensure the file is large enough to contain the CRC location
# #     with open(new_bin, 'rb+') as f:
# #         f.seek(0, os.SEEK_END)
# #         file_size = f.tell()
        
# #         if file_size < flash_size:
# #             # Pad the file with 0xFF to reach the flash size, avoiding 0x00003FC0 and 0x00003FFC
# #             f.seek(file_size)
# #             for addr in range(file_size, flash_size):
# #                 if (addr < end_of_text_address or addr >= end_of_text_address + 4) and (addr < crc_address or addr >= crc_address + 4):
# #                     f.write(b'\xFF')
        
# #         # Ensure we do NOT modify 0x00003FC0
# #         if crc_address >= end_of_text_address and crc_address < end_of_text_address + 4:
# #             raise ValueError(f"CRC address (0x{crc_address:X}) overlaps with reserved address (0x{end_of_text_address:X}.)")
        
# #         # Write CRC at the specified address only if it does not overlap 0x00003FC0
# #         f.seek(crc_address)
# #         f.write(crc_bytes)

# # def bin_to_hex(input_bin, output_hex):
# #     """Convert binary back to Intel HEX format."""
# #     ih = intelhex.IntelHex()
# #     ih.loadbin(input_bin, offset=0)
# #     ih.tofile(output_hex, format='hex')

# # def main(input_bin, output_bin, output_hex):
# #     # Compute Ethernet CRC32 in 64B pages up to the valid data range
# #     crc_int, crc_bytes, truncated_data = compute_crc32(input_bin)

# #     # Print the CRC in hexadecimal
# #     print(f"CRC32 added to FW at 0x00003FFC: 0x{crc_int:08X}")

# #     # Write the truncated data to a new binary file
# #     with open(output_bin, 'wb') as f:
# #         f.write(truncated_data)
    
# #     # Write CRC32 at the fixed location in the new binary file
# #     write_crc32_at_address(output_bin, output_bin, crc_bytes)

# #     # Convert binary back to HEX
# #     bin_to_hex(output_bin, output_hex)

# # if __name__ == "__main__":
# #     if len(sys.argv) != 4:
# #         print("Usage: python add_crc32_fixed.py <input.bin> <output.bin> <output.hex>")
# #         sys.exit(1)

# #     input_bin_file = sys.argv[1]
# #     output_bin_file = sys.argv[2]  # New binary file with CRC at fixed address
# #     output_hex_file = sys.argv[3]

# #     main(input_bin_file, output_bin_file, output_hex_file)

# import struct
# import zlib
# import sys

# def process_bin_file(input_file, output_file):
#     try:
#         with open(input_file, 'rb') as f:
#             # Read the entire file content
#             content = f.read()
            
#             # Create a new bytearray from the original content
#             new_content = bytearray(content)
            
#             # Pad the file to 16384 bytes if needed
#             current_size = len(new_content)
#             if current_size < 16384:
#                 padding_size = 16384 - current_size
#                 new_content.extend(bytes(padding_size))
#                 print(f"File padded from {current_size} to 16384 bytes")
#             elif current_size > 16384:
#                 print(f"Warning: File is larger than 16384 bytes ({current_size} bytes)")
            
#             # Check if the file is large enough to read from offset 0x000003FC0
#             if len(new_content) <= 0x000003FC0 + 4:
#                 print(f"Error: Input file is too small even after padding. File size: {len(new_content)} bytes")
#                 sys.exit(1)
                
#             # Extract the 4-byte value at 0x000003FC0
#             end_of_text = struct.unpack('<I', new_content[0x000003FC0:0x000003FC0+4])[0]
            
#             # Round up to the nearest multiple of 64
#             rounded_end = ((end_of_text + 63) // 64) * 64
            
#             # Compute CRC32 of the file from start to rounded_end
#             crc32 = zlib.crc32(new_content[:rounded_end]) & 0xFFFFFFFF
            
#             # Store the CRC32 at location 0x00003FFC
#             struct.pack_into('<I', new_content, 0x00003FFC, crc32)
            
#         # Write the modified content to the output file
#         with open(output_file, 'wb') as f:
#             f.write(new_content)
        
#         print(f"Processing complete. Output saved to {output_file}")
#         print(f"End of text value: 0x{end_of_text:08X}")
#         print(f"Rounded end: 0x{rounded_end:08X}")
#         print(f"Computed CRC32: 0x{crc32:08X}")
    
#     except FileNotFoundError:
#         print(f"Error: Input file '{input_file}' not found.")
#         sys.exit(1)
#     except Exception as e:
#         print(f"Error: {str(e)}")
#         sys.exit(1)

# if __name__ == "__main__":
#     # Check if correct number of arguments are provided
#     if len(sys.argv) != 3:
#         print("Usage: python script.py <input_bin_file> <output_bin_file>")
#         sys.exit(1)
    
#     input_file = sys.argv[1]
#     output_file = sys.argv[2]
    
#     process_bin_file(input_file, output_file)


import struct
import zlib
import sys

def process_bin_file(input_file, output_file):
    try:
        with open(input_file, 'rb') as f:
            # Read the entire file content
            content = f.read()
            
            # Create a new bytearray from the original content
            new_content = bytearray(content)
            
            # Pad the file to 16384 bytes if needed
            current_size = len(new_content)
            if current_size < 16384:
                padding_size = 16384 - current_size
                new_content.extend(bytes(padding_size))
                print(f"File padded from {current_size} to 16384 bytes")
            elif current_size > 16384:
                print(f"Warning: File is larger than 16384 bytes ({current_size} bytes)")
            
            # Check if the file is large enough to read from offset 0x000003FC0
            if len(new_content) <= 0x000003FC0 + 4:
                print(f"Error: Input file is too small even after padding. File size: {len(new_content)} bytes")
                sys.exit(1)
                
            # Extract the 4-byte value at 0x000003FC0
            end_of_text = struct.unpack('<I', new_content[0x000003FC0:0x000003FC0+4])[0]
            
            # Save the 8-byte values at location 0x00003FC4
            preserved_bytes = bytes(new_content[0x00003FC4:0x00003FC4+8])
            
            # Round up to the nearest multiple of 64
            rounded_end = ((end_of_text + 63) // 64) * 64
            
            # Compute CRC32 of the file from start to rounded_end
            crc32 = zlib.crc32(new_content[:rounded_end]) & 0xFFFFFFFF
            
            # Restore the 8-byte values at location 0x00003FC4
            for i in range(8):
                new_content[0x00003FC4 + i] = preserved_bytes[i]
                
            # Store the CRC32 at location 0x00003FFC
            struct.pack_into('<I', new_content, 0x00003FFC, crc32)
            
        # Write the modified content to the output file
        with open(output_file, 'wb') as f:
            f.write(new_content)
        
        print(f"Processing complete. Output saved to {output_file}")
        print(f"End of text value: 0x{end_of_text:08X}")
        print(f"Rounded end: 0x{rounded_end:08X}")
        print(f"Preserved 8 bytes at 0x00003FC4: {preserved_bytes.hex()}")
        print(f"Computed CRC32: 0x{crc32:08X}")
    
    except FileNotFoundError:
        print(f"Error: Input file '{input_file}' not found.")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    # Check if correct number of arguments are provided
    if len(sys.argv) != 3:
        print("Usage: python script.py <input_bin_file> <output_bin_file>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    process_bin_file(input_file, output_file)
