-- +goose Up
CREATE TABLE cars (
    id UUID PRIMARY KEY,
    model_id UUID NOT NULL,
    trim_name VARCHAR(100),
    year INT NOT NULL,
    price INT NOT NULL DEFAULT 0,
    fuel_type VARCHAR(30),
    fuel_efficiency DECIMAL(5,2),
    transmission VARCHAR(30),
    engine_displacement INT,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    thumbnail_url VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    CONSTRAINT fk_cars_model
        FOREIGN KEY (model_id) REFERENCES car_models(id)
);

-- +goose Down
DROP TABLE IF EXISTS cars;