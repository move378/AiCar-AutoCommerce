-- +goose Up
CREATE TABLE vehicles_ev_specs (
    trim_id UUID PRIMARY KEY REFERENCES vehicles_trims(id) ON DELETE CASCADE,
    battery_capacity DECIMAL(5,1),
    max_range INT,
    eff_combined DECIMAL(3,1),
    eff_city DECIMAL(3,1),
    eff_highway DECIMAL(3,1),
    energy_grade INT,
    UNIQUE (trim_id)
);

-- +goose Down
DROP TABLE vehicles_ev_specs;