CREATE OR REPLACE PROCEDURE get_pixel(
    IN x INT,
    IN y INT,
    OUT r INT,
    OUT g INT,
    OUT b INT
)
    LANGUAGE plpgsql
AS
$$
BEGIN
    -- Retrieve the RGB values from the canvas table for the given x and y coordinates
    SELECT canvas.r, canvas.g, canvas.b
    INTO r, g, b
    FROM canvas
    WHERE canvas.x = get_pixel.x AND canvas.y = get_pixel.y;

    -- If no pixel is found, set default values (e.g., white)
    IF NOT FOUND THEN
        r := 255;
        g := 255;
        b := 255;
    END IF;
END;
$$;
