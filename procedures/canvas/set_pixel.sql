CREATE OR REPLACE PROCEDURE set_pixel(
    IN x INT,
    IN y INT,
    IN r INT DEFAULT 255,
    IN g INT DEFAULT 255,
    IN b INT DEFAULT 255
)
    LANGUAGE plpgsql
AS
$$
begin
    execute 'UPDATE canvas SET' ||
            ' r = ' || r || ',' ||
            ' g = ' || g || ',' ||
            ' b = ' || b || '' ||
            ' WHERE x = ' || x || ' AND y = ' || y;
end;
$$;