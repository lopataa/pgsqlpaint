CREATE OR REPLACE PROCEDURE unset_pixel(IN p_x integer, IN p_y integer)
    LANGUAGE plpgsql
AS
$$
BEGIN
    DELETE FROM canvas WHERE x = p_x AND y = p_y;
END;
$$;
