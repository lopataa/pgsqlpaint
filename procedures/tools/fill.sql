CREATE OR REPLACE PROCEDURE fill(
    IN p_x INT,
    IN p_y INT,
    IN r INT DEFAULT 255,
    IN g INT DEFAULT 255,
    IN b INT DEFAULT 255
)
    LANGUAGE plpgsql
AS $$
DECLARE
    target_r INT;
    target_g INT;
    target_b INT;
    queue_x INT[];
    queue_y INT[];
    current_x INT;
    current_y INT;
    current_r INT;
    current_g INT;
    current_b INT;
    queue_pos INT := 1;
    queue_size INT := 1;
BEGIN
    -- Get the color of the target pixel
    SELECT get_pixel.r, get_pixel.g, get_pixel.b
    INTO target_r, target_g, target_b
    FROM get_pixel(p_x, p_y);

    -- If target color is the same as fill color, no need to do anything
    IF target_r = r AND target_g = g AND target_b = b THEN
        RETURN;
    END IF;

    RAISE NOTICE 'Processing pixel at (%), color: (%), (%), (%)', current_x, current_r, current_g, current_b;


    -- Initialize queue with starting point
    queue_x := ARRAY[p_x];
    queue_y := ARRAY[p_y];

    -- Process queue until empty
    WHILE queue_pos <= queue_size LOOP
            -- Get current pixel from queue
            current_x := queue_x[queue_pos];
            current_y := queue_y[queue_pos];
            queue_pos := queue_pos + 1;

            -- Get color of current pixel
            SELECT get_pixel.r, get_pixel.g, get_pixel.b
            INTO current_r, current_g, current_b
            FROM get_pixel(current_x, current_y);

            -- If color matches target color, fill it and add neighbors to queue
            IF current_r = target_r AND current_g = target_g AND current_b = target_b THEN
                -- Fill current pixel
                CALL set_pixel(current_x, current_y, r, g, b);

                -- Add neighbors to queue (4-way connectivity)
                -- Right neighbor
                queue_x := array_append(queue_x, current_x + 1);
                queue_y := array_append(queue_y, current_y);
                queue_size := queue_size + 1;

                -- Left neighbor
                queue_x := array_append(queue_x, current_x - 1);
                queue_y := array_append(queue_y, current_y);
                queue_size := queue_size + 1;

                -- Bottom neighbor
                queue_x := array_append(queue_x, current_x);
                queue_y := array_append(queue_y, current_y + 1);
                queue_size := queue_size + 1;

                -- Top neighbor
                queue_x := array_append(queue_x, current_x);
                queue_y := array_append(queue_y, current_y - 1);
                queue_size := queue_size + 1;
            END IF;
        END LOOP;

    NOTIFY repaint;
END;
$$;
