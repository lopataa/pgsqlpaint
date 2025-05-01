CREATE OR REPLACE PROCEDURE draw_circle(
    IN center_x INT,
    IN center_y INT,
    IN radius INT,
    IN color_r INT DEFAULT 255,
    IN color_g INT DEFAULT 255,
    IN color_b INT DEFAULT 255,
    IN stroke_width INT DEFAULT 0,
    IN style VARCHAR DEFAULT 'Solid'
)
    LANGUAGE plpgsql
AS
$$
DECLARE
    x            INT := 0;
    y            INT;
    err          INT;
    -- For dash/dot pattern
    step         INT := 0;
    dash_length  INT := 8; -- Length of dash
    gap_length   INT := 4; -- Length of gap between dashes
    dot_interval INT := 4; -- Interval between dots
BEGIN
    IF stroke_width > 0 THEN
        --multiply by stroke_width
        dash_length := dash_length * stroke_width;
        gap_length := gap_length * stroke_width;
        dot_interval := dot_interval * stroke_width;
    END IF;

    -- Show the params
    IF radius <= 0 THEN
        RETURN;
    END IF;

    y := radius;
    err := 1 - radius;

    WHILE x <= y
        LOOP
            -- Style logic
            IF style = 'Solid' THEN
                CALL set_radius(center_x + x, center_y + y, color_r, color_g, color_b, stroke_width);
                CALL set_radius(center_x - x, center_y + y, color_r, color_g, color_b, stroke_width);
                CALL set_radius(center_x + x, center_y - y, color_r, color_g, color_b, stroke_width);
                CALL set_radius(center_x - x, center_y - y, color_r, color_g, color_b, stroke_width);
                CALL set_radius(center_x + y, center_y + x, color_r, color_g, color_b, stroke_width);
                CALL set_radius(center_x - y, center_y + x, color_r, color_g, color_b, stroke_width);
                CALL set_radius(center_x + y, center_y - x, color_r, color_g, color_b, stroke_width);
                CALL set_radius(center_x - y, center_y - x, color_r, color_g, color_b, stroke_width);
            ELSIF style = 'Dashed' THEN
                IF (step % (dash_length + gap_length)) < dash_length THEN
                    CALL set_radius(center_x + x, center_y + y, color_r, color_g, color_b, stroke_width);
                    CALL set_radius(center_x - x, center_y + y, color_r, color_g, color_b, stroke_width);
                    CALL set_radius(center_x + x, center_y - y, color_r, color_g, color_b, stroke_width);
                    CALL set_radius(center_x - x, center_y - y, color_r, color_g, color_b, stroke_width);
                    CALL set_radius(center_x + y, center_y + x, color_r, color_g, color_b, stroke_width);
                    CALL set_radius(center_x - y, center_y + x, color_r, color_g, color_b, stroke_width);
                    CALL set_radius(center_x + y, center_y - x, color_r, color_g, color_b, stroke_width);
                    CALL set_radius(center_x - y, center_y - x, color_r, color_g, color_b, stroke_width);
                END IF;
                step := step + 1;
            ELSIF style = 'Dotted' THEN
                IF (step % dot_interval) = 0 THEN
                    CALL set_radius(center_x + x, center_y + y, color_r, color_g, color_b, stroke_width);
                    CALL set_radius(center_x - x, center_y + y, color_r, color_g, color_b, stroke_width);
                    CALL set_radius(center_x + x, center_y - y, color_r, color_g, color_b, stroke_width);
                    CALL set_radius(center_x - x, center_y - y, color_r, color_g, color_b, stroke_width);
                    CALL set_radius(center_x + y, center_y + x, color_r, color_g, color_b, stroke_width);
                    CALL set_radius(center_x - y, center_y + x, color_r, color_g, color_b, stroke_width);
                    CALL set_radius(center_x + y, center_y - x, color_r, color_g, color_b, stroke_width);
                    CALL set_radius(center_x - y, center_y - x, color_r, color_g, color_b, stroke_width);
                END IF;
                step := step + 1;
            END IF;

            -- Midpoint algorithm calculations
            IF err < 0 THEN
                err := err + 2 * x + 3;
            ELSE
                err := err + 2 * (x - y) + 5;
                y := y - 1;
            END IF;
            x := x + 1;
        END LOOP;

    NOTIFY repaint;
END;
$$;
