CREATE OR REPLACE PROCEDURE draw_circle(
    IN center_x INT,
    IN center_y INT,
    IN radius INT,
    IN color_r INT DEFAULT 255,
    IN color_g INT DEFAULT 255,
    IN color_b INT DEFAULT 255
)
    LANGUAGE plpgsql
AS $$
DECLARE
    x INT := 0;
    y INT;
    err INT;
BEGIN
    IF radius <= 0 THEN
        RETURN;
    END IF;

    y := radius;
    err := 1 - radius;

    WHILE x <= y LOOP
            -- Update all 8 symmetrical points using set_pixel
            CALL set_pixel(center_x + x, center_y + y, color_r, color_g, color_b);
            CALL set_pixel(center_x - x, center_y + y, color_r, color_g, color_b);
            CALL set_pixel(center_x + x, center_y - y, color_r, color_g, color_b);
            CALL set_pixel(center_x - x, center_y - y, color_r, color_g, color_b);
            CALL set_pixel(center_x + y, center_y + x, color_r, color_g, color_b);
            CALL set_pixel(center_x - y, center_y + x, color_r, color_g, color_b);
            CALL set_pixel(center_x + y, center_y - x, color_r, color_g, color_b);
            CALL set_pixel(center_x - y, center_y - x, color_r, color_g, color_b);

            -- Midpoint algorithm calculations
            IF err < 0 THEN
                err := err + 2 * x + 3;
            ELSE
                err := err + 2 * (x - y) + 5;
                y := y - 1;
            END IF;
            x := x + 1;
        END LOOP;
END;
$$;
