-- +goose Up

-- ─── Brands ───────────────────────────────────────────────────────────────────
INSERT INTO vehicles_brands (id, name, country) VALUES
    ('aaaaaaaa-0001-0000-0000-000000000000', 'Mercedes-Benz', 'Germany'),
    ('aaaaaaaa-0002-0000-0000-000000000000', 'BMW',           'Germany'),
    ('aaaaaaaa-0003-0000-0000-000000000000', 'Audi',          'Germany'),
    ('aaaaaaaa-0004-0000-0000-000000000000', 'Porsche',       'Germany'),
    ('aaaaaaaa-0005-0000-0000-000000000000', 'Volkswagen',    'Germany'),
    ('aaaaaaaa-0006-0000-0000-000000000000', 'Volvo',         'Sweden'),
    ('aaaaaaaa-0007-0000-0000-000000000000', 'Lexus',         'Japan'),
    ('aaaaaaaa-0008-0000-0000-000000000000', 'Tesla',         'USA')
ON CONFLICT DO NOTHING;

-- ─── Models ───────────────────────────────────────────────────────────────────
INSERT INTO vehicles_models (id, brand_id, model_name, classification, segment) VALUES
    -- Mercedes-Benz
    ('bbbbbbbb-0101-0000-0000-000000000000', 'aaaaaaaa-0001-0000-0000-000000000000', 'E-Class',  'Sedan',  'Mid'),
    ('bbbbbbbb-0102-0000-0000-000000000000', 'aaaaaaaa-0001-0000-0000-000000000000', 'C-Class',  'Sedan',  'Mid'),
    ('bbbbbbbb-0103-0000-0000-000000000000', 'aaaaaaaa-0001-0000-0000-000000000000', 'S-Class',  'Sedan',  'Large'),
    ('bbbbbbbb-0104-0000-0000-000000000000', 'aaaaaaaa-0001-0000-0000-000000000000', 'GLE',      'SUV',    'Large'),
    ('bbbbbbbb-0105-0000-0000-000000000000', 'aaaaaaaa-0001-0000-0000-000000000000', 'GLC',      'SUV',    'Mid'),
    -- BMW
    ('bbbbbbbb-0201-0000-0000-000000000000', 'aaaaaaaa-0002-0000-0000-000000000000', '3 Series', 'Sedan',  'Mid'),
    ('bbbbbbbb-0202-0000-0000-000000000000', 'aaaaaaaa-0002-0000-0000-000000000000', '5 Series', 'Sedan',  'Mid'),
    ('bbbbbbbb-0203-0000-0000-000000000000', 'aaaaaaaa-0002-0000-0000-000000000000', 'X5',       'SUV',    'Large'),
    ('bbbbbbbb-0204-0000-0000-000000000000', 'aaaaaaaa-0002-0000-0000-000000000000', 'M3',       'Sport',  'Mid'),
    -- Audi
    ('bbbbbbbb-0301-0000-0000-000000000000', 'aaaaaaaa-0003-0000-0000-000000000000', 'A4',       'Sedan',  'Mid'),
    ('bbbbbbbb-0302-0000-0000-000000000000', 'aaaaaaaa-0003-0000-0000-000000000000', 'A6',       'Sedan',  'Mid'),
    ('bbbbbbbb-0303-0000-0000-000000000000', 'aaaaaaaa-0003-0000-0000-000000000000', 'Q5',       'SUV',    'Mid'),
    -- Porsche
    ('bbbbbbbb-0401-0000-0000-000000000000', 'aaaaaaaa-0004-0000-0000-000000000000', 'Cayenne',  'SUV',    'Large'),
    ('bbbbbbbb-0402-0000-0000-000000000000', 'aaaaaaaa-0004-0000-0000-000000000000', 'Panamera', 'Sedan',  'Large'),
    -- Volkswagen
    ('bbbbbbbb-0501-0000-0000-000000000000', 'aaaaaaaa-0005-0000-0000-000000000000', 'Golf',     'Hatchback', 'Small'),
    ('bbbbbbbb-0502-0000-0000-000000000000', 'aaaaaaaa-0005-0000-0000-000000000000', 'Tiguan',   'SUV',    'Mid'),
    -- Volvo
    ('bbbbbbbb-0601-0000-0000-000000000000', 'aaaaaaaa-0006-0000-0000-000000000000', 'XC60',     'SUV',    'Mid'),
    ('bbbbbbbb-0602-0000-0000-000000000000', 'aaaaaaaa-0006-0000-0000-000000000000', 'XC90',     'SUV',    'Large'),
    -- Lexus
    ('bbbbbbbb-0701-0000-0000-000000000000', 'aaaaaaaa-0007-0000-0000-000000000000', 'ES',       'Sedan',  'Mid'),
    ('bbbbbbbb-0702-0000-0000-000000000000', 'aaaaaaaa-0007-0000-0000-000000000000', 'RX',       'SUV',    'Mid'),
    -- Tesla
    ('bbbbbbbb-0801-0000-0000-000000000000', 'aaaaaaaa-0008-0000-0000-000000000000', 'Model 3',  'Sedan',  'Mid'),
    ('bbbbbbbb-0802-0000-0000-000000000000', 'aaaaaaaa-0008-0000-0000-000000000000', 'Model Y',  'SUV',    'Mid')
