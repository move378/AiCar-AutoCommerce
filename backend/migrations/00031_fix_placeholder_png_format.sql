-- +goose Up
-- 00030의 URL 형식이 잘못됨 (/600x400.png/ → 404)
-- 올바른 형식: /600x400/색상/색상.png?text=

-- placehold.co URL을 올바른 PNG 형식으로 수정
-- 패턴: /FFFFFF?text= → /FFFFFF.png?text=
-- 패턴: /ffffff?text= → /ffffff.png?text=

UPDATE cars SET thumbnail_url = REGEXP_REPLACE(
  thumbnail_url,
  '([0-9a-fA-F]{6})\?text=',
  '\1.png?text='
)
WHERE thumbnail_url LIKE '%placehold.co%'
  AND thumbnail_url NOT LIKE '%.png?text=%';

UPDATE car_images SET image_url = REGEXP_REPLACE(
  image_url,
  '([0-9a-fA-F]{6})\?text=',
  '\1.png?text='
)
WHERE image_url LIKE '%placehold.co%'
  AND image_url NOT LIKE '%.png?text=%';

-- 00030에서 잘못 삽입된 .png/ 부분도 정리
UPDATE cars SET thumbnail_url = REPLACE(thumbnail_url, '.png/', '/')
WHERE thumbnail_url LIKE '%placehold.co%.png/%';

UPDATE car_images SET image_url = REPLACE(image_url, '.png/', '/')
WHERE image_url LIKE '%placehold.co%.png/%';

-- +goose Down
UPDATE cars SET thumbnail_url = REPLACE(thumbnail_url, '.png?text=', '?text=')
WHERE thumbnail_url LIKE '%placehold.co%';

UPDATE car_images SET image_url = REPLACE(image_url, '.png?text=', '?text=')
WHERE image_url LIKE '%placehold.co%';
