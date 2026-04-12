"""
DB 이미지 URL 업데이트 스크립트

download_images.py 실행 후 생성된 image_url_mapping.json을 읽어
vehicles_trim_images 테이블의 image_url을 로컬 URL로 업데이트한다.
추가로 cars 테이블의 thumbnail_url도 업데이트한다.

사용법:
  cd vehicle_crawler
  python update_db_urls.py
"""

import json
import psycopg2
from config import DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD

MAPPING_FILE = "image_url_mapping.json"
SERVER_BASE_URL = "http://18.191.163.53:8080"


def main():
    # URL 매핑 로드
    with open(MAPPING_FILE, "r", encoding="utf-8") as f:
        mappings = json.load(f)

    print(f"URL 매핑 {len(mappings)}개 로드")

    conn = psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
    )

    try:
        with conn:
            with conn.cursor() as cur:
                # 1. vehicles_trim_images 업데이트 (테이블 존재 시)
                updated_trim = 0
                try:
                    for m in mappings:
                        cur.execute(
                            "UPDATE vehicles_trim_images SET image_url = %s WHERE image_url = %s",
                            (m["new_url"], m["old_url"]),
                        )
                        updated_trim += cur.rowcount
                except Exception as e:
                    print(f"vehicles_trim_images 스킵 (테이블 미존재): {e}")
                    conn.rollback()

                # 2. cars 테이블의 placehold.co URL을 exterior_front 이미지로 교체
                front_images = [
                    m for m in mappings if m["angle"] == "exterior_front"
                ]

                # 현재 cars 테이블의 모델 정보 조회
                cur.execute("""
                    SELECT c.id, cm.model_name, cb.name as brand_name, c.thumbnail_url
                    FROM cars c
                    JOIN car_models cm ON c.model_id = cm.id
                    JOIN car_brands cb ON cm.brand_id = cb.id
                    WHERE c.thumbnail_url LIKE '%%placehold.co%%'
                       OR c.thumbnail_url IS NULL
                """)
                cars_to_update = cur.fetchall()
                print(f"업데이트 대상 차량: {len(cars_to_update)}대")

                updated_cars = 0
                for car_id, model_name, brand_name, _ in cars_to_update:
                    # 브랜드+모델 매칭으로 이미지 찾기
                    model_lower = model_name.lower().replace(" ", "_")
                    matched = None
                    for img in front_images:
                        if img["model"] in model_lower or model_lower in img["model"]:
                            matched = img
                            break
                    # 브랜드 매칭 fallback
                    if not matched:
                        brand_lower = brand_name.lower().replace("-", "-")
                        for img in front_images:
                            if brand_lower in img["brand"] or img["brand"] in brand_lower:
                                matched = img
                                break
                    if matched:
                        cur.execute(
                            "UPDATE cars SET thumbnail_url = %s WHERE id = %s",
                            (matched["new_url"], car_id),
                        )
                        updated_cars += cur.rowcount
                        print(f"  [{brand_name} {model_name}] → {matched['new_url'][:80]}...")

                # 3. 남은 placehold.co 확인
                cur.execute(
                    "SELECT COUNT(*) FROM cars WHERE thumbnail_url LIKE '%%placehold.co%%'"
                )
                remaining = cur.fetchone()[0]

                print(f"\n{'='*50}")
                print(f"vehicles_trim_images 업데이트: {updated_trim}건")
                print(f"cars thumbnail 업데이트: {updated_cars}건")
                print(f"남은 placehold.co URL: {remaining}건")

    finally:
        conn.close()


if __name__ == "__main__":
    main()
