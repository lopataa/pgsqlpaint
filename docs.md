# Draw in PL/pgSQL Documentation

## Tables

### canvas

This is the only table in the database. It has five columns:

- `x` (integer, primary key): X coordinate of the pixel
- `y` (integer, primary key): Y coordinate of the pixel
- `r` (integer): Red value (0-255)
- `g` (integer): Green value (0-255)
- `b` (integer): Blue value (0-255)

The table is used to store the color of each pixel on the canvas. The size of the canvas is determined by taking the
maximum
x and y values from the table. The canvas is initialized with a single black pixel at (800, 600) when the database is
created. If a pixel is unset, it is considered to be black (0, 0, 0).

## Pixel Operations

### set\_pixel

Sets or updates the color of a single pixel at (x, y) on the canvas.

- Parameters:
    - `p_x` (integer): X coordinate
    - `p_y` (integer): Y coordinate
    - `p_r` (integer, default 255): Red value
    - `p_g` (integer, default 255): Green value
    - `p_b` (integer, default 255): Blue value

If a pixel exists at (x, y), its color is updated; otherwise, a new pixel is inserted.

### unset\_pixel

Removes a pixel at (x, y) from the canvas.

- Parameters:
    - `p_x` (integer): X coordinate
    - `p_y` (integer): Y coordinate

Deletes the pixel at the specified location.

### set\_radius

Sets all pixels within a given radius around (x, y) to a specified color.

- Parameters:
    - `p_x`, `p_y` (integer): Center coordinates
    - `p_r`, `p_g`, `p_b` (integer, default 255): Color values
    - `radius` (integer, default 0): Radius in pixels

Updates all pixels within the radius using the `set_pixel` procedure.

### unset\_radius

Removes all pixels within a given radius around (x, y).

- Parameters:
    - `p_x`, `p_y` (integer): Center coordinates
    - `radius` (integer, default 0): Radius in pixels

Deletes all pixels within the specified radius using `unset_pixel`.

### get\_pixel

Retrieves the RGB color of a pixel at (x, y).

- Parameters:
    - `p_x` (integer): X coordinate
    - `p_y` (integer): Y coordinate
- Returns:
    - `r`, `g`, `b` (integer): Color values (defaults to 0 if pixel not found)

Returns the color of the specified pixel, or black if unset.

### move

Moves and optionally resizes a rectangular region within the canvas, copying pixels from a source rectangle to a target
rectangle using nearest-neighbor scaling.

- Parameters:

    - `p_x1`, `p_y1`: Top-left coordinates of the source rectangle
    - `p_x2`, `p_y2`: Bottom-right coordinates of the source rectangle
    - `p_x_to`, `p_y_to`: Top-left coordinates of the target rectangle
    - `p_x_to2`, `p_y_to2`: Bottom-right coordinates of the target rectangle

### clear\_canvas

Clears the entire canvas and resets it to a single black pixel at the specified bottom-right coordinate.

- Parameters:
    - `width` _(default 800)_: Width of the canvas
    - `height` _(default 600)_

## Drawing Primitives

### draw\_line

Draws a line from (x1, y1) to (x2, y2) with specified color, width, and style.

- Parameters:
    - `x1`, `y1`, `x2`, `y2` (integer): Endpoints
    - `r`, `g`, `b` (integer, default 255): Color
    - `stroke_width` (integer, default 1): Line thickness
    - `style` (varchar, default 'Solid'): 'Solid', 'Dashed', or 'Dotted'

Supports solid, dashed, and dotted lines with adjustable width.

### draw\_rect

Draws a rectangle by connecting four sides between (x1, y1) and (x2, y2).

- Parameters:
    - `x1`, `y1`, `x2`, `y2` (integer): Opposite corners
    - `r`, `g`, `b` (integer, default 255): Color
    - `stroke_width` (integer, default 1): Border thickness
    - `style` (varchar, default 'Solid'): Border style

Uses `draw_line` to render each side of the rectangle.

### draw\_circle

Draws a circle centered at (center\_x, center\_y) with a given radius.

- Parameters:
    - `center_x`, `center_y` (integer): Center coordinates
    - `radius` (integer): Circle radius
    - `color_r`, `color_g`, `color_b` (integer, default 255): Color
    - `stroke_width` (integer, default 0): Border thickness
    - `style` (varchar, default 'Solid'): 'Solid', 'Dashed', or 'Dotted'

Supports different border styles and thicknesses.

### fill

Fills a contiguous region starting from (p\_x, p\_y) with a specified color.

- Parameters:
    - `p_x`, `p_y` (integer): Starting point
    - `r`, `g`, `b` (integer, default 255): Fill color

Implements a flood-fill algorithm to recolor connected areas of the same color.

## Text Rendering

### text

Renders a text string onto the canvas at (p\_x, p\_y) with specified font and color.

- Parameters:
    - `what` (text): The string to render
    - `p_x`, `p_y` (integer): Top-left text position
    - `font` (text, default 'Comic Sans MS'): Font name
    - `font_style` (text, default 'regular'): Font style
    - `font_size` (integer, default 12): Font size
    - `p_r`, `p_g`, `p_b` (integer, default 255): Text color

Draws text using the PIL library and updates only the affected pixels on the canvas. I'm using a third-party library
just because this is an additional thing, that wasn't a requirement.

## Rendering functions

### render_canvas_to_png

Renders the current canvas as a PNG image and returns the image as a bytea object. I'm using a third-party library
because of the speed benefit, but you can use the `render_canvas_to_bmp` function if you want to avoid it.

### render_canvas_to_bmp

Renders the current canvas as a BMP image and returns the image as a bytea object. This function is written fully in
SQL, because of the simplicity of the BMP format. It is about 2x slower than the PNG version, but it doesn't require any
third-party libraries.