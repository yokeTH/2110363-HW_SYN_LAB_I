from PIL import Image, ImageDraw, ImageFont
import numpy as np
import os

def generate_char_mem():
    """Generate .mem file with 8x16 character patterns, with 16x oversampling and save preview"""
    
    # Initialize image for character rendering (128x256 for 16x oversampling)
    img = Image.new('1', (8, 16), color=0)
    draw = ImageDraw.Draw(img)
    
    try:
        font = ImageFont.truetype('font.ttf', 12)
    except:
        print('Font Not Found')
        font = ImageFont.load_default()

    # Create memory file
    with open('char_rom.mem', 'w') as f:
        # Generate all ASCII characters (0-127)
        for code in range(128):
            # Clear image
            draw.rectangle((0, 0, 8, 16), fill=0)
            
            # Draw character if printable
            if 32 <= code <= 126:
                # Adjust baseline for different characters
                y_offset = -1
                if chr(code) in 'gjpqy':  # Characters with descenders
                    y_offset = -3
                    
                draw.text((0, y_offset), chr(code), font=font, fill=1)
            
            # Save the preview of the oversampled character (128x256)
            # Only use valid filename characters
            char_name = chr(code) if 32 <= code <= 126 else f"non_printable_{code}"
            filename = f"char_{char_name}_preview.png"
            
            # Sanitize the filename to avoid issues with special characters
            filename = filename.replace('/', '_').replace('\\', '_')  # Replace slashes with underscores
            # img.save('previews/original_'+filename)
            
            # Resize the image to 8x16 for final character representation
            img_resized = img.resize((8, 16), Image.Resampling.BILINEAR)
            img_resized.save('previews/small_'+filename)
            
            # Convert to bit pattern
            pixels = np.array(img_resized)
            
            # Write 16 rows for this character
            for row in pixels:
                bit_string = ''.join(['1' if p else '0' for p in row])
                hex_value = format(int(bit_string, 2), '02x')
                f.write(f"{hex_value}\n")

if __name__ == "__main__":
    generate_char_mem()
    print("Generated char_rom.mem and preview images")
