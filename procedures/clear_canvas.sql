CREATE OR REPLACE PROCEDURE
    clear_canvas(
    IN width INT default 800,
    IN height INT default 600
)
    LANGUAGE plpgsql
AS
$$
begin
    execute 'truncate table canvas';

    -- Insert empty rows (height)
    FOR y IN 1..height
        LOOP
            FOR x IN 1..height
                LOOP
                    EXECUTE 'INSERT INTO canvas (x,y) VALUES (' || x || ',' || y || ')';
                END LOOP;
        END LOOP;
end;
$$;