ON CONFLICT DO NOTHING;

-- ─── Trims ────────────────────────────────────────────────────────────────────
INSERT INTO vehicles_trims (id, model_id, trim_name, body_type, year, base_price, fuel_type, seating_capacity, transmission, transmission_type) VALUES
    -- Mercedes-Benz E-Class
    ('cccccccc-0101-0000-0000-000000000000', 'bbbbbbbb-0101-0000-0000-000000000000', 'E 200',          'Sedan', '2024', 72000000, 'Gasoline', 5, '9G-TRONIC', 'Auto'),
    ('cccccccc-0102-0000-0000-000000000000', 'bbbbbbbb-0101-0000-0000-000000000000', 'E 300',          'Sedan', '2024', 82000000, 'Gasoline', 5, '9G-TRONIC', 'Auto'),
    ('cccccccc-0103-0000-0000-000000000000', 'bbbbbbbb-0101-0000-0000-000000000000', 'E 220 d',        'Sedan', '2024', 78000000, 'Diesel',   5, '9G-TRONIC', 'Auto'),
    ('cccccccc-0104-0000-0000-000000000000', 'bbbbbbbb-0101-0000-0000-000000000000', 'E 450 4MATIC',   'Sedan', '2023', 95000000, 'Gasoline', 5, '9G-TRONIC', 'Auto'),
    -- Mercedes-Benz C-Class
    ('cccccccc-0201-0000-0000-000000000000', 'bbbbbbbb-0102-0000-0000-000000000000', 'C 200',          'Sedan', '2024', 62000000, 'Gasoline', 5, '9G-TRONIC', 'Auto'),
    ('cccccccc-0202-0000-0000-000000000000', 'bbbbbbbb-0102-0000-0000-000000000000', 'C 300 4MATIC',   'Sedan', '2024', 72000000, 'Gasoline', 5, '9G-TRONIC', 'Auto'),
    -- Mercedes-Benz S-Class
    ('cccccccc-0301-0000-0000-000000000000', 'bbbbbbbb-0103-0000-0000-000000000000', 'S 450 4MATIC',   'Sedan', '2024', 185000000,'Gasoline', 5, '9G-TRONIC', 'Auto'),
    ('cccccccc-0302-0000-0000-000000000000', 'bbbbbbbb-0103-0000-0000-000000000000', 'S 580 4MATIC',   'Sedan', '2024', 220000000,'Gasoline', 5, '9G-TRONIC', 'Auto'),
    -- Mercedes-Benz GLE
    ('cccccccc-0401-0000-0000-000000000000', 'bbbbbbbb-0104-0000-0000-000000000000', 'GLE 300 d 4MATIC','SUV',  '2024', 98000000, 'Diesel',   5, '9G-TRONIC', 'Auto'),
    ('cccccccc-0402-0000-0000-000000000000', 'bbbbbbbb-0104-0000-0000-000000000000', 'GLE 450 4MATIC', 'SUV',  '2024', 112000000,'Gasoline', 5, '9G-TRONIC', 'Auto'),
    -- BMW 3 Series
    ('cccccccc-0501-0000-0000-000000000000', 'bbbbbbbb-0201-0000-0000-000000000000', '320i',           'Sedan', '2024', 58000000, 'Gasoline', 5, '8-speed Steptronic', 'Auto'),
    ('cccccccc-0502-0000-0000-000000000000', 'bbbbbbbb-0201-0000-0000-000000000000', '330i xDrive',    'Sedan', '2024', 67000000, 'Gasoline', 5, '8-speed Steptronic', 'Auto'),
    ('cccccccc-0503-0000-0000-000000000000', 'bbbbbbbb-0201-0000-0000-000000000000', '320d xDrive',    'Sedan', '2024', 62000000, 'Diesel',   5, '8-speed Steptronic', 'Auto'),
    -- BMW 5 Series
    ('cccccccc-0601-0000-0000-000000000000', 'bbbbbbbb-0202-0000-0000-000000000000', '520i',           'Sedan', '2024', 72000000, 'Gasoline', 5, '8-speed Steptronic', 'Auto'),
    ('cccccccc-0602-0000-0000-000000000000', 'bbbbbbbb-0202-0000-0000-000000000000', '530i xDrive',    'Sedan', '2024', 82000000, 'Gasoline', 5, '8-speed Steptronic', 'Auto'),
    ('cccccccc-0603-0000-0000-000000000000', 'bbbbbbbb-0202-0000-0000-000000000000', '520d xDrive',    'Sedan', '2024', 77000000, 'Diesel',   5, '8-speed Steptronic', 'Auto'),
    -- BMW X5
    ('cccccccc-0701-0000-0000-000000000000', 'bbbbbbbb-0203-0000-0000-000000000000', 'xDrive40i',      'SUV',   '2024', 105000000,'Gasoline', 5, '8-speed Steptronic', 'Auto'),
    ('cccccccc-0702-0000-0000-000000000000', 'bbbbbbbb-0203-0000-0000-000000000000', 'xDrive30d',      'SUV',   '2024', 98000000, 'Diesel',   5, '8-speed Steptronic', 'Auto'),
    -- BMW M3
    ('cccccccc-0801-0000-0000-000000000000', 'bbbbbbbb-0204-0000-0000-000000000000', 'M3 Competition', 'Sedan', '2024', 132000000,'Gasoline', 5, '8-speed M Steptronic', 'Auto'),
    -- Audi A4
    ('cccccccc-0901-0000-0000-000000000000', 'bbbbbbbb-0301-0000-0000-000000000000', '35 TFSI',        'Sedan', '2024', 57000000, 'Gasoline', 5, '7-speed S tronic', 'Auto'),
    ('cccccccc-0902-0000-0000-000000000000', 'bbbbbbbb-0301-0000-0000-000000000000', '40 TFSI quattro','Sedan', '2024', 65000000, 'Gasoline', 5, '7-speed S tronic', 'Auto'),
    -- Audi A6
    ('cccccccc-1001-0000-0000-000000000000', 'bbbbbbbb-0302-0000-0000-000000000000', '40 TFSI',        'Sedan', '2024', 72000000, 'Gasoline', 5, '7-speed S tronic', 'Auto'),
    ('cccccccc-1002-0000-0000-000000000000', 'bbbbbbbb-0302-0000-0000-000000000000', '45 TFSI quattro','Sedan', '2024', 82000000, 'Gasoline', 5, '7-speed S tronic', 'Auto'),
    -- Audi Q5
    ('cccccccc-1101-0000-0000-000000000000', 'bbbbbbbb-0303-0000-0000-000000000000', '40 TFSI quattro','SUV',   '2024', 78000000, 'Gasoline', 5, '7-speed S tronic', 'Auto'),
    -- Porsche Cayenne
    ('cccccccc-1201-0000-0000-000000000000', 'bbbbbbbb-0401-0000-0000-000000000000', 'Cayenne',        'SUV',   '2024', 135000000,'Gasoline', 5, '8-speed Tiptronic', 'Auto'),
    ('cccccccc-1202-0000-0000-000000000000', 'bbbbbbbb-0401-0000-0000-000000000000', 'Cayenne S',      'SUV',   '2024', 165000000,'Gasoline', 5, '8-speed Tiptronic', 'Auto'),
    -- Porsche Panamera
    ('cccccccc-1301-0000-0000-000000000000', 'bbbbbbbb-0402-0000-0000-000000000000', 'Panamera 4S',    'Sedan', '2024', 185000000,'Gasoline', 5, '8-speed PDK', 'Auto'),
    -- Volkswagen Golf
    ('cccccccc-1401-0000-0000-000000000000', 'bbbbbbbb-0501-0000-0000-000000000000', 'GTI',            'Hatchback','2024',48000000,'Gasoline', 5, '7-speed DSG', 'Auto'),
    -- Volkswagen Tiguan
    ('cccccccc-1501-0000-0000-000000000000', 'bbbbbbbb-0502-0000-0000-000000000000', 'Tiguan 2.0 TSI', 'SUV',   '2024', 52000000, 'Gasoline', 5, '7-speed DSG', 'Auto'),
    -- Volvo XC60
    ('cccccccc-1601-0000-0000-000000000000', 'bbbbbbbb-0601-0000-0000-000000000000', 'B5 AWD',         'SUV',   '2024', 72000000, 'Gasoline', 5, '8-speed Geartronic', 'Auto'),
    ('cccccccc-1602-0000-0000-000000000000', 'bbbbbbbb-0601-0000-0000-000000000000', 'Recharge T8',    'SUV',   '2024', 89000000, 'Plug-in Hybrid', 5, '8-speed Geartronic', 'Auto'),
    -- Volvo XC90
    ('cccccccc-1701-0000-0000-000000000000', 'bbbbbbbb-0602-0000-0000-000000000000', 'B6 AWD',         'SUV',   '2024', 92000000, 'Gasoline', 7, '8-speed Geartronic', 'Auto'),
    -- Lexus ES
    ('cccccccc-1801-0000-0000-000000000000', 'bbbbbbbb-0701-0000-0000-000000000000', 'ES 250',         'Sedan', '2024', 58000000, 'Gasoline', 5, '6-speed Automatic', 'Auto'),
    ('cccccccc-1802-0000-0000-000000000000', 'bbbbbbbb-0701-0000-0000-000000000000', 'ES 300h',        'Sedan', '2024', 65000000, 'Hybrid',   5, 'ECVT', 'Auto'),
    -- Lexus RX
    ('cccccccc-1901-0000-0000-000000000000', 'bbbbbbbb-0702-0000-0000-000000000000', 'RX 350',         'SUV',   '2024', 72000000, 'Gasoline', 5, '8-speed Automatic', 'Auto'),
    ('cccccccc-1902-0000-0000-000000000000', 'bbbbbbbb-0702-0000-0000-000000000000', 'RX 500h',        'SUV',   '2024', 85000000, 'Hybrid',   5, 'Direct Shift-CVT', 'Auto'),
    -- Tesla Model 3
    ('cccccccc-2001-0000-0000-000000000000', 'bbbbbbbb-0801-0000-0000-000000000000', 'Standard Range', 'Sedan', '2024', 55000000, 'Electric', 5, 'Single-speed', 'Auto'),
    ('cccccccc-2002-0000-0000-000000000000', 'bbbbbbbb-0801-0000-0000-000000000000', 'Long Range AWD', 'Sedan', '2024', 68000000, 'Electric', 5, 'Single-speed', 'Auto'),
    -- Tesla Model Y
    ('cccccccc-2101-0000-0000-000000000000', 'bbbbbbbb-0802-0000-0000-000000000000', 'Standard Range', 'SUV',   '2024', 62000000, 'Electric', 5, 'Single-speed', 'Auto'),
    ('cccccccc-2102-0000-0000-000000000000', 'bbbbbbbb-0802-0000-0000-000000000000', 'Long Range AWD', 'SUV',   '2024', 72000000, 'Electric', 5, 'Single-speed', 'Auto')
