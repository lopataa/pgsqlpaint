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

-- Helper function to convert integers to little-endian bytea
CREATE OR REPLACE FUNCTION get_bytea(value integer, bytes int = 4)
    RETURNS bytea AS $$
DECLARE
    hex_str text := '';
BEGIN
    FOR i IN 0..bytes-1 LOOP
            hex_str := hex_str || lpad(to_hex((value >> (i*8)) & 255), 2, '0');
        END LOOP;
    RETURN decode(hex_str, 'hex');
END;
$$ LANGUAGE plpgsql;

-- Helper function for single byte conversion
CREATE OR REPLACE FUNCTION get_byte(value integer)
    RETURNS bytea AS $$
BEGIN
    RETURN decode(lpad(to_hex(value & 255), 2, '0'), 'hex');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION render_canvas_to_bmp(OUT result bytea)
    LANGUAGE plpgsql
AS $$
DECLARE
    _width integer;
    _height integer;
    _file_size integer;
    bmp_header bytea;
    dib_header bytea;
    pixel_data bytea := '';
    pixel_row record;
BEGIN
    -- Get canvas dimensions
    SELECT COALESCE(MAX(x), 0), COALESCE(MAX(y), 0)
    INTO _width, _height FROM canvas;

    -- Calculate BMP file size
    _file_size := 138 + (_width * _height * 4);

    -- Construct BMP header
    bmp_header :=
            E'\\x424D' ||  -- BM signature
            get_bytea(_file_size, 4) ||
            E'\\x00000000' ||  -- Reserved
            E'\\x8A000000';    -- Pixel data offset (122 bytes)

    -- Construct DIB header (BITMAPV4HEADER)
    dib_header :=
            E'\\x7C000000' ||          -- Header size
            get_bytea(_width, 4) ||       -- Image width
            get_bytea(_height, 4) ||      -- Image height
            E'\\x0100' ||                 -- Planes
            E'\\x2000' ||                 -- 32bpp
            E'\\x03000000' ||             -- BI_BITFIELDS compression
            get_bytea(_width * _height * 4, 4) || -- Image size
            E'\\x130B0000' ||             -- Horizontal resolution (2835 dpi)
            E'\\x130B0000' ||             -- Vertical resolution
            E'\\x00000000' ||             -- Palette colors
            E'\\x00000000' ||             -- Important colors
            E'\\x0000FF00' ||             -- Red mask
            E'\\x00FF0000' ||             -- Green mask
            E'\\xFF000000' ||             -- Blue mask
            E'\\x000000FF' ||             -- Alpha mask
            E'\\x42475273' ||             -- Color space (Win )
            E'\\x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000';

    -- Generate pixel data
    pixel_data := (
        SELECT string_agg(
                       CHR(get_byte(b)) ||
                       CHR(get_byte(g)) ||
                       CHR(get_byte(r)) ||
                       '\xff'::bytea,
                       '' ORDER BY y DESC, x ASC
               )
        FROM canvas
    );

    -- Combine all components
    result := bmp_header || dib_header || pixel_data;
END;
$$;
