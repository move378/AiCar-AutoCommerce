-- +goose Up
CREATE TABLE car_images (
    id UUID PRIMARY KEY,
    car_id UUID NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    is_thumbnail BOOLEAN NOT NULL DEFAULT FALSE,
    sort_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_car_images_car
        FOREIGN KEY (car_id) REFERENCES cars(id)
);

-- +goose Down
DROP TABLE IF EXISTS car_images;