ON CONFLICT DO NOTHING;

-- ─── ICE Specs ────────────────────────────────────────────────────────────────
INSERT INTO vehicles_ice_specs (trim_id, displacement, fuel_eff_combined, fuel_eff_city, fuel_eff_highway, cylinder) VALUES
    ('cccccccc-0101-0000-0000-000000000000', 1999, 12.3, 10.8, 14.2, 4),
    ('cccccccc-0102-0000-0000-000000000000', 1999, 11.5, 10.1, 13.5, 4),
    ('cccccccc-0103-0000-0000-000000000000', 1993, 16.2, 14.5, 18.5, 4),
    ('cccccccc-0104-0000-0000-000000000000', 2999, 10.1,  8.8, 11.8, 6),
    ('cccccccc-0201-0000-0000-000000000000', 1497, 13.1, 11.5, 15.2, 4),
    ('cccccccc-0202-0000-0000-000000000000', 1999, 11.8, 10.3, 13.8, 4),
    ('cccccccc-0301-0000-0000-000000000000', 2999,  9.8,  8.5, 11.5, 6),
    ('cccccccc-0302-0000-0000-000000000000', 3982,  8.9,  7.8, 10.5, 8),
    ('cccccccc-0401-0000-0000-000000000000', 1993, 13.5, 12.0, 15.5, 4),
    ('cccccccc-0402-0000-0000-000000000000', 2999,  9.5,  8.2, 11.2, 6),
    ('cccccccc-0501-0000-0000-000000000000', 1998, 13.5, 11.8, 15.5, 4),
    ('cccccccc-0502-0000-0000-000000000000', 1998, 12.1, 10.5, 14.2, 4),
    ('cccccccc-0503-0000-0000-000000000000', 1995, 17.2, 15.5, 19.5, 4),
    ('cccccccc-0601-0000-0000-000000000000', 1998, 12.0, 10.5, 14.0, 4),
    ('cccccccc-0602-0000-0000-000000000000', 1998, 11.2,  9.8, 13.2, 4),
    ('cccccccc-0603-0000-0000-000000000000', 1995, 16.5, 14.8, 18.8, 4),
    ('cccccccc-0701-0000-0000-000000000000', 2998, 10.2,  8.8, 12.0, 6),
    ('cccccccc-0702-0000-0000-000000000000', 2993, 13.8, 12.2, 15.8, 6),
    ('cccccccc-0801-0000-0000-000000000000', 2993,  8.5,  7.5, 10.0, 6),
    ('cccccccc-0901-0000-0000-000000000000', 1395, 13.0, 11.5, 15.0, 4),
    ('cccccccc-0902-0000-0000-000000000000', 1984, 11.5, 10.0, 13.5, 4),
    ('cccccccc-1001-0000-0000-000000000000', 1984, 11.8, 10.2, 13.8, 4),
    ('cccccccc-1002-0000-0000-000000000000', 1984, 10.9,  9.5, 12.8, 4),
    ('cccccccc-1101-0000-0000-000000000000', 1984, 11.2,  9.8, 13.0, 4),
    ('cccccccc-1201-0000-0000-000000000000', 2894,  9.1,  7.8, 10.8, 6),
    ('cccccccc-1202-0000-0000-000000000000', 2894,  8.3,  7.1,  9.8, 6),
    ('cccccccc-1301-0000-0000-000000000000', 2894,  8.0,  6.9,  9.5, 6),
    ('cccccccc-1401-0000-0000-000000000000', 1984, 12.8, 11.2, 14.8, 4),
    ('cccccccc-1501-0000-0000-000000000000', 1984, 12.0, 10.5, 14.0, 4),
    ('cccccccc-1601-0000-0000-000000000000', 1969, 11.5, 10.0, 13.5, 4),
    ('cccccccc-1701-0000-0000-000000000000', 2498, 10.5,  9.0, 12.5, 4),
    ('cccccccc-1801-0000-0000-000000000000', 2494, 11.8, 10.2, 13.8, 6),
    ('cccccccc-1901-0000-0000-000000000000', 2354, 11.5, 10.0, 13.5, 4)
