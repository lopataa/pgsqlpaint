CREATE OR REPLACE PROCEDURE draw_line(
    IN x1 INT,
    IN y1 INT,
    IN x2 INT,
    IN y2 INT,
    IN r INT DEFAULT 255,
    IN g INT DEFAULT 255,
    IN b INT DEFAULT 255,
    IN stroke_width INT DEFAULT 1,
    IN style varchar DEFAULT 'Solid'
)
    LANGUAGE plpgsql
AS
$$
DECLARE
    dx INT;
    dy INT;
    k FLOAT;
    q FLOAT;
    temp INT;
    -- For dash/dot pattern
    step INT := 0;
    dash_length INT := 8;  -- Length of dash
    gap_length INT := 4;   -- Length of gap between dashes
    dot_interval INT := 4; -- Interval between dots
BEGIN
    IF stroke_width > 0 THEN
    --multiply by stroke_width
        dash_length := dash_length * stroke_width;
        gap_length := gap_length * stroke_width;
        dot_interval := dot_interval * stroke_width;
    END IF;

    -- Show the params
    RAISE NOTICE 'x1: %, y1: %, x2: %, y2: %, r: %, g: %, b: %, style: %', x1, y1, x2, y2, r, g, b, style;

    -- Handle vertical line case (dx == 0)
    IF x1 = x2 THEN
        -- Ensure y1 <= y2 for the loop
        IF y1 > y2 THEN
            temp := y1;
            y1 := y2;
            y2 := temp;
        END IF;

        FOR y IN y1..y2 LOOP
                -- Style logic
                IF style = 'Solid' THEN
                    CALL set_radius(x1, y, r, g, b, stroke_width);
                ELSIF style = 'Dashed' THEN
                    IF (step % (dash_length + gap_length)) < dash_length THEN
                        CALL set_radius(x1, y, r, g, b, stroke_width);
                    END IF;
                    step := step + 1;
                ELSIF style = 'Dotted' THEN
                    IF (step % dot_interval) = 0 THEN
                        CALL set_radius(x1, y, r, g, b, stroke_width);
                    END IF;
                    step := step + 1;
                END IF;
            END LOOP;

        NOTIFY repaint;
        RETURN; -- Early exit for vertical lines
    END IF;

    -- Calculate slope and y-intercept
    dx := x2 - x1;
    dy := y2 - y1;
    k := dy::FLOAT / dx::FLOAT;
    q := y1 - (k * x1);

    -- For gentle slopes (|k| < 1), iterate over x
    IF ABS(k) < 1 THEN
        -- Ensure x1 <= x2 for the loop
        IF x1 > x2 THEN
            temp := x1;
            x1 := x2;
            x2 := temp;
            temp := y1;
            y1 := y2;
            y2 := temp;
        END IF;

        FOR x IN x1..x2 LOOP
                IF style = 'Solid' THEN
                    CALL set_radius(x, ROUND(k * x + q)::INTEGER, r, g, b, stroke_width);
                ELSIF style = 'Dashed' THEN
                    IF (step % (dash_length + gap_length)) < dash_length THEN
                        CALL set_radius(x, ROUND(k * x + q)::INTEGER, r, g, b, stroke_width);
                    END IF;
                    step := step + 1;
                ELSIF style = 'Dotted' THEN
                    IF (step % dot_interval) = 0 THEN
                        CALL set_radius(x, ROUND(k * x + q)::INTEGER, r, g, b, stroke_width);
                    END IF;
                    step := step + 1;
                END IF;
            END LOOP;

        -- For steep slopes (|k| >= 1), iterate over y
    ELSE
        -- Ensure y1 <= y2 for the loop
        IF y1 > y2 THEN
            temp := y1;
            y1 := y2;
            y2 := temp;
            temp := x1;
            x1 := x2;
            x2 := temp;
        END IF;

        FOR y IN y1..y2 LOOP
                IF style = 'Solid' THEN
                    CALL set_radius(ROUND((y - q) / k)::INTEGER, y, r, g, b, stroke_width);
                ELSIF style = 'Dashed' THEN
                    IF (step % (dash_length + gap_length)) < dash_length THEN
                        CALL set_radius(ROUND((y - q) / k)::INTEGER, y, r, g, b, stroke_width);
                    END IF;
                    step := step + 1;
                ELSIF style = 'Dotted' THEN
                    IF (step % dot_interval) = 0 THEN
                        CALL set_radius(ROUND((y - q) / k)::INTEGER, y, r, g, b, stroke_width);
                    END IF;
                    step := step + 1;
                END IF;
            END LOOP;
    END IF;

    NOTIFY repaint;
END;
$$;
