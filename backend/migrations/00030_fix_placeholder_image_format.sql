-- +goose Up
-- placehold.co가 SVG를 반환하여 Flutter에서 디코딩 실패
-- URL에 .png 확장자를 추가하여 PNG 형식으로 변경

UPDATE cars SET thumbnail_url = REPLACE(thumbnail_url, 'placehold.co/600x400/', 'placehold.co/600x400.png/')
WHERE thumbnail_url LIKE '%placehold.co%';

UPDATE cars SET thumbnail_url = REPLACE(thumbnail_url, 'placehold.co/400x250/', 'placehold.co/400x250.png/')
WHERE thumbnail_url LIKE '%placehold.co%';

UPDATE car_images SET image_url = REPLACE(image_url, 'placehold.co/600x400/', 'placehold.co/600x400.png/')
WHERE image_url LIKE '%placehold.co%';

UPDATE car_images SET image_url = REPLACE(image_url, 'placehold.co/400x250/', 'placehold.co/400x250.png/')
WHERE image_url LIKE '%placehold.co%';

-- +goose Down
UPDATE cars SET thumbnail_url = REPLACE(thumbnail_url, 'placehold.co/600x400.png/', 'placehold.co/600x400/')
WHERE thumbnail_url LIKE '%placehold.co%';

UPDATE cars SET thumbnail_url = REPLACE(thumbnail_url, 'placehold.co/400x250.png/', 'placehold.co/400x250/')
WHERE thumbnail_url LIKE '%placehold.co%';

UPDATE car_images SET image_url = REPLACE(image_url, 'placehold.co/600x400.png/', 'placehold.co/600x400/')
WHERE image_url LIKE '%placehold.co%';

UPDATE car_images SET image_url = REPLACE(image_url, 'placehold.co/400x250.png/', 'placehold.co/400x250/')
WHERE image_url LIKE '%placehold.co%';
