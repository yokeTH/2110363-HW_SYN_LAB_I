# Python script to modify char_rom.mem

def modify_char_rom(input_file, output_file):
    # ASCII range for displayable characters
    start_char = 32  # Space
    end_char = 126  # ~

    # Rows per character in the original ROM
    rows_per_char = 16

    # Compute the starting and ending indices in the ROM
    start_index = start_char * rows_per_char
    end_index = (end_char + 1) * rows_per_char  # +1 to include the last character

    # Read the original ROM data
    with open(input_file, "r") as infile:
        rom_data = infile.readlines()

    # Extract the relevant portion of the ROM data
    reduced_rom_data = rom_data[start_index:end_index]

    # Write the reduced ROM data to the new file
    with open(output_file, "w") as outfile:
        outfile.writelines(reduced_rom_data)

    print(f"Reduced char_rom.mem generated: {output_file}")

if __name__ == "__main__":
    # Input and output file names
    input_mem_file = "char_rom_thai.mem"  # Original memory file
    output_mem_file = "reduced_char_rom_thai.mem"  # New reduced memory file

    # Modify the ROM file
    modify_char_rom(input_mem_file, output_mem_file)