ON CONFLICT DO NOTHING;

-- ─── EV Specs ─────────────────────────────────────────────────────────────────
INSERT INTO vehicles_ev_specs (trim_id, battery_capacity, max_range, eff_combined, eff_city, eff_highway) VALUES
    ('cccccccc-2001-0000-0000-000000000000', 60.0,  510, 5.9, 5.5, 6.5),
    ('cccccccc-2002-0000-0000-000000000000', 82.0,  629, 7.7, 7.2, 8.5),
    ('cccccccc-2101-0000-0000-000000000000', 60.0,  488, 6.2, 5.8, 6.9),
    ('cccccccc-2102-0000-0000-000000000000', 82.0,  594, 7.2, 6.8, 8.0)
ON CONFLICT DO NOTHING;


-- +goose Down
DELETE FROM vehicles_ev_specs  WHERE trim_id::text  LIKE 'cccccccc-%';
DELETE FROM vehicles_ice_specs WHERE trim_id::text  LIKE 'cccccccc-%';
DELETE FROM vehicles_trims     WHERE id::text       LIKE 'cccccccc-%';
DELETE FROM vehicles_models    WHERE id::text       LIKE 'bbbbbbbb-%';
DELETE FROM vehicles_brands    WHERE id::text       LIKE 'aaaaaaaa-%';
