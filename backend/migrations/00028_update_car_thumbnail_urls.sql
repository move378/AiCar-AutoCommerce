-- +goose Up

-- BMW 320i
UPDATE cars SET thumbnail_url = 'https://placehold.co/600x400/0066B1/FFFFFF?text=BMW+320i&font=montserrat'
WHERE id = 'ca000000-0000-0000-0000-000000000001';
UPDATE car_images SET image_url = 'https://placehold.co/600x400/0066B1/FFFFFF?text=BMW+320i&font=montserrat'
WHERE id = 'ci000000-0000-0000-0000-000000000001';

-- BMW 530i
UPDATE cars SET thumbnail_url = 'https://placehold.co/600x400/0066B1/FFFFFF?text=BMW+530i&font=montserrat'
WHERE id = 'ca000000-0000-0000-0000-000000000002';
UPDATE car_images SET image_url = 'https://placehold.co/600x400/0066B1/FFFFFF?text=BMW+530i&font=montserrat'
WHERE id = 'ci000000-0000-0000-0000-000000000002';

-- BMW X3
UPDATE cars SET thumbnail_url = 'https://placehold.co/600x400/0066B1/FFFFFF?text=BMW+X3&font=montserrat'
WHERE id = 'ca000000-0000-0000-0000-000000000003';
UPDATE car_images SET image_url = 'https://placehold.co/600x400/0066B1/FFFFFF?text=BMW+X3&font=montserrat'
WHERE id = 'ci000000-0000-0000-0000-000000000003';

-- Mercedes-Benz C 200
UPDATE cars SET thumbnail_url = 'https://placehold.co/600x400/333333/FFFFFF?text=Benz+C200&font=montserrat'
WHERE id = 'ca000000-0000-0000-0000-000000000004';
UPDATE car_images SET image_url = 'https://placehold.co/600x400/333333/FFFFFF?text=Benz+C200&font=montserrat'
WHERE id = 'ci000000-0000-0000-0000-000000000004';

-- Mercedes-Benz E 300
UPDATE cars SET thumbnail_url = 'https://placehold.co/600x400/333333/FFFFFF?text=Benz+E300&font=montserrat'
WHERE id = 'ca000000-0000-0000-0000-000000000005';
UPDATE car_images SET image_url = 'https://placehold.co/600x400/333333/FFFFFF?text=Benz+E300&font=montserrat'
WHERE id = 'ci000000-0000-0000-0000-000000000005';

-- Mercedes-Benz GLC 300
UPDATE cars SET thumbnail_url = 'https://placehold.co/600x400/333333/FFFFFF?text=Benz+GLC300&font=montserrat'
WHERE id = 'ca000000-0000-0000-0000-000000000006';
UPDATE car_images SET image_url = 'https://placehold.co/600x400/333333/FFFFFF?text=Benz+GLC300&font=montserrat'
WHERE id = 'ci000000-0000-0000-0000-000000000006';

-- Audi A4
UPDATE cars SET thumbnail_url = 'https://mediaservice.audi.com/media/live/50900/fly1400x601n1/8w5/2024.png'
WHERE id = 'ca000000-0000-0000-0000-000000000007';
UPDATE car_images SET image_url = 'https://mediaservice.audi.com/media/live/50900/fly1400x601n1/8w5/2024.png'
WHERE id = 'ci000000-0000-0000-0000-000000000007';

-- Audi Q5
UPDATE cars SET thumbnail_url = 'https://mediaservice.audi.com/media/live/50900/fly1400x601n1/fy5/2024.png'
WHERE id = 'ca000000-0000-0000-0000-000000000008';
UPDATE car_images SET image_url = 'https://mediaservice.audi.com/media/live/50900/fly1400x601n1/fy5/2024.png'
WHERE id = 'ci000000-0000-0000-0000-000000000008';

-- Lexus ES 300h
UPDATE cars SET thumbnail_url = 'https://placehold.co/600x400/1A1A1A/C4A76C?text=Lexus+ES300h&font=montserrat'
WHERE id = 'ca000000-0000-0000-0000-000000000009';
UPDATE car_images SET image_url = 'https://placehold.co/600x400/1A1A1A/C4A76C?text=Lexus+ES300h&font=montserrat'
WHERE id = 'ci000000-0000-0000-0000-000000000009';

-- Volvo XC60 (GLE 300 d 이미지 대체)
UPDATE cars SET thumbnail_url = 'https://media.oneweb.mercedes-benz.com/images/dynamic/asia/KR/167109/806_056/iris.webp?q=COSY-EU-100-1713d0VXqaSFqtyO67PobzIr3eWsrrCsdRRzwQZQ9vZbMw3SGtGyUtsd2HdcUfp8qXGEuiYJ0l3ItOB2NQObApjTXI5uVfzQC3qXFkzNwTYm7jZ7ohKVFsM%25vqCtTyLRzLyYax7NYrH1KnOn8wsOfoiZUbXM4FG4MTg90vZ6PDBSbSeWAtRtsd5cpcUfSLWXGEtbSJ0lLHJOB2a8RbApenCI5us5xQC3Uh7kzNGJKm7j0hShKVBHF%25vqA8lyLRjc6YaxVoYrH1gObnMr%25E2fchI5uKMTQmIwlzkhQg59m7jGyvhKVUs9%25vq7vlyLRKG6YaxvNxrH1LmOn8wiOcoiZ4bIM4Fg4rTg9Pzn6PDeSoSevjzFoJpENtjvaKUNjWmtdDZGZMuMapgeLlHp7RKfJnzPk&BKGND=9&uni=m&cp=o1Yw6tbhjdvotoOJyaA8nQ&IMGT=W27&POV=BE090&imwidth=600'
WHERE id = 'ca000000-0000-0000-0000-000000000010';
UPDATE car_images SET image_url = 'https://media.oneweb.mercedes-benz.com/images/dynamic/asia/KR/167109/806_056/iris.webp?q=COSY-EU-100-1713d0VXqaSFqtyO67PobzIr3eWsrrCsdRRzwQZQ9vZbMw3SGtGyUtsd2HdcUfp8qXGEuiYJ0l3ItOB2NQObApjTXI5uVfzQC3qXFkzNwTYm7jZ7ohKVFsM%25vqCtTyLRzLyYax7NYrH1KnOn8wsOfoiZUbXM4FG4MTg90vZ6PDBSbSeWAtRtsd5cpcUfSLWXGEtbSJ0lLHJOB2a8RbApenCI5us5xQC3Uh7kzNGJKm7j0hShKVBHF%25vqA8lyLRjc6YaxVoYrH1gObnMr%25E2fchI5uKMTQmIwlzkhQg59m7jGyvhKVUs9%25vq7vlyLRKG6YaxvNxrH1LmOn8wiOcoiZ4bIM4Fg4rTg9Pzn6PDeSoSevjzFoJpENtjvaKUNjWmtdDZGZMuMapgeLlHp7RKfJnzPk&BKGND=9&uni=m&cp=o1Yw6tbhjdvotoOJyaA8nQ&IMGT=W27&POV=BE090&imwidth=600'
WHERE id = 'ci000000-0000-0000-0000-000000000010';

-- +goose Down
-- 원복 필요 시 example.com URL로 복구
UPDATE cars SET thumbnail_url = 'https://example.com/placeholder.jpg'
WHERE id LIKE 'ca000000%';
UPDATE car_images SET image_url = 'https://example.com/placeholder.jpg'
WHERE id LIKE 'ci000000%';
