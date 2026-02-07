#!/usr/bin/env python3
"""Generate Neon Pente app icon at multiple sizes."""

import math
from PIL import Image, ImageDraw, ImageFilter, ImageFont

# Neon colors from neon_theme.dart
DARK_BG = (10, 10, 15)        # 0x0A0A0F
DARKER_BG = (5, 5, 8)         # 0x050508
BOARD_BG = (14, 14, 22)       # dark board
NEON_CYAN = (0, 229, 255)     # 0x00E5FF
NEON_MAGENTA = (255, 0, 255)  # 0xFF00FF
PLAYER2 = (255, 128, 255)     # 0xFF80FF
GRID_COLOR = (0, 229, 255, 35)  # cyan with low alpha


def lerp_color(c1, c2, t):
    """Linearly interpolate between two RGB colors."""
    return tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(3))


def draw_glow_circle(draw, cx, cy, radius, color, glow_radius, img):
    """Draw a glowing circle by layering multiple translucent circles."""
    # We'll create a separate image for the glow, blur it, and composite
    glow_img = Image.new('RGBA', img.size, (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow_img)

    # Outer glow layers
    for i in range(3):
        r = radius + glow_radius * (1 + i * 0.8)
        alpha = int(60 / (i + 1))
        glow_draw.ellipse(
            [cx - r, cy - r, cx + r, cy + r],
            fill=(*color, alpha)
        )

    # Blur the glow
    glow_img = glow_img.filter(ImageFilter.GaussianBlur(radius=glow_radius * 0.7))
    img.paste(Image.alpha_composite(
        Image.new('RGBA', img.size, (0, 0, 0, 0)), glow_img
    ), (0, 0), glow_img)


def draw_stone(img, draw, cx, cy, radius, color, glow_color):
    """Draw a neon-glowing stone."""
    # Draw glow
    draw_glow_circle(draw, cx, cy, radius, glow_color, radius * 0.7, img)

    # Main stone body with radial gradient (simulate with concentric circles)
    steps = max(int(radius), 10)
    for i in range(steps, 0, -1):
        t = i / steps
        r = radius * t
        # Gradient from bright center to colored edge
        center_color = (255, 255, 255)
        factor = t ** 0.6
        c = lerp_color(center_color, color, factor)
        alpha = int(200 + 55 * (1 - t))
        draw.ellipse(
            [cx - r, cy - r, cx + r, cy + r],
            fill=(*c, alpha)
        )


def generate_icon(size):
    """Generate the Neon Pente icon at the given pixel size."""
    img = Image.new('RGBA', (size, size), (*DARK_BG, 255))
    draw = ImageDraw.Draw(img)

    # Board area (with slight padding)
    padding = size * 0.06
    board_size = size - 2 * padding

    # Draw rounded background
    corner_r = size * 0.15
    draw.rounded_rectangle(
        [0, 0, size - 1, size - 1],
        radius=corner_r,
        fill=(*DARKER_BG, 255),
    )

    # Draw a subtle board area
    bp = size * 0.1
    draw.rounded_rectangle(
        [bp, bp, size - bp, size - bp],
        radius=corner_r * 0.6,
        fill=(*BOARD_BG, 255),
    )

    # Grid: 7x7 visible intersections in the center area
    grid_cells = 6  # 7 lines = 6 cells
    grid_margin = size * 0.16
    grid_size = size - 2 * grid_margin
    cell_size = grid_size / grid_cells

    # Draw grid lines
    line_color = (0, 229, 255, 30)
    for i in range(7):
        x = grid_margin + i * cell_size
        y = grid_margin + i * cell_size
        # Vertical line
        draw.line([(x, grid_margin), (x, size - grid_margin)],
                  fill=line_color, width=max(1, size // 200))
        # Horizontal line
        draw.line([(grid_margin, y), (size - grid_margin, y)],
                  fill=line_color, width=max(1, size // 200))

    # Center star point
    cx = size / 2
    cy = size / 2
    sp_r = max(2, size * 0.012)
    draw.ellipse([cx - sp_r, cy - sp_r, cx + sp_r, cy + sp_r],
                 fill=(0, 229, 255, 80))

    # Stone radius relative to icon size
    stone_r = cell_size * 0.38

    # Define stone positions based on the reference image pattern (simplified)
    # Using grid coordinates (0-6, 0-6) where (3,3) is center
    # Cyan stones (player 1 - replacing white in reference)
    cyan_stones = [
        (3, 1),  # center column, upper
        (2, 2),  # upper area
        (4, 2),
        (3, 3),  # center
        (4, 3),
        (2, 4),
        (3, 4),
        (4, 4),
        (3, 5),  # center column, lower
    ]

    # Magenta stones (player 2 - replacing black in reference)
    magenta_stones = [
        (2, 1),
        (5, 1),
        (1, 2),
        (5, 2),
        (2, 3),
        (5, 3),
        (1, 4),
        (5, 4),
        (4, 5),
        (5, 5),
    ]

    # Convert grid coords to pixel positions
    def grid_to_px(gx, gy):
        px = grid_margin + gx * cell_size
        py = grid_margin + gy * cell_size
        return px, py

    # Draw magenta stones first (they're "behind" in some positions)
    for gx, gy in magenta_stones:
        px, py = grid_to_px(gx, gy)
        draw_stone(img, ImageDraw.Draw(img), px, py, stone_r,
                   PLAYER2, NEON_MAGENTA)

    # Draw cyan stones on top
    for gx, gy in cyan_stones:
        px, py = grid_to_px(gx, gy)
        draw_stone(img, ImageDraw.Draw(img), px, py, stone_r,
                   NEON_CYAN, NEON_CYAN)

    # Draw subtle border glow
    border_img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    border_draw = ImageDraw.Draw(border_img)
    border_draw.rounded_rectangle(
        [1, 1, size - 2, size - 2],
        radius=corner_r,
        outline=(*NEON_CYAN, 40),
        width=max(1, size // 150),
    )
    border_img = border_img.filter(ImageFilter.GaussianBlur(radius=max(1, size // 100)))
    img = Image.alpha_composite(img, border_img)

    # Add a sharper inner border
    final_draw = ImageDraw.Draw(img)
    final_draw.rounded_rectangle(
        [1, 1, size - 2, size - 2],
        radius=corner_r,
        outline=(*NEON_CYAN, 60),
        width=max(1, size // 256),
    )

    return img


def generate_adaptive_foreground(size):
    """Generate Android adaptive icon foreground (108dp with 72dp safe zone)."""
    # Adaptive icons use 108x108 grid, the icon itself should be in the center 72x72
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))

    # The content should be in the center 66.7% (72/108)
    inner_size = int(size * 72 / 108)
    offset = (size - inner_size) // 2

    # Generate the icon at the inner size
    icon = generate_icon(inner_size)
    img.paste(icon, (offset, offset), icon)

    return img


def main():
    import os

    base_dir = '/home/user/Pente'

    # ── Android mipmap icons ──────────────────────────────────────────
    android_res = os.path.join(base_dir, 'android/app/src/main/res')

    # Standard launcher icon sizes
    mipmap_sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
    }

    for folder, sz in mipmap_sizes.items():
        path = os.path.join(android_res, folder)
        os.makedirs(path, exist_ok=True)

        # Standard icon
        icon = generate_icon(sz)
        icon.save(os.path.join(path, 'ic_launcher.png'))

        # Round icon (same for now, Android clips to circle)
        icon.save(os.path.join(path, 'ic_launcher_round.png'))
        print(f'  {folder}/ic_launcher.png ({sz}x{sz})')

    # Adaptive icon foreground
    adaptive_sizes = {
        'mipmap-mdpi': 108,
        'mipmap-hdpi': 162,
        'mipmap-xhdpi': 216,
        'mipmap-xxhdpi': 324,
        'mipmap-xxxhdpi': 432,
    }

    for folder, sz in adaptive_sizes.items():
        path = os.path.join(android_res, folder)
        fg = generate_adaptive_foreground(sz)
        fg.save(os.path.join(path, 'ic_launcher_foreground.png'))
        print(f'  {folder}/ic_launcher_foreground.png ({sz}x{sz})')

    # Adaptive icon background (solid dark color)
    drawable_dir = os.path.join(android_res, 'drawable')
    os.makedirs(drawable_dir, exist_ok=True)

    # ── Linux desktop icon ────────────────────────────────────────────
    assets_dir = os.path.join(base_dir, 'assets')
    os.makedirs(assets_dir, exist_ok=True)

    for sz in [64, 128, 256, 512]:
        icon = generate_icon(sz)
        icon.save(os.path.join(assets_dir, f'icon_{sz}.png'))
        print(f'  assets/icon_{sz}.png ({sz}x{sz})')

    # ── Web icons ─────────────────────────────────────────────────────
    web_dir = os.path.join(base_dir, 'web')
    os.makedirs(web_dir, exist_ok=True)

    # favicon.png (192x192)
    icon192 = generate_icon(192)
    icon192.save(os.path.join(web_dir, 'favicon.png'))
    print(f'  web/favicon.png (192x192)')

    # Icon-192 and Icon-512 for PWA
    icon192.save(os.path.join(web_dir, 'icons', 'Icon-192.png')
                 if os.path.exists(os.path.join(web_dir, 'icons'))
                 else os.path.join(web_dir, 'Icon-192.png'))
    icon512 = generate_icon(512)
    icon512.save(os.path.join(web_dir, 'Icon-512.png'))
    print(f'  web/Icon-192.png, web/Icon-512.png')

    # Also save a maskable icon for PWA
    icon_maskable = generate_icon(512)
    icon_maskable.save(os.path.join(web_dir, 'Icon-maskable-512.png'))

    print('\nAll icons generated successfully!')


if __name__ == '__main__':
    main()
