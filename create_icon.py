# Create a simple icon using Python and PIL
# Install: pip install pillow

from PIL import Image, ImageDraw

def create_iptv_casper_icon(size=512):
    """Create a simple IPTV Casper icon"""
    # Create image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Define colors
    blue = (33, 150, 243, 255)
    purple = (156, 39, 176, 255)
    white = (255, 255, 255, 255)
    
    # Create gradient background (simplified as two-tone)
    for y in range(size):
        ratio = y / size
        r = int(blue[0] * (1 - ratio) + purple[0] * ratio)
        g = int(blue[1] * (1 - ratio) + purple[1] * ratio)
        b = int(blue[2] * (1 - ratio) + purple[2] * ratio)
        draw.rectangle([(0, y), (size, y+1)], fill=(r, g, b, 255))
    
    # Add rounded corners
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([(0, 0), (size, size)], radius=size//5, fill=255)
    img.putalpha(mask)
    
    # Draw TV screen outline
    margin = size // 6
    screen_left = margin
    screen_top = margin + size // 10
    screen_right = size - margin
    screen_bottom = size - margin - size // 10
    screen_width = size // 20
    
    draw.rounded_rectangle(
        [(screen_left, screen_top), (screen_right, screen_bottom)],
        radius=size // 15,
        outline=white,
        width=screen_width
    )
    
    # Draw play button (triangle)
    play_size = size // 3
    play_center_x = size // 2
    play_center_y = size // 2
    
    play_points = [
        (play_center_x - play_size // 3, play_center_y - play_size // 2),
        (play_center_x - play_size // 3, play_center_y + play_size // 2),
        (play_center_x + play_size // 2, play_center_y)
    ]
    draw.polygon(play_points, fill=white)
    
    # Draw signal waves (simplified)
    wave_x = size - margin - size // 8
    wave_y = margin + size // 8
    wave_size = size // 10
    
    for i in range(3):
        draw.arc(
            [(wave_x - wave_size * (i+1), wave_y - wave_size * (i+1)),
             (wave_x + wave_size * (i+1), wave_y + wave_size * (i+1))],
            start=180, end=270,
            fill=(255, 255, 255, 180 - i * 40),
            width=size // 40
        )
    
    return img

def create_icon_set():
    """Create icons in various sizes"""
    sizes = [16, 32, 48, 64, 128, 256, 512, 1024]
    
    print("Creating IPTV Casper icons...")
    
    for size in sizes:
        icon = create_iptv_casper_icon(size)
        filename = f"app_icon_{size}.png"
        icon.save(filename, 'PNG')
        print(f"✓ Created {filename}")
    
    # Create master icon
    master = create_iptv_casper_icon(1024)
    master.save("app_icon.png", 'PNG')
    print(f"✓ Created app_icon.png (master)")
    
    print("\nIcons created successfully!")
    print("Place 'app_icon.png' in assets/images/ folder")
    print("Then run: flutter pub run flutter_launcher_icons")

if __name__ == "__main__":
    create_icon_set()
