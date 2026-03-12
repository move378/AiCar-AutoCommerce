-- +goose Up
CREATE TABLE vehicles_brands (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL UNIQUE,
    country VARCHAR(100),
    logo_url TEXT
);

-- +goose Down
DROP TABLE vehicles_brands;