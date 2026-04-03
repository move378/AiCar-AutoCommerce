-- +goose Up
CREATE TABLE IF NOT EXISTS my_cars (
    id UUID PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    license_plate VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- +goose Down
DROP TABLE IF EXISTS my_cars;