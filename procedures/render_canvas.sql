CREATE OR REPLACE FUNCTION render_canvas_to_png()
    RETURNS bytea AS
$$
    import io
    from PIL import Image

    # Get canvas data
    plan = plpy.prepare("SELECT x, y, r, g, b FROM canvas ORDER BY y ASC, x ASC")
    result = plpy.execute(plan)

    if len(result) == 0:
        return None

    # Determine image dimensions
    max_x = max(row['x'] for row in result)
    max_y = max(row['y'] for row in result)

    # Create a new image with determined dimensions or use default if empty
    width = max_x
    height = max_y
    img = Image.new('RGB', (width, height), color=(0, 0, 0))
    pixels = img.load()

    # Set pixels based on canvas data
    for row in result:
        x = row['x'] - 1
        y = row['y'] - 1
        r = row['r']
        g = row['g']
        b = row['b']
        pixels[x, y] = (r, g, b)

    # Save to PNG
    buffer = io.BytesIO()
    img.save(buffer, format='PNG')
    buffer.seek(0)
    return buffer.getvalue()
$$ LANGUAGE plpython3u;
