CREATE OR REPLACE PROCEDURE set_pixel(IN p_x integer, IN p_y integer, IN p_r integer DEFAULT 255, IN p_g integer DEFAULT 255, IN p_b integer DEFAULT 255)
    LANGUAGE plpgsql
AS
$$
BEGIN
    INSERT INTO canvas (x, y, r, g, b)
    VALUES (p_x, p_y, p_r, p_g, p_b)
    ON CONFLICT (x, y) DO UPDATE
        SET r = p_r,
            g = p_g,
            b = p_b;
END;
$$;
