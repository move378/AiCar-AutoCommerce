-- +goose Up
CREATE TABLE vehicles_ice_specs (
    trim_id UUID PRIMARY KEY REFERENCES vehicles_trims(id) ON DELETE CASCADE,
    displacement INT,
    fuel_tank_capacity INT,
    fuel_eff_combined DECIMAL(4,1),
    fuel_eff_city DECIMAL(4,1),
    fuel_eff_highway DECIMAL(4,1),
    energy_grade INT
);

-- +goose Down
DROP TABLE vehicles_ice_specs;