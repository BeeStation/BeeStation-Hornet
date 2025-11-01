import re
import glob
from colormath.color_objects import sRGBColor, HSLColor
from colormath.color_conversions import convert_color

def hex_to_hsl(hex_color):
    try:
        alpha_percent = None
        if len(hex_color) == 4 or len(hex_color) == 5:  # Shorthand formats expansion
            hex_color = '#' + ''.join([c * 2 for c in hex_color[1:]])
        if len(hex_color) == 9:  # Includes '#' and alpha
            alphahex = hex_color[-2:]
            alpha_percent = (int(alphahex, 16) / 255) * 100
        rgb = sRGBColor.new_from_rgb_hex(hex_color)
        hsl = convert_color(rgb, HSLColor)
        if alpha_percent is not None:
            return f"hsla({hsl.hsl_h:.1f}, {hsl.hsl_s * 100:.1f}%, {hsl.hsl_l * 100:.1f}%, {alpha_percent:.1f})"
        return f"hsl({hsl.hsl_h:.1f}, {hsl.hsl_s * 100:.1f}%, {hsl.hsl_l * 100:.1f}%)"
    except Exception as e:
        print(f"  [!] Failed to convert color '{hex_color}': {e}")
        return hex_color  # Leave unchanged if error

def replace_hex_with_hsl(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            content = file.read()
    except Exception as e:
        print(f"[!] Skipping '{file_path}' (read error: {e})")
        return

    try:
        hex_pattern = re.compile(r'#([0-9a-fA-F]{3,8})')
        updated_content = hex_pattern.sub(lambda match: hex_to_hsl(match.group(0)), content)
        with open(file_path, 'w', encoding='utf-8') as file:
            file.write(updated_content)
        print(f"[+] Processed: {file_path}")
    except Exception as e:
        print(f"[!] Skipping '{file_path}' (processing error: {e})")

def process_all_scss_files():
    scss_files = glob.glob('*.scss')
    print(f"Found {len(scss_files)} SCSS files.")
    for scss_file in scss_files:
        try:
            replace_hex_with_hsl(scss_file)
        except Exception as e:
            print(f"[!] Skipping '{scss_file}' (unexpected error: {e})")

if __name__ == "__main__":
    process_all_scss_files()
