import json
import re
from pathlib import Path
from typing import Any, Dict, List, Optional


BASE_DIR = Path(__file__).resolve().parent
RAW_DIR = BASE_DIR / "data" / "raw"
SUMMARY_DIR = BASE_DIR / "data" / "summary"
SUMMARY_PATH = SUMMARY_DIR / "summary.json"


def load_json(path: Path, default=None):
    if default is None:
        default = {}
    if not path.exists():
        return default
    return json.loads(path.read_text(encoding="utf-8"))


def save_json(path: Path, data: Any):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")


def clean_text(value: Any) -> str:
    if value is None:
        return ""
    text = str(value)
    text = text.replace("\r", "\n").replace("​", " ")
    text = re.sub(r"[ \t]+", " ", text)
    text = re.sub(r"\n\s*\n+", "\n", text)
    return text.strip()


def parse_int(value: Any) -> Optional[int]:
    if value is None:
        return None
    s = re.sub(r"[^\d]", "", str(value))
    return int(s) if s else None


def unique_keep_order(values: List[str]) -> List[str]:
    seen = set()
    result = []
    for v in values:
        v = clean_text(v)
        if not v:
            continue
        if v not in seen:
            seen.add(v)
            result.append(v)
    return result


def build_vehicle_summary(raw: Dict[str, Any]) -> Dict[str, Any]:
    vehicle = raw.get("vehicle", {}) or {}
    inventory_variants = raw.get("inventory_variants", []) or []
    trims = raw.get("trims", []) or []
    usps = raw.get("usps", []) or []

    edition_id = vehicle.get("edition_id")
    edition_name = clean_text(vehicle.get("edition_name"))
    edition_price = parse_int(vehicle.get("edition_price"))

    # inventory 기반 공통 필드
    sales_type = clean_text(vehicle.get("sales_type")) or clean_text(
        inventory_variants[0].get("sales_type") if inventory_variants else ""
    )
    template_path = clean_text(
        inventory_variants[0].get("template_path") if inventory_variants else ""
    )
    segment_codes = unique_keep_order([v.get("segment_code", "") for v in inventory_variants])
    fuel_types = unique_keep_order([v.get("fuel_type", "") for v in inventory_variants])

    # 대표 제원
    powers = unique_keep_order([v.get("power", "") for v in inventory_variants])
    mileages = unique_keep_order([v.get("mileage", "") for v in inventory_variants])
    efficiencies = unique_keep_order([v.get("efficiency", "") for v in inventory_variants])

    # 색상 / 시리즈
    colors = []
    series = []
    for v in inventory_variants:
        colors.extend(v.get("colors", []) or [])
        series.extend(v.get("series", []) or [])
    colors = unique_keep_order(colors)
    series = unique_keep_order(series)

    # trim 정리
    trim_categories = unique_keep_order([t.get("category_title", "") for t in trims])

    model_trims = []
    exterior_trims = []
    interior_trims = []
    package_trims = []
    other_trims = []

    for t in trims:
        item = {
            "category_title": clean_text(t.get("category_title")),
            "category_code": clean_text(t.get("category_code")),
            "pcode": clean_text(t.get("pcode")),
            "trim_name": clean_text(t.get("trim_name")),
            "trim_img": clean_text(t.get("trim_img")),
            "activation": t.get("activation"),
            "status": t.get("status"),
            "sf_yn": clean_text(t.get("sf_yn")),
        }

        cat = item["category_title"]
        if cat in ("모델", "엔진", "모델 명"):
            model_trims.append(item)
        elif cat == "익스테리어":
            exterior_trims.append(item)
        elif cat == "인테리어":
            interior_trims.append(item)
        elif cat == "패키지":
            package_trims.append(item)
        else:
            other_trims.append(item)

    # USP 정리
    feature_items = []
    section_titles = []
    highlight_titles = []

    for u in usps:
        section_title = clean_text(u.get("section_title"))
        section_subtitle = clean_text(u.get("section_subtitle"))
        item_title = clean_text(u.get("item_title"))
        item_description = clean_text(u.get("item_description"))

        if section_title:
            section_titles.append(section_title)

        # "모델 하이라이트" 계열
        if "모델 하이라이트" in section_title:
            highlight_titles.append(section_title)

        if item_title or item_description:
            feature_items.append({
                "section_seq": u.get("section_seq"),
                "section_type": clean_text(u.get("section_type")),
                "section_title": section_title,
                "section_subtitle": section_subtitle,
                "item_seq": u.get("item_seq"),
                "item_type": clean_text(u.get("item_type")),
                "item_title": item_title,
                "item_description": item_description,
                "item_image": clean_text(u.get("item_image")),
                "link": clean_text(u.get("link")),
            })

    section_titles = unique_keep_order(section_titles)

    # 대표 feature title 추출
    top_features = unique_keep_order(
        [f["item_title"] for f in feature_items if f["item_title"]]
    )[:10]

    # 대표 요약문
    summary_lines = [edition_name]

    if edition_price:
        summary_lines.append(f"가격: {edition_price:,}원")
    if fuel_types:
        summary_lines.append(f"연료: {', '.join(fuel_types)}")
    if powers:
        summary_lines.append(f"출력: {', '.join(powers)}")
    if efficiencies:
        summary_lines.append(f"효율: {', '.join(efficiencies[:3])}")
    if top_features:
        summary_lines.append(f"주요 특징: {', '.join(top_features[:5])}")

    short_description = " | ".join(summary_lines)

    return {
        "edition_id": edition_id,
        "edition_name": edition_name,
        "sales_type": sales_type,
        "template_path": template_path,
        "edition_price": edition_price,
        "main_image": clean_text(vehicle.get("main_image")),
        "btn_title": clean_text(vehicle.get("btn_title")),
        "stock_flag": vehicle.get("stock_flag"),
        "electric_yn": clean_text(vehicle.get("electric_yn")),

        "segment_codes": segment_codes,
        "fuel_types": fuel_types,
        "powers": powers,
        "mileages": mileages,
        "efficiencies": efficiencies,
        "colors": colors,
        "series": series,

        "inventory_variants": inventory_variants,

        "trim_count": raw.get("trim_count", 0),
        "usp_count": raw.get("usp_count", 0),
        "trim_categories": trim_categories,
        "model_trims": model_trims,
        "exterior_trims": exterior_trims,
        "interior_trims": interior_trims,
        "package_trims": package_trims,
        "other_trims": other_trims,

        "section_titles": section_titles,
        "top_features": top_features,
        "features": feature_items,

        "short_description": short_description,
    }


def build_summary():
    results = []

    for file_path in sorted(RAW_DIR.glob("*.json")):
        try:
            raw = load_json(file_path, {})
            summary_item = build_vehicle_summary(raw)
            summary_item["source_file"] = file_path.name
            results.append(summary_item)
            print(f"[OK] {file_path.name} -> {summary_item['edition_name']}")
        except Exception as e:
            print(f"[FAIL] {file_path.name}: {e}")

    save_json(SUMMARY_PATH, results)
    print(f"\nsummary 저장 완료: {SUMMARY_PATH}")
    print(f"총 {len(results)}개")


if __name__ == "__main__":
    build_summary()