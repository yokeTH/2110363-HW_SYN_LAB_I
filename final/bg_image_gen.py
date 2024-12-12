from PIL import Image
import numpy as np

def convert_image_to_memfile(input_image_path, output_mem_path, width=640, height=480):
    """
    Convert an image to a Verilog memory file with 12-bit RGB values.
    
    Args:
    - input_image_path: Path to the input image
    - output_mem_path: Path to the output .mem file
    - width: Target width (default 640)
    - height: Target height (default 480)
    """
    # Open the image
    img = Image.open(input_image_path)
    
    # Resize the image to exact dimensions
    img = img.resize((width, height), Image.LANCZOS)
    
    # Convert to RGB if not already
    img = img.convert('RGB')
    
    # Convert to numpy array
    img_array = np.array(img)
    
    # Open output file
    with open(output_mem_path, 'w') as f:
        # Iterate through pixels row by row
        for y in range(height):
            for x in range(width):
                # Get RGB values
                r, g, b = img_array[y, x]
                
                # Convert 8-bit values to 4-bit (12-bit total)
                r_4bit = r >> 4  # Divide by 16 (keep most significant 4 bits)
                g_4bit = g >> 4
                b_4bit = b >> 4
                
                # Combine into 12-bit hex value
                pixel_value = (r_4bit << 8) | (g_4bit << 4) | b_4bit
                
                # Write hex value to file
                f.write(f"{pixel_value:03X}\n")

# Example usage
if __name__ == "__main__":
    # Replace with your image path
    input_image = "big_sur.jpg"  # Must be exact 640x480 or will be resized
    output_mem = "image.mem"
    
    convert_image_to_memfile(input_image, output_mem)
    print(f"Converted {input_image} to {output_mem}")