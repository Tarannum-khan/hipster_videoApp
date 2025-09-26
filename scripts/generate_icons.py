#!/usr/bin/env python3
"""
Simple script to generate app icons from a base design
"""

import os
from PIL import Image, ImageDraw, ImageFont
import math

def create_app_icon(size):
    """Create an app icon of the specified size"""
    # Create a new image with a gradient background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Create gradient background
    for y in range(size):
        # Calculate gradient color
        ratio = y / size
        r = int(102 + (118 - 102) * ratio)  # 667eea to 764ba2
        g = int(126 + (75 - 126) * ratio)
        b = int(234 + (162 - 234) * ratio)
        
        draw.rectangle([0, y, size, y+1], fill=(r, g, b, 255))
    
    # Add video call icon
    icon_size = int(size * 0.6)
    icon_x = (size - icon_size) // 2
    icon_y = (size - icon_size) // 2
    
    # Camera body
    body_width = int(icon_size * 0.5)
    body_height = int(icon_size * 0.375)
    body_x = icon_x + (icon_size - body_width) // 2
    body_y = icon_y + int(icon_size * 0.2)
    
    draw.rounded_rectangle(
        [body_x, body_y, body_x + body_width, body_y + body_height],
        radius=int(icon_size * 0.05),
        fill=(255, 255, 255, 230)
    )
    
    # Camera lens
    lens_radius = int(icon_size * 0.15)
    lens_x = icon_x + icon_size // 2
    lens_y = icon_y + icon_size // 2
    
    draw.ellipse(
        [lens_x - lens_radius, lens_y - lens_radius, 
         lens_x + lens_radius, lens_y + lens_radius],
        fill=(102, 126, 234, 255)
    )
    
    # Inner lens
    inner_radius = int(lens_radius * 0.75)
    draw.ellipse(
        [lens_x - inner_radius, lens_y - inner_radius,
         lens_x + inner_radius, lens_y + inner_radius],
        fill=(255, 255, 255, 200)
    )
    
    return img

def main():
    """Generate all required icon sizes"""
    sizes = [48, 72, 96, 144, 192, 512]
    
    # Create output directory
    os.makedirs('assets/images/icons', exist_ok=True)
    
    for size in sizes:
        print(f"Generating {size}x{size} icon...")
        icon = create_app_icon(size)
        icon.save(f'assets/images/icons/icon_{size}.png')
    
    print("All icons generated successfully!")

if __name__ == "__main__":
    main()








