-- +goose Up
CREATE TABLE vehicles_models (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES vehicles_brands(id) ON DELETE CASCADE,
    model_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    classification VARCHAR(50),
    segment VARCHAR(20),
    UNIQUE (brand_id, model_name)
);

-- +goose Down
DROP TABLE vehicles_models;