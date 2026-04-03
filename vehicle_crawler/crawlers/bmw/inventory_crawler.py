import json
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

INPUT_FILE = os.path.join(BASE_DIR, "url", "inventory_urls.json")
OUTPUT_FILE = os.path.join(BASE_DIR, "data", "inventory_data.json")


def convert_inventory_data():
    print("실행 시작")

    if not os.path.exists(INPUT_FILE):
        print(f"원본 파일이 없습니다: {INPUT_FILE}")
        return

    with open(INPUT_FILE, "r", encoding="utf-8") as f:
        raw = json.load(f)

    cars = raw.get("response", {}).get("filterData", [])
    print(f"불러온 차량 수: {len(cars)}")

    results = []

    for car in cars:
        image_path = car.get("editionDispFullPath", "")

        if image_path.startswith("http"):
            image_url = image_path
        elif image_path:
            image_url = "https://shop.bmw.co.kr" + image_path
        else:
            image_url = ""

        item = {
            "name": car.get("editionNm", ""),
            "edition_id": car.get("editionId", ""),
            "engine_pcode": car.get("enginePcode", ""),
            "fuel_type": car.get("fuelType", ""),
            "price_min": car.get("priceMin", ""),
            "price_max": car.get("priceMax", ""),
            "segment_code": car.get("segmentCode", ""),
            "template_path": car.get("templatePath", ""),
            "sales_type": car.get("salesType", ""),
            "power": car.get("highestPower", "").replace('"', ""),
            "mileage": car.get("mileage", "").replace('"', ""),
            "efficiency": car.get("fullEfficiency", "").replace('"', ""),
            "image_url": image_url,
            "colors": car.get("colors", []),
            "series": car.get("series", []),
            "is_new": car.get("new", False)
        }

        results.append(item)

    os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)

    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(results, f, ensure_ascii=False, indent=4)

    print(f"inventory_data.json 저장 완료: {len(results)}개")
    print(f"저장 위치: {OUTPUT_FILE}")


if __name__ == "__main__":
    convert_inventory_data()

    