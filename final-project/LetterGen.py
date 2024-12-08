from PIL import Image, ImageDraw, ImageFont
from string import ascii_uppercase
def get_binary_representation(char, width=8, height=16, font_size=10):
    # Create a blank image with white background
    image = Image.new("1", (width, height), 1)
    draw = ImageDraw.Draw(image)

    # Load a default font; alternatively, you can specify a font path
    # font = ImageFont.truetype('/Users/yoketh/Library/Fonts/Andale Mono.ttf', 12)
    font = ImageFont.load_default(font_size)
    
    # Calculate the bounding box and center the character
    bbox = font.getbbox(char)
    text_x = (width - (bbox[2] - bbox[0])) // 2
    text_y = (height - (bbox[3] - bbox[1])) // 2

    # Draw the character onto the image
    draw.text((text_x, text_y), char, font=font, fill=0)
    image.show()

    # Convert image to binary representation
    binary_representation = []
    for y in range(height):
        row = []
        for x in range(width):
            # Append 1 for filled pixels and 0 for empty ones
            row.append(0 if image.getpixel((x, y)) else 1)
        binary_representation.append(row)
    
    return binary_representation

# Display binary pattern for character "A"
# for a in ascii_uppercase:
binary_pattern = get_binary_representation('a',12,24,16)
for row in binary_pattern:
    print("".join(str(pixel) for pixel in row))
