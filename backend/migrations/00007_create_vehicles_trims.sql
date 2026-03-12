-- +goose Up
CREATE TABLE vehicles_trims (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    model_id UUID NOT NULL REFERENCES vehicles_models(id) ON DELETE CASCADE,
    trim_name VARCHAR(255) NOT NULL,
    year VARCHAR(20),
    base_price BIGINT,
    fuel_type VARCHAR(50),
    seating_capacity SMALLINT,
    trunk_capacity INT,
    max_output INT,
    drive_type DECIMAL(5,1),
    acceleration DECIMAL(3,1),
    length INT,
    width INT,
    height INT,
    wheelbase INT,
    curb_weight INT,
    transmission VARCHAR(100),
    image_url TEXT,
    top_speed INT,
    doors SMALLINT,
    UNIQUE (model_id, trim_name)
);

-- +goose Down
DROP TABLE vehicles_trims;