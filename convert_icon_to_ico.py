# Icon Converter - Convert PNG to ICO for Windows Installer
# This script converts the app icon to ICO format required by Inno Setup

try:
    from PIL import Image
    import os
    
    print("Converting PNG to ICO format for installer...")
    print("")
    
    # Check if source icon exists
    icon_path = "assets/images/app_icon.png"
    if not os.path.exists(icon_path):
        print(f"ERROR: {icon_path} not found!")
        print("Please run create_icon.py first to generate the icon.")
        exit(1)
    
    # Load the source image
    img = Image.open(icon_path)
    print(f"✓ Loaded {icon_path}")
    
    # ICO format supports multiple sizes in one file
    # Windows installer typically uses: 16, 32, 48, 256
    ico_sizes = [(16, 16), (32, 32), (48, 48), (256, 256)]
    
    # Create output directory if needed
    os.makedirs("assets/images", exist_ok=True)
    
    # Save as ICO with multiple sizes
    output_path = "assets/images/app_icon.ico"
    img.save(output_path, format='ICO', sizes=ico_sizes)
    
    print(f"✓ Created {output_path}")
    print("")
    print("ICO sizes included:")
    for size in ico_sizes:
        print(f"  • {size[0]}x{size[1]} pixels")
    
    print("")
    print("✓ Icon conversion complete!")
    print("The ICO file is ready for use in the installer.")
    
except ImportError:
    print("ERROR: Pillow library not found!")
    print("Install it with: pip install pillow")
    exit(1)
except Exception as e:
    print(f"ERROR: {str(e)}")
    exit(1)
