-- +goose Up
CREATE TABLE vehicles_trims (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    model_id UUID NOT NULL REFERENCES vehicles_models(id) ON DELETE CASCADE,
    trim_name VARCHAR(255) NOT NULL,
    -- 모델 테이블에서 이동된 바디 타입 정보
    body_type VARCHAR(50),
    body_type_code VARCHAR(50),
    -- 이하 기존 제원 정보 동일
    year VARCHAR(20),
    base_price BIGINT,
    fuel_type VARCHAR(50),
    seating_capacity SMALLINT,
    max_output INT,
    drive_type DECIMAL(5,1),
    acceleration DECIMAL(3,1),
    length INT,
    width INT,
    height INT,
    curb_weight INT,
    transmission VARCHAR(100),
    image_url TEXT,
    top_speed INT,
    doors SMALLINT,
    CONSTRAINT uq_vehicles_trims_model_trim UNIQUE (model_id, trim_name)
);

-- +goose Down
DROP TABLE vehicles_trims;