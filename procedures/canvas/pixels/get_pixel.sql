CREATE OR REPLACE FUNCTION get_pixel(
    IN p_x INT,
    IN p_y INT,
    OUT r INT,
    OUT g INT,
    OUT b INT
)
    LANGUAGE plpgsql
AS
$$
BEGIN
    -- Retrieve the RGB values from the canvas table for the given x and y coordinates
    SELECT coalesce(canvas.r, 0) AS r,
           coalesce(canvas.g, 0) AS g,
           coalesce(canvas.b, 0) AS b
    INTO get_pixel.r, get_pixel.g, get_pixel.b
    FROM canvas
    WHERE canvas.x = p_x
      AND canvas.y = p_y;

    -- If no pixel is found, default to black (0, 0, 0)
    IF NOT FOUND THEN
        r := 0;
        g := 0;
        b := 0;
    END IF;
END;
$$;
