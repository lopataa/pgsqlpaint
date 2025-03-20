CREATE TABLE IF NOT EXISTS canvas (
    id SERIAL PRIMARY KEY,
    x INT,
    y INT,
    r INT DEFAULT 0,
    g INT DEFAULT 0,
    b INT DEFAULT 0
);

-- create indices for faster lookups
CREATE INDEX IF NOT EXISTS canvas_x_idx ON canvas (x);
CREATE INDEX IF NOT EXISTS canvas_y_idx ON canvas (y);