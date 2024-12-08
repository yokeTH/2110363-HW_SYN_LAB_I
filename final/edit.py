def edit_char_mem(filename):
    """
    Interactively edit a specific character's data in a .mem file.

    Args:
        filename (str): Path to the .mem file.
    """
    # Get character hexadecimal code from the user
    char_hex = input("Enter the character hex code (e.g., 41 for 'A'): ").strip()

    try:
        # Convert hex to decimal
        char_code = int(char_hex, 16)
    except ValueError:
        print("Invalid hexadecimal code. Please try again.")
        return

    # Calculate line range
    start_line = char_code * 16
    end_line = start_line + 15

    # Read the file
    try:
        with open(filename, 'r') as file:
            lines = file.readlines()
    except FileNotFoundError:
        print(f"File '{filename}' not found.")
        return

    # Ensure the file has enough lines
    if len(lines) <= end_line:
        print("The .mem file does not contain enough data for this character code.")
        return

    # Display current content for the character
    print(f"Current content for character {char_hex} (lines {start_line}-{end_line}):")
    current_content = lines[start_line:end_line + 1]
    for i, line in enumerate(current_content):
        print(f"{i}: {line.strip()}")

    # Get new content from the user
    print("\nEnter the new 16 lines of content (hexadecimal, 2 characters each):")
    new_content = []
    for i in range(16):
        while True:
            line = input(f"Line {i}: ").strip()
            if len(line) in {1, 2} and all(c in "0123456789abcdefABCDEF" for c in line):
                new_content.append(line.zfill(2).lower())
                break
            print("Invalid input. Enter exactly 2 hexadecimal characters.")

    # Confirm changes
    print("\nReview the new content:")
    for i, line in enumerate(new_content):
        print(f"{i}: {line}")
    # confirm = input("Confirm changes? (yes/no): ").strip().lower()
    # if confirm != 'yes':
    #     print("Changes canceled.")
    #     return

    # Replace the lines
    lines[start_line:end_line + 1] = [line + '\n' for line in new_content]

    # Write back to the file
    with open(filename, 'w') as file:
        file.writelines(lines)

    print(f"Character {char_hex} updated successfully.")

if __name__ == "__main__":
    filename = "char_rom.mem"  # Adjust the file path as needed
    edit_char_mem(filename)
