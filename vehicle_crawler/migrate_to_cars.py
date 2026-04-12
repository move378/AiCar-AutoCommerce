"""
크롤링된 벤츠 60대 데이터를 cars 테이블에 마이그레이션

vehicles_debug.json → brands, car_models, cars, car_images 테이블에 INSERT
이미 다운로드된 로컬 이미지 URL을 thumbnail_url 및 car_images에 매핑

사용법:
  cd vehicle_crawler
  source venv/bin/activate
  python migrate_to_cars.py
"""

import json
import os
import re
import uuid
import psycopg2
from psycopg2.extras import RealDictCursor
from config import DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD

VEHICLES_JSON = "vehicles_debug.json"
IMAGE_MAPPING_JSON = "image_url_mapping.json"
SERVER_BASE_URL = "http://18.191.163.53:8080"
BRAND_ID_BENZ = "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"


def safe_filename(text):
    text = text.strip().lower()
    text = re.sub(r"[\\/:*?\"<>|+\s]+", "_", text)
    text = re.sub(r"_+", "_", text)
    return text[:100] if text else "unknown"


def get_connection():
    return psycopg2.connect(
        host=DB_HOST, port=DB_PORT, dbname=DB_NAME,
        user=DB_USER, password=DB_PASSWORD,
    )


def load_image_mapping():
    """image_url_mapping.json에서 로컬 URL 매핑 로드"""
    if not os.path.exists(IMAGE_MAPPING_JSON):
        return {}
    with open(IMAGE_MAPPING_JSON, "r", encoding="utf-8") as f:
        mappings = json.load(f)
    # key: "{model}_{trim}_{angle}" → new_url
    result = {}
    for m in mappings:
        key = f"{m['model']}_{m['trim']}_{m['angle']}"
        result[key] = m["new_url"]
    return result


def map_body_type_to_fuel(fuel_type_raw):
    """크롤러 연료 타입을 DB 형식으로 변환"""
    if not fuel_type_raw:
        return "가솔린"
    ft = fuel_type_raw.lower()
    if "ev" in ft or "전기" in ft:
        return "전기"
    if "디젤" in ft or "diesel" in ft:
        return "디젤"
    if "하이브리드" in ft or "hybrid" in ft:
        return "하이브리드"
    return "가솔린"


