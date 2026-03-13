-- +goose Up
CREATE TABLE vehicles_models (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES vehicles_brands(id) ON DELETE CASCADE,
    model_name VARCHAR(100) NOT NULL,
    -- category(바디타입) 컬럼 삭제 (트림 테이블로 이동)
    classification VARCHAR(50),
    segment VARCHAR(20),
    CONSTRAINT uq_vehicles_models_brand_model UNIQUE (brand_id, model_name)
);

-- +goose Down
DROP TABLE vehicles_models;