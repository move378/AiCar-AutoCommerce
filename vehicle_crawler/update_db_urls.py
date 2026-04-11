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
                # 1. vehicles_trim_images 업데이트
                updated_trim = 0
                for m in mappings:
                    cur.execute(
                        "UPDATE vehicles_trim_images SET image_url = %s WHERE image_url = %s",
                        (m["new_url"], m["old_url"]),
                    )
                    updated_trim += cur.rowcount

                # 2. cars 테이블의 placehold.co URL을 exterior_front 이미지로 교체
                # 각 브랜드의 첫 번째 exterior_front 이미지를 thumbnail로 사용
                front_images = [
                    m for m in mappings if m["angle"] == "exterior_front"
                ]

                updated_cars = 0
                for img in front_images:
                    # brand 이름으로 cars.thumbnail_url 업데이트
                    brand_display = {
                        "mercedes-benz": "Mercedes-Benz",
                        "bmw": "BMW",
                        "audi": "Audi",
                        "volvo": "Volvo",
                        "lexus": "Lexus",
                        "tesla": "Tesla",
                    }
                    brand = brand_display.get(img["brand"], img["brand"])

                    cur.execute(
                        """
                        UPDATE cars SET thumbnail_url = %s
                        WHERE id IN (
                            SELECT c.id FROM cars c
                            JOIN car_models cm ON c.model_id = cm.id
                            JOIN car_brands cb ON cm.brand_id = cb.id
                            WHERE cb.name = %s
                            AND c.thumbnail_url LIKE '%%placehold.co%%'
                        )
                        LIMIT 1
                        """,
                        (img["new_url"], brand),
                    )
                    updated_cars += cur.rowcount

                # 3. placehold.co URL이 남아있는 cars 확인
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
