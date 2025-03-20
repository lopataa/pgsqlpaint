CREATE OR REPLACE PROCEDURE draw_line(
    IN x1 INT,
    IN y1 INT,
    IN x2 INT,
    IN y2 INT,
    IN r INT DEFAULT 255,
    IN g INT DEFAULT 255,
    IN b INT DEFAULT 255
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
BEGIN
    -- Show the params
    RAISE NOTICE 'x1: %, y1: %, x2: %, y2: %, r: %, g: %, b: %', x1, y1, x2, y2, r, g, b;

    -- Handle vertical line case (dx == 0)
    IF x1 = x2 THEN
        -- Ensure y1 <= y2 for the loop
        IF y1 > y2 THEN
            temp := y1;
            y1 := y2;
            y2 := temp;
        END IF;

        -- Draw vertical line
        FOR y IN y1..y2 LOOP
                CALL set_pixel(x1, y, r, g, b);
            END LOOP;

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
        END IF;

        FOR x IN x1..x2 LOOP
                CALL set_pixel(x, ROUND(k * x + q)::INTEGER, r, g, b);
            END LOOP;
        -- For steep slopes (|k| >= 1), iterate over y
    ELSE
        -- Ensure y1 <= y2 for the loop
        IF y1 > y2 THEN
            temp := y1;
            y1 := y2;
            y2 := temp;
        END IF;

        FOR y IN y1..y2 LOOP
                CALL set_pixel(ROUND((y - q) / k)::INTEGER, y, r, g, b);
            END LOOP;
    END IF;
END;
$$;
