-- +goose Up
ALTER TABLE vehicles_brands
    ADD CONSTRAINT uq_vehicles_brands_name UNIQUE (name);
 
ALTER TABLE vehicles_models
    ADD CONSTRAINT uq_vehicles_models_brand_model UNIQUE (brand_id, model_name);
 
ALTER TABLE vehicles_trims
    ADD CONSTRAINT uq_vehicles_trims_model_trim UNIQUE (model_id, trim_name);
 
ALTER TABLE vehicles_ice_specs
    ADD CONSTRAINT uq_vehicles_ice_specs_trim_id UNIQUE (trim_id);
 
ALTER TABLE vehicles_ev_specs
    ADD CONSTRAINT uq_vehicles_ev_specs_trim_id UNIQUE (trim_id);
 
-- +goose Down
ALTER TABLE vehicles_brands DROP CONSTRAINT uq_vehicles_brands_name;
ALTER TABLE vehicles_models DROP CONSTRAINT uq_vehicles_models_brand_model;
ALTER TABLE vehicles_trims DROP CONSTRAINT uq_vehicles_trims_model_trim;
ALTER TABLE vehicles_ice_specs DROP CONSTRAINT uq_vehicles_ice_specs_trim_id;
ALTER TABLE vehicles_ev_specs DROP CONSTRAINT uq_vehicles_ev_specs_trim_id;
 