CREATE OR REPLACE PROCEDURE clear_canvas(
    IN width INT DEFAULT 800,
    IN height INT DEFAULT 600
) LANGUAGE plpgsql AS $$
BEGIN
    TRUNCATE TABLE canvas RESTART IDENTITY;

    INSERT INTO canvas (x, y)
    SELECT x, y
    FROM generate_series(1, width) AS x
             CROSS JOIN generate_series(1, height) AS y;
END;
$$;
