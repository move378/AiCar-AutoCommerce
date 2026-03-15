-- +goose Up
CREATE TABLE car_models (
    id UUID PRIMARY KEY,
    brand_id UUID NOT NULL,
    name VARCHAR(100) NOT NULL,
    segment VARCHAR(50),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_car_models_brand
        FOREIGN KEY (brand_id) REFERENCES brands(id)
);

-- +goose Down
DROP TABLE IF EXISTS car_models;