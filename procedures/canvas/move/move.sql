CREATE OR REPLACE PROCEDURE move(
    IN p_x1 INT,
    IN p_y1 INT,
    IN p_x2 INT,
    IN p_y2 INT,
    IN p_x_to INT,
    IN p_y_to INT,
    IN p_x_to2 INT,
    IN p_y_to2 INT
)
    LANGUAGE plpgsql
AS
$$
DECLARE
    source_width INT;
    source_height INT;
    target_width INT;
    target_height INT;
    scale_x FLOAT;
    scale_y FLOAT;
BEGIN
    -- Calculate dimensions
    source_width := p_x2 - p_x1 + 1;
    source_height := p_y2 - p_y1 + 1;
    target_width := p_x_to2 - p_x_to + 1;
    target_height := p_y_to2 - p_y_to + 1;

    -- Calculate scaling factors, handle edge cases
    scale_x := CASE
                   WHEN target_width = 1 THEN 0
                   ELSE (source_width - 1)::FLOAT / (target_width - 1)
        END;

    scale_y := CASE
                   WHEN target_height = 1 THEN 0
                   ELSE (source_height - 1)::FLOAT / (target_height - 1)
        END;

    -- Delete the target area
    DELETE
    FROM canvas
    WHERE x BETWEEN p_x_to AND p_x_to2
      AND y BETWEEN p_y_to AND p_y_to2;

    -- Insert with nearest neighbor scaling
    WITH target_points AS (
        SELECT
            p_x_to + x_offset AS target_x,
            p_y_to + y_offset AS target_y,
            p_x1 + round(x_offset * scale_x) AS source_x,
            p_y1 + round(y_offset * scale_y) AS source_y
        FROM
            generate_series(0, target_width - 1) AS x_offset,
            generate_series(0, target_height - 1) AS y_offset
    )
    INSERT INTO canvas (x, y, r, g, b)
    SELECT tp.target_x, tp.target_y, c.r, c.g, c.b
    FROM target_points tp
             JOIN canvas c ON c.x = tp.source_x AND c.y = tp.source_y
    WHERE tp.source_x BETWEEN p_x1 AND p_x2
      AND tp.source_y BETWEEN p_y1 AND p_y2;

    notify repaint;
END;
$$;
