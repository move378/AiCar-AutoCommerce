-- +goose Up

-- BMW 브랜드
INSERT INTO brands (id, name)
VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'BMW')
ON CONFLICT DO NOTHING;

-- Mercedes-Benz 브랜드
INSERT INTO brands (id, name)
VALUES ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Mercedes-Benz')
ON CONFLICT DO NOTHING;

-- Audi 브랜드
INSERT INTO brands (id, name)
VALUES ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Audi')
ON CONFLICT DO NOTHING;

-- Lexus 브랜드
INSERT INTO brands (id, name)
VALUES ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'Lexus')
ON CONFLICT DO NOTHING;

-- Volvo 브랜드
INSERT INTO brands (id, name)
VALUES ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'Volvo')
ON CONFLICT DO NOTHING;

-- BMW 모델
INSERT INTO car_models (id, brand_id, name, segment, is_active) VALUES
('a1000000-0000-0000-0000-000000000001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '3 Series', 'Sedan', TRUE),
('a1000000-0000-0000-0000-000000000002', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '5 Series', 'Sedan', TRUE),
('a1000000-0000-0000-0000-000000000003', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'X3', 'SUV', TRUE);

-- Mercedes-Benz 모델
INSERT INTO car_models (id, brand_id, name, segment, is_active) VALUES
('b1000000-0000-0000-0000-000000000001', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'C-Class', 'Sedan', TRUE),
('b1000000-0000-0000-0000-000000000002', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'E-Class', 'Sedan', TRUE),
('b1000000-0000-0000-0000-000000000003', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'GLC', 'SUV', TRUE);

-- Audi 모델
INSERT INTO car_models (id, brand_id, name, segment, is_active) VALUES
('c1000000-0000-0000-0000-000000000001', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'A4', 'Sedan', TRUE),
('c1000000-0000-0000-0000-000000000002', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'Q5', 'SUV', TRUE);

-- Lexus 모델
INSERT INTO car_models (id, brand_id, name, segment, is_active) VALUES
('d1000000-0000-0000-0000-000000000001', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'ES', 'Sedan', TRUE);

-- Volvo 모델
INSERT INTO car_models (id, brand_id, name, segment, is_active) VALUES
('e1000000-0000-0000-0000-000000000001', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'XC60', 'SUV', TRUE);

-- BMW 3 Series 320i
INSERT INTO cars (id, model_id, trim_name, year, price, fuel_type, fuel_efficiency, transmission, engine_displacement, status, thumbnail_url) VALUES
('ca000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000001', '320i', 2025, 53900000, 'Gasoline', 11.4, 'Automatic', 1998, 'ACTIVE', 'https://example.com/bmw-320i.jpg');

-- BMW 5 Series 530i
INSERT INTO cars (id, model_id, trim_name, year, price, fuel_type, fuel_efficiency, transmission, engine_displacement, status, thumbnail_url) VALUES
('ca000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000002', '530i', 2025, 71900000, 'Gasoline', 10.2, 'Automatic', 1998, 'ACTIVE', 'https://example.com/bmw-530i.jpg');

-- BMW X3 xDrive20i
INSERT INTO cars (id, model_id, trim_name, year, price, fuel_type, fuel_efficiency, transmission, engine_displacement, status, thumbnail_url) VALUES
('ca000000-0000-0000-0000-000000000003', 'a1000000-0000-0000-0000-000000000003', 'xDrive20i', 2025, 66500000, 'Gasoline', 10.6, 'Automatic', 1998, 'ACTIVE', 'https://example.com/bmw-x3.jpg');

-- Mercedes-Benz C 200
INSERT INTO cars (id, model_id, trim_name, year, price, fuel_type, fuel_efficiency, transmission, engine_displacement, status, thumbnail_url) VALUES
('ca000000-0000-0000-0000-000000000004', 'b1000000-0000-0000-0000-000000000001', 'C 200', 2025, 58600000, 'Gasoline', 11.1, 'Automatic', 1496, 'ACTIVE', 'https://example.com/benz-c200.jpg');

-- Mercedes-Benz E 300
INSERT INTO cars (id, model_id, trim_name, year, price, fuel_type, fuel_efficiency, transmission, engine_displacement, status, thumbnail_url) VALUES
('ca000000-0000-0000-0000-000000000005', 'b1000000-0000-0000-0000-000000000002', 'E 300', 2025, 81200000, 'Gasoline', 9.8, 'Automatic', 1999, 'ACTIVE', 'https://example.com/benz-e300.jpg');

-- Mercedes-Benz GLC 300
INSERT INTO cars (id, model_id, trim_name, year, price, fuel_type, fuel_efficiency, transmission, engine_displacement, status, thumbnail_url) VALUES
('ca000000-0000-0000-0000-000000000006', 'b1000000-0000-0000-0000-000000000003', 'GLC 300', 2025, 73100000, 'Gasoline', 9.5, 'Automatic', 1999, 'ACTIVE', 'https://example.com/benz-glc300.jpg');

-- Audi A4 40 TFSI
INSERT INTO cars (id, model_id, trim_name, year, price, fuel_type, fuel_efficiency, transmission, engine_displacement, status, thumbnail_url) VALUES
('ca000000-0000-0000-0000-000000000007', 'c1000000-0000-0000-0000-000000000001', '40 TFSI', 2025, 54700000, 'Gasoline', 11.0, 'Automatic', 1984, 'ACTIVE', 'https://example.com/audi-a4.jpg');

-- Audi Q5 45 TFSI
INSERT INTO cars (id, model_id, trim_name, year, price, fuel_type, fuel_efficiency, transmission, engine_displacement, status, thumbnail_url) VALUES
('ca000000-0000-0000-0000-000000000008', 'c1000000-0000-0000-0000-000000000002', '45 TFSI quattro', 2025, 69800000, 'Gasoline', 9.2, 'Automatic', 1984, 'ACTIVE', 'https://example.com/audi-q5.jpg');

-- Lexus ES 300h
INSERT INTO cars (id, model_id, trim_name, year, price, fuel_type, fuel_efficiency, transmission, engine_displacement, status, thumbnail_url) VALUES
('ca000000-0000-0000-0000-000000000009', 'd1000000-0000-0000-0000-000000000001', '300h', 2025, 59900000, 'Hybrid', 18.1, 'CVT', 2487, 'ACTIVE', 'https://example.com/lexus-es.jpg');

-- Volvo XC60 B5
INSERT INTO cars (id, model_id, trim_name, year, price, fuel_type, fuel_efficiency, transmission, engine_displacement, status, thumbnail_url) VALUES
('ca000000-0000-0000-0000-000000000010', 'e1000000-0000-0000-0000-000000000001', 'B5 AWD', 2025, 63900000, 'Gasoline(MHEV)', 10.0, 'Automatic', 1969, 'ACTIVE', 'https://example.com/volvo-xc60.jpg');

-- 이미지 데이터
INSERT INTO car_images (id, car_id, image_url, is_thumbnail, sort_order) VALUES
('ci000000-0000-0000-0000-000000000001', 'ca000000-0000-0000-0000-000000000001', 'https://example.com/bmw-320i.jpg', TRUE, 0),
('ci000000-0000-0000-0000-000000000002', 'ca000000-0000-0000-0000-000000000002', 'https://example.com/bmw-530i.jpg', TRUE, 0),
('ci000000-0000-0000-0000-000000000003', 'ca000000-0000-0000-0000-000000000003', 'https://example.com/bmw-x3.jpg', TRUE, 0),
('ci000000-0000-0000-0000-000000000004', 'ca000000-0000-0000-0000-000000000004', 'https://example.com/benz-c200.jpg', TRUE, 0),
('ci000000-0000-0000-0000-000000000005', 'ca000000-0000-0000-0000-000000000005', 'https://example.com/benz-e300.jpg', TRUE, 0),
('ci000000-0000-0000-0000-000000000006', 'ca000000-0000-0000-0000-000000000006', 'https://example.com/benz-glc300.jpg', TRUE, 0),
('ci000000-0000-0000-0000-000000000007', 'ca000000-0000-0000-0000-000000000007', 'https://example.com/audi-a4.jpg', TRUE, 0),
('ci000000-0000-0000-0000-000000000008', 'ca000000-0000-0000-0000-000000000008', 'https://example.com/audi-q5.jpg', TRUE, 0),
('ci000000-0000-0000-0000-000000000009', 'ca000000-0000-0000-0000-000000000009', 'https://example.com/lexus-es.jpg', TRUE, 0),
('ci000000-0000-0000-0000-000000000010', 'ca000000-0000-0000-0000-000000000010', 'https://example.com/volvo-xc60.jpg', TRUE, 0);

-- +goose Down
DELETE FROM car_images WHERE id LIKE 'ci000000%';
DELETE FROM cars WHERE id LIKE 'ca000000%';
DELETE FROM car_models WHERE id IN ('a1000000-0000-0000-0000-000000000001','a1000000-0000-0000-0000-000000000002','a1000000-0000-0000-0000-000000000003','b1000000-0000-0000-0000-000000000001','b1000000-0000-0000-0000-000000000002','b1000000-0000-0000-0000-000000000003','c1000000-0000-0000-0000-000000000001','c1000000-0000-0000-0000-000000000002','d1000000-0000-0000-0000-000000000001','e1000000-0000-0000-0000-000000000001');
DELETE FROM brands WHERE id IN ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb','cccccccc-cccc-cccc-cccc-cccccccccccc','dddddddd-dddd-dddd-dddd-dddddddddddd','eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee');
