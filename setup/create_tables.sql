CREATE TABLE IF NOT EXISTS canvas (
    x INT,
    y INT,
    r INT DEFAULT 0,
    g INT DEFAULT 0,
    b INT DEFAULT 0,

    PRIMARY KEY (x, y)
);

-- create indices for faster lookups
CREATE INDEX IF NOT EXISTS canvas_x_idx ON canvas (x);
CREATE INDEX IF NOT EXISTS canvas_y_idx ON canvas (y);