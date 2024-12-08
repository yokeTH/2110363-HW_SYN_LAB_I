from PIL import Image, ImageDraw, ImageFont
from string import ascii_uppercase, ascii_lowercase, digits, punctuation

def get_binary_representation(char, width=12, height=24, font_size=16):
    # Create a blank image with white background
    image = Image.new("1", (width, height), 1)
    draw = ImageDraw.Draw(image)
    
    # Load default font
    font = ImageFont.load_default(font_size)
    
    # Calculate text position to center it
    bbox = font.getbbox(char)
    text_x = (width - (bbox[2] - bbox[0])) // 2
    text_y = (height - (bbox[3] - bbox[1])) // 2
    
    # Draw character
    draw.text((text_x, text_y), char, font=font, fill=0)
    
    # Convert to single binary string
    binary = ''
    for y in range(height):
        for x in range(width):
            binary += '1' if image.getpixel((x, y)) == 0 else '0'
    
    return binary

def create_rom_file():
    # Open file for writing
    with open('font_rom.mem', 'w') as f:
        # Write all 256 possible ASCII values (0-255)
        for i in range(256):
            # Use actual character for printable ASCII (32-126)
            if 32 <= i <= 126:
                pattern = get_binary_representation(chr(i))
            else:
                # For non-printable characters (0-31 and 127-255), use empty pattern
                pattern = '0' * (12 * 24)
            
            # Write binary pattern with address as comment
            f.write(f"{pattern} // {i:03d}: " + (f"'{chr(i)}'" if 32 <= i <= 126 else "control/extended") + "\n")

if __name__ == '__main__':
    create_rom_file()
    print("ROM file 'font_rom.mem' has been generated!")