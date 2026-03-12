-- +goose Up
-- classification(법적 구분) 필드를 모델 테이블에 추가했습니다.
CREATE TABLE vehicles_models (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES vehicles_brands(id) ON DELETE CASCADE,
    model_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),             -- 마케팅 구분 (Coupé, Sedan 등)
    classification VARCHAR(50),       -- 법적 구분 (승용, 승합, 화물 등)
    segment VARCHAR(20)               -- 체급 (E-Segment 등)
);

-- +goose Down
DROP TABLE vehicles_models;