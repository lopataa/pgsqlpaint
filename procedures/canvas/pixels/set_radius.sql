CREATE OR REPLACE PROCEDURE set_radius(IN p_x integer, IN p_y integer, IN p_r integer DEFAULT 255,
                                      IN p_g integer DEFAULT 255, IN p_b integer DEFAULT 255, IN radius integer DEFAULT 0)
    LANGUAGE plpgsql
AS
$$
BEGIN
    -- call set pixel with in a certain radius
    FOR x IN p_x - radius..p_x + radius LOOP
        FOR y IN p_y - radius..p_y + radius LOOP
            IF (x - p_x) * (x - p_x) + (y - p_y) * (y - p_y) <= radius * radius THEN
                CALL set_pixel(x, y, p_r, p_g, p_b);
            END IF;
        END LOOP;
    END LOOP;
END;
$$;
