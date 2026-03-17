-- +goose Up
CREATE TABLE vehicles_trim_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trim_id UUID NOT NULL REFERENCES vehicles_trims(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    image_type VARCHAR(50)
);

-- +goose Down
DROP TABLE vehicles_trim_images;