-- +goose Up
INSERT INTO brands (id, name)
VALUES ('11111111-1111-1111-1111-111111111111', 'Hyundai');

INSERT INTO car_models (id, brand_id, name, segment, is_active)
VALUES (
    '22222222-2222-2222-2222-222222222222',
    '11111111-1111-1111-1111-111111111111',
    'Avante',
    'Sedan',
    TRUE
);

INSERT INTO cars (
    id, model_id, trim_name, year, price, fuel_type, fuel_efficiency,
    transmission, engine_displacement, status, thumbnail_url
) VALUES (
    '33333333-3333-3333-3333-333333333333',
    '22222222-2222-2222-2222-222222222222',
    'Smart',
    2024,
    23000000,
    'Gasoline',
    14.80,
    'Automatic',
    1600,
    'ACTIVE',
    'https://example.com/avante-thumb.jpg'
);

INSERT INTO car_images (
    id, car_id, image_url, is_thumbnail, sort_order
) VALUES (
    '44444444-4444-4444-4444-444444444444',
    '33333333-3333-3333-3333-333333333333',
    'https://example.com/avante-1.jpg',
    TRUE,
    0
);

-- +goose Down
DELETE FROM car_images WHERE id = '44444444-4444-4444-4444-444444444444';
DELETE FROM cars WHERE id = '33333333-3333-3333-3333-333333333333';
DELETE FROM car_models WHERE id = '22222222-2222-2222-2222-222222222222';
DELETE FROM brands WHERE id = '11111111-1111-1111-1111-111111111111';