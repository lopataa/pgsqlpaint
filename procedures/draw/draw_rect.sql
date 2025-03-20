CREATE OR REPLACE PROCEDURE draw_rect(
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
BEGIN
    CALL draw_line(x1, y1, x2, y1, r, g, b);
    CALL draw_line(x1, y1, x1, y2, r, g, b);
    CALL draw_line(x2, y1, x2, y2, r, g, b);
    CALL draw_line(x1, y2, x2, y2, r, g, b);
END;
$$;
