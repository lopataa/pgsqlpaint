CREATE OR REPLACE PROCEDURE fill(
    IN x INT,
    IN y INT,
    IN r INT DEFAULT 255,
    IN g INT DEFAULT 255,
    IN b INT DEFAULT 255
)
    LANGUAGE plpgsql
AS $$
DECLARE
    original_r INT;
    original_g INT;
    original_b INT;
BEGIN
    -- Get original color at starting point
    SELECT c.r, c.g, c.b INTO original_r, original_g, original_b
    FROM canvas c
    WHERE c.x = fill.x AND c.y = fill.y;

    -- Exit if no pixel exists or colors match
    IF NOT FOUND OR (original_r, original_g, original_b) = (fill.r, fill.g, fill.b) THEN
        RETURN;
    END IF;

    -- Recursive flood fill using 4-directional neighbors
    WITH RECURSIVE fill_area AS (
        SELECT c.x, c.y
        FROM canvas c
        WHERE c.x = fill.x AND c.y = fill.y
          AND c.r = original_r AND c.g = original_g AND c.b = original_b

        UNION

        SELECT nc.x, nc.y
        FROM canvas nc
                 JOIN fill_area fa ON (
            (nc.x = fa.x + 1 AND nc.y = fa.y) OR
            (nc.x = fa.x - 1 AND nc.y = fa.y) OR
            (nc.x = fa.x AND nc.y = fa.y + 1) OR
            (nc.x = fa.x AND nc.y = fa.y - 1)
            )
        WHERE nc.r = original_r AND nc.g = original_g AND nc.b = original_b
    )
    UPDATE canvas
    SET r = fill.r, g = fill.g, b = fill.b
    FROM fill_area
    WHERE canvas.x = fill_area.x AND canvas.y = fill_area.y;
END;
$$;
