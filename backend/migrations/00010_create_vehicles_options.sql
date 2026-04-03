-- +goose Up
CREATE TABLE vehicles_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    description TEXT
);

-- +goose Down
DROP TABLE vehicles_options;