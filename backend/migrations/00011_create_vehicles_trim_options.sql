-- +goose Up
CREATE TABLE vehicles_trim_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trim_id UUID NOT NULL REFERENCES vehicles_trims(id) ON DELETE CASCADE,
    option_id UUID NOT NULL REFERENCES vehicles_options(id) ON DELETE CASCADE,
    price BIGINT DEFAULT 0,
    is_standard BOOLEAN DEFAULT FALSE,
    availability BOOLEAN DEFAULT TRUE
);

-- +goose Down
DROP TABLE vehicles_trim_options;