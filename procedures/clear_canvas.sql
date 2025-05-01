CREATE OR REPLACE PROCEDURE clear_canvas(
    IN width INT DEFAULT 800,
    IN height INT DEFAULT 600
)
    LANGUAGE plpgsql AS
$$
BEGIN
    TRUNCATE TABLE canvas;

    -- create a single row at the right lower corner
    INSERT INTO canvas (x, y, r, g, b) VALUES (width, height, 0, 0, 0);

    NOTIFY repaint;
END;
$$;