def main():
    with open(VEHICLES_JSON, "r", encoding="utf-8") as f:
        vehicles = json.load(f)

    image_map = load_image_mapping()
    print(f"차량 {len(vehicles)}대, 이미지 매핑 {len(image_map)}개 로드")

    conn = get_connection()

    try:
        with conn:
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                # 기존 car_models 조회 (벤츠)
                cur.execute(
                    "SELECT id, name FROM car_models WHERE brand_id = %s",
                    (BRAND_ID_BENZ,),
                )
                existing_models = {r["name"]: r["id"] for r in cur.fetchall()}
                print(f"기존 벤츠 모델: {list(existing_models.keys())}")

                # 기존 cars 조회 (중복 방지)
                cur.execute(
                    "SELECT trim_name FROM cars c JOIN car_models cm ON c.model_id = cm.id WHERE cm.brand_id = %s",
                    (BRAND_ID_BENZ,),
                )
                existing_trims = {r["trim_name"] for r in cur.fetchall()}
                print(f"기존 벤츠 트림: {len(existing_trims)}개")

                created_models = 0
                created_cars = 0
                created_images = 0
                skipped = 0

                for v in vehicles:
                    model_name = v["model"]["name"]
                    trim = v["trim"]
                    trim_name = trim["name"]

                    # 이미 존재하는 트림은 스킵
                    if trim_name in existing_trims:
                        skipped += 1
                        continue

                    # car_models 생성 (없으면)
                    if model_name not in existing_models:
                        model_id = str(uuid.uuid4())
                        cur.execute(
                            """INSERT INTO car_models (id, brand_id, name, segment)
                               VALUES (%s, %s, %s, %s)
                               ON CONFLICT DO NOTHING RETURNING id""",
                            (model_id, BRAND_ID_BENZ, model_name,
                             v["model"].get("segment")),
                        )
                        row = cur.fetchone()
                        if row:
                            existing_models[model_name] = row["id"]
                            created_models += 1
                        else:
                            cur.execute(
                                "SELECT id FROM car_models WHERE brand_id = %s AND name = %s",
                                (BRAND_ID_BENZ, model_name),
                            )
                            existing_models[model_name] = cur.fetchone()["id"]

                    model_id = existing_models[model_name]

                    # 이미지 URL 매핑
                    model_safe = safe_filename(model_name)
                    trim_safe = safe_filename(trim_name)
                    front_key = f"{model_safe}_{trim_safe}_exterior_front"
                    thumbnail_url = image_map.get(front_key)

                    # 가격 변환 (크롤러는 원 단위)
                    price = trim.get("base_price") or 0

                    # 연식
                    year_raw = trim.get("model_year", "2025")
                    try:
                        year = int(year_raw) if int(year_raw) > 1900 else 2025
                    except (ValueError, TypeError):
                        year = 2025

                    # cars 생성
                    car_id = str(uuid.uuid4())
                    cur.execute(
                        """INSERT INTO cars (id, model_id, trim_name, year, price,
                                            fuel_type, fuel_efficiency, transmission,
                                            engine_displacement, thumbnail_url)
                           VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)""",
                        (
                            car_id, model_id, trim_name, year, price,
                            map_body_type_to_fuel(trim.get("fuel_type")),
                            None,  # fuel_efficiency
                            trim.get("transmission_type"),
                            None,  # engine_displacement
                            thumbnail_url,
                        ),
                    )
                    created_cars += 1
                    existing_trims.add(trim_name)

                    # car_images 생성
                    angles = [
                        ("exterior_front", 0, True),
                        ("exterior_side", 1, False),
                        ("interior", 2, False),
                    ]
                    for angle, sort_order, is_thumb in angles:
                        img_key = f"{model_safe}_{trim_safe}_{angle}"
                        img_url = image_map.get(img_key)
                        if img_url:
                            cur.execute(
                                """INSERT INTO car_images (id, car_id, image_url,
                                                          is_thumbnail, sort_order)
                                   VALUES (%s, %s, %s, %s, %s)""",
                                (str(uuid.uuid4()), car_id, img_url,
                                 is_thumb, sort_order),
                            )
                            created_images += 1

                    if created_cars % 10 == 0:
                        print(f"  진행: {created_cars}대 생성...")

                # ICE/EV 스펙: cars 테이블에 fuel_efficiency 업데이트
                for v in vehicles:
                    trim = v["trim"]
                    ice = trim.get("ice_spec")
                    ev = trim.get("ev_spec")
                    efficiency = None
                    displacement = None
                    if ice:
                        efficiency = ice.get("efficiency_combined")
                        displacement = ice.get("displacement")
                    elif ev:
                        efficiency = ev.get("efficiency_combined")

                    if efficiency or displacement:
                        cur.execute(
                            """UPDATE cars SET fuel_efficiency = %s,
                                              engine_displacement = %s
                               WHERE trim_name = %s AND model_id IN (
                                   SELECT id FROM car_models WHERE brand_id = %s
                               )""",
                            (efficiency, displacement, trim["name"], BRAND_ID_BENZ),
                        )

                print(f"\n{'='*50}")
                print(f"모델 생성: {created_models}개")
                print(f"차량 생성: {created_cars}대")
                print(f"이미지 생성: {created_images}개")
                print(f"스킵 (기존): {skipped}개")

                # 최종 확인
                cur.execute("SELECT COUNT(*) as cnt FROM cars")
                total = cur.fetchone()["cnt"]
                print(f"전체 cars: {total}대")

    finally:
        conn.close()


if __name__ == "__main__":
    main()
