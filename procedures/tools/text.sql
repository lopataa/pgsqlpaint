CREATE OR REPLACE PROCEDURE text(
    IN what TEXT,
    IN p_x INT,
    IN p_y INT,
    IN font TEXT DEFAULT 'Comic Sans MS',
    IN font_style TEXT DEFAULT 'regular',
    IN font_size INT DEFAULT 12,
    IN p_r INT DEFAULT 255,
    IN p_g INT DEFAULT 255,
    IN p_b INT DEFAULT 255
)
    LANGUAGE plpython3u
AS
$$
import io
from PIL import Image, ImageFont, ImageDraw

# Get canvas data
canvas_plan = plpy.prepare("SELECT x, y, r, g, b FROM canvas ORDER BY y ASC, x ASC")
canvas_result = plpy.execute(canvas_plan)

# Determine current max dimensions or default to 0 for empty canvas
max_x = max(row['x'] for row in canvas_result) if canvas_result else 0
max_y = max(row['y'] for row in canvas_result) if canvas_result else 0

# Load font and calculate text dimensions
font_path = f"/usr/share/fonts/truetype/{font}.ttf"
try:
    loaded_font = ImageFont.truetype(font_path, font_size)
except IOError:
    plpy.error(f"Font {font} not found or invalid size")

# Calculate text bounding box
dummy_img = Image.new('RGB', (1, 1))
dummy_draw = ImageDraw.Draw(dummy_img)
text_bbox = dummy_draw.textbbox((p_x, p_y), what, font=loaded_font)
required_width = max(max_x, text_bbox[2])  # right edge
required_height = max(max_y, text_bbox[3]) # bottom edge

# Create base image
img = Image.new('RGB', (required_width, required_height), (0, 0, 0))
draw = ImageDraw.Draw(img)

# Draw existing pixels
for row in canvas_result:
    x = row['x'] - 1
    y = row['y'] - 1
    if x < img.width and y < img.height:
        img.putpixel((x, y), (row['r'], row['g'], row['b']))

# Draw new text
draw.text((p_x, p_y), what, font=loaded_font, fill=(p_r, p_g, p_b))

# Create text mask
mask = Image.new('L', img.size, 0)
mask_draw = ImageDraw.Draw(mask)
mask_draw.text((p_x, p_y), what, font=loaded_font, fill=255)

# Update canvas only for changed pixels
for x in range(text_bbox[0], text_bbox[2]):
    for y in range(text_bbox[1], text_bbox[3]):
        if mask.getpixel((x, y)) > 128:  # Text pixel threshold
            r, g, b = img.getpixel((x, y))
            set_pixel_plan = plpy.prepare("CALL set_pixel($1, $2, $3, $4, $5)", ["int", "int", "int", "int", "int"])
            plpy.execute(set_pixel_plan, [x+1, y+1, r, g, b])
$$;
