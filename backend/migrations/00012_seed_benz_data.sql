-- +goose Up
-- 1. 브랜드 시드 데이터
INSERT INTO vehicles_brands (id, name, country, logo_url)
VALUES ('550e8400-e29b-41d4-a716-446655440000', 'Mercedes-Benz', 'Germany', 'https://www.mercedes-benz.co.kr/logo.png');

-- 2. 모델 시드 데이터 (classification: '승용' 추가)
INSERT INTO vehicles_models (id, brand_id, model_name, category, classification, segment)
VALUES (
    '6ba7b810-9dad-11d1-80b4-00c04fd430c8', 
    '550e8400-e29b-41d4-a716-446655440000', 
    'CLE', 
    'Coupé', 
    '승용', 
    'E-Segment'
);

-- 3. 트림 시드 데이터 (CLE 450 4MATIC Coupé)
INSERT INTO vehicles_trims (
    id, model_id, trim_name, year, base_price, fuel_type, 
    seating_capacity, max_output, acceleration, 
    length, width, height, curb_weight, transmission, image_url
) VALUES (
    '88888888-4444-4444-4444-1234567890ab',
    '6ba7b810-9dad-11d1-80b4-00c04fd430c8',
    'CLE 450 4MATIC Coupé AMG Line',
    '2025',
    98400000,
    'ICE',
    4, 381, 4.4,
    4850, 1861, 1422, 2400,
    '자동 9단 변속기',
    'https://media.oneweb.mercedes-benz.com/images/dynamic/asia/KR/236361/806/iris.webp'
);

-- 4. 내연기관 스펙 및 연비 시드 데이터
INSERT INTO vehicles_ice_specs (
    trim_id, displacement, fuel_tank_capacity, 
    fuel_eff_combined, fuel_eff_city, fuel_eff_highway, energy_grade
) VALUES (
    '88888888-4444-4444-4444-1234567890ab',
    2999,
    66,
    10.7, 9.1, 13.2, 3
);

-- 5. 옵션 및 매핑 데이터 (생략 가능하나 구조 유지를 위해 포함)
INSERT INTO vehicles_options (id, name, category, description) VALUES 
('f47ac10b-58cc-4372-a567-0e02b2c3d479', '디지털 라이트', 'EXTERIOR', '디지털 라이트 및 프로젝션 기능'),
('f47ac10b-58cc-4372-a567-0e02b2c3d480', '부메스터® 서라운드 사운드 시스템', 'MULTIMEDIA', '고성능 서라운드 사운드 시스템');

INSERT INTO vehicles_trim_options (trim_id, option_id, price, is_standard, availability)
VALUES 
('88888888-4444-4444-4444-1234567890ab', 'f47ac10b-58cc-4372-a567-0e02b2c3d479', 0, TRUE, TRUE),
('88888888-4444-4444-4444-1234567890ab', 'f47ac10b-58cc-4372-a567-0e02b2c3d480', 0, TRUE, TRUE);

-- +goose Down
DELETE FROM vehicles_trim_options;
DELETE FROM vehicles_options;
DELETE FROM vehicles_ice_specs;
DELETE FROM vehicles_ev_specs;
DELETE FROM vehicles_trims;
DELETE FROM vehicles_models;
DELETE FROM vehicles_brands;