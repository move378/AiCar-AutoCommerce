import json
import re
from pathlib import Path

BMW_IMAGE_BASE = "https://shop.bmw.co.kr"

SERVICE_HIGHLIGHT_BLACKLIST = {
    "웰컴 서비스 콜.",
    "플러스 체크 서비스.",
    "픽업 & 딜리버리 서비스.",
    "로너 카 서비스.",
    "사고차 케어 서비스.",
    "BMW 핸드오버 세레머니.",
    "BMW 에어포트 서비스.",
    "전용 렌터카 서비스.",
    "BMW 조이 스퀘어.",
    "BMW 드라이빙 센터 식음료 쿠폰.",
    "럭셔리 라이프 스타일.",
    "큐레이션 바이 엑셀런스.",
    "BMW iX1",
    "익스테리어.",
    "인테리어.",
    "디지털 하이라이트.",
    "어시스턴트.",
}

INVALID_TRIM_CODES = {"BMW", "THE", "NEW", "30TH"}

SERIES_FAMILY_MAP = {
    "BMW 3 SERIES": "3 Series",
    "BMW 4 SERIES": "4 Series",
    "BMW 5 SERIES": "5 Series",
    "BMW 5시리즈": "5 Series",
    "BMW 7 SERIES": "7 Series",
    "BMW 8 SERIES": "8 Series",
    "BMW X3": "X3",
    "BMW X5": "X5",
    "BMW X6": "X6",
    "BMW X7": "X7",
    "BMW XM": "XM",
    "BMW I5": "i5",
    "BMW I7": "i7",
    "BMW IX": "iX",
    "BMW IX1": "iX1",
    "BMW IX2": "iX2",
    "BMW IX3": "iX3",
    "BMW Z4": "Z4",
}

# specs 전용 override
MANUAL_SPEC_OVERRIDES = {
    "M340I": {
        "power_ps": 387,
        "torque_kgm": 50.99,
        "acceleration_0_100_sec": 4.4,
        "top_speed_kmh": 250,
    },
    "M850I": {
        "power_ps": 625,
        "torque_kgm": 76.5,
        "acceleration_0_100_sec": 3.2,
        "top_speed_kmh": 305,
    },
    "M240I": {
        "power_ps": 480,
        "torque_kgm": 61.2,
        "acceleration_0_100_sec": 4.0,
        "top_speed_kmh": 250,
    },
    "M440I 쿠페": {
        "power_ps": 387,
        "torque_kgm": 51.0,
        "acceleration_0_100_sec": 4.5,
        "top_speed_kmh": 250,
    },
    "M440I 컨버터블": {
        "power_ps": 387,
        "torque_kgm": 51.0,
        "acceleration_0_100_sec": 4.9,
        "top_speed_kmh": 250,
    },
    "M235": {
        "power_ps": 317,
        "torque_kgm": 40.8,
        "acceleration_0_100_sec": 4.9,
        "top_speed_kmh": 250,
    },
    "Z4 M40I": {
        "power_ps": 387,
        "torque_kgm": 51.0,
        "acceleration_0_100_sec": 4.1,
        "top_speed_kmh": 250,
    },
    "IX XDRIVE45": {
        "power_ps": 408,
        "torque_kgm": 71.4,
        "acceleration_0_100_sec": 5.1,
        "top_speed_kmh": 200,
    },
    "IX XDRIVE60": {
        "power_ps": 544,
        "torque_kgm": 78.0,
        "acceleration_0_100_sec": 4.6,
        "top_speed_kmh": 200,
    },
    "IX M70": {
        "power_ps": 659,
        "torque_kgm": 103.5,
        "acceleration_0_100_sec": 3.8,
        "top_speed_kmh": 250,
    },
    "IX1 XDRIVE30": {
        "power_ps": 313,
        "torque_kgm": 50.4,
        "acceleration_0_100_sec": 5.6,
        "top_speed_kmh": 180,
    },
    "IX1 EDRIVE20": {
        "power_ps": 204,
        "torque_kgm": 25.5,
        "acceleration_0_100_sec": 8.6,
        "top_speed_kmh": 170,
    },
    "IX2 EDRIVE20": {
        "power_ps": 204,
        "torque_kgm": 25.5,
        "acceleration_0_100_sec": 8.6,
        "top_speed_kmh": 170,
    },
    "I5 EDRIVE40": {
        "power_ps": 340,
        "torque_kgm": 40.8,
        "acceleration_0_100_sec": 6.0,
        "top_speed_kmh": 193,
    },
    "I5 XDRIVE40": {
        "power_ps": 394,
        "torque_kgm": 60.2,
        "acceleration_0_100_sec": 5.4,
        "top_speed_kmh": 215,
    },
    "I5 M60 XDRIVE": {
        "power_ps": 601,
        "torque_kgm": 83.6,
        "acceleration_0_100_sec": 3.8,
        "top_speed_kmh": 230,
    },
    "I7 EDRIVE50": {
        "power_ps": 455,
        "torque_kgm": 66.3,
        "acceleration_0_100_sec": 5.5,
        "top_speed_kmh": 205,
    },
    "I7 XDRIVE60": {
        "power_ps": 544,
        "torque_kgm": 76.0,
        "acceleration_0_100_sec": 4.7,
        "top_speed_kmh": 240,
    },
    "I7 M70": {
        "power_ps": 659,
        "torque_kgm": 112.2,
        "acceleration_0_100_sec": 3.7,
        "top_speed_kmh": 250,
    },
    "X7 M60I": {
        "power_ps": 530,
        "torque_kgm": 76.5,
        "acceleration_0_100_sec": 4.7,
        "top_speed_kmh": 250,
    },
    "X5 40D": {
        "battery_kwh": None,
        "range_km": None,
        "efficiency_km_per_kwh": None,
        "efficiency_city_km_per_kwh": None,
        "efficiency_highway_km_per_kwh": None,
        "fast_charge_min": None,
        "slow_charge_hour": None,
    },
    "X6 40D": {
        "battery_kwh": None,
        "range_km": None,
        "efficiency_km_per_kwh": None,
        "efficiency_city_km_per_kwh": None,
        "efficiency_highway_km_per_kwh": None,
        "fast_charge_min": None,
        "slow_charge_hour": None,
    },
    "X7 XDRIVE40D": {
        "battery_kwh": None,
        "range_km": None,
        "efficiency_km_per_kwh": None,
        "efficiency_city_km_per_kwh": None,
        "efficiency_highway_km_per_kwh": None,
        "fast_charge_min": None,
        "slow_charge_hour": None,
    },
    "XM LABEL": {
        "power_ps": 585,
        "torque_kgm": 76.5,
        "acceleration_0_100_sec": 3.8,
        "top_speed_kmh": 250,
        "battery_kwh": 29.5,
        "range_km": 60,
    },
}

# top-level 전용 override
MANUAL_TOP_LEVEL_OVERRIDES = {
    "M240I": {
        "model_family": "2 Series",
        "drive_type": "RWD",
        "fuel_type": "gasoline",
        "body_type": "coupe",
        "segment": "compact",
    },
    "M440I 쿠페": {
        "model_family": "4 Series",
        "drive_type": "AWD",
        "fuel_type": "gasoline",
        "body_type": "coupe",
        "segment": "mid_size",
    },
    "M440I 컨버터블": {
        "model_family": "4 Series",
        "drive_type": "AWD",
        "fuel_type": "gasoline",
        "body_type": "convertible",
        "segment": "mid_size",
    },
    "IX1 XDRIVE30": {
        "drive_type": "AWD",
        "fuel_type": "electric",
        "segment": "compact",
    },
    "IX1 EDRIVE20": {
        "drive_type": "FWD",
        "fuel_type": "electric",
        "segment": "compact",
    },
    "BMW IX1": {
        "fuel_type": "electric",
        "segment": "compact",
    },
    "IX2 EDRIVE20": {
        "drive_type": "FWD",
        "fuel_type": "electric",
        "segment": "compact",
    },
    "BMW IX2": {
        "fuel_type": "electric",
        "segment": "compact",
    },
    "IX XDRIVE45": {
        "drive_type": "AWD",
        "fuel_type": "electric",
    },
    "IX XDRIVE60": {
        "drive_type": "AWD",
        "fuel_type": "electric",
    },
    "IX M70": {
        "drive_type": "AWD",
        "fuel_type": "electric",
    },
    "IX3": {
        "drive_type": "AWD",
        "fuel_type": "electric",
    },
    "I5 EDRIVE40": {
        "drive_type": "RWD",
        "fuel_type": "electric",
    },
    "I5 XDRIVE40": {
        "drive_type": "AWD",
        "fuel_type": "electric",
    },
    "I5 M60 XDRIVE": {
        "drive_type": "AWD",
        "fuel_type": "electric",
    },
    "BMW I5": {
        "fuel_type": "electric",
    },
    "I7 EDRIVE50": {
        "drive_type": "RWD",
        "fuel_type": "electric",
    },
    "I7 XDRIVE60": {
        "drive_type": "AWD",
        "fuel_type": "electric",
    },
    "I7 M70": {
        "drive_type": "AWD",
        "fuel_type": "electric",
    },
    "BMW I7": {
        "fuel_type": "electric",
    },
    "X5 40D": {
        "fuel_type": "diesel",
        "drive_type": "AWD",
    },
    "X6 40D": {
        "fuel_type": "diesel",
        "drive_type": "AWD",
    },
    "X7 XDRIVE40D": {
        "fuel_type": "diesel",
        "drive_type": "AWD",
    },
    "X7 XDRIVE40I": {
        "fuel_type": "gasoline",
        "drive_type": "AWD",
    },
    "X7 M60I": {
        "fuel_type": "gasoline",
        "drive_type": "AWD",
    },
    "XM LABEL": {
        "fuel_type": "plug_in_hybrid",
        "drive_type": "AWD",
    },
}


def parse_number(value):
    if value is None:
        return None
    if isinstance(value, (int, float)):
        return value
    s = str(value).strip().replace(",", "")
    m = re.search(r"[-+]?\d+(?:\.\d+)?", s)
    if not m:
        return None
    num = float(m.group())
    return int(num) if num.is_integer() else num


def make_absolute_image_url(path):
    if not path:
        return None
    if str(path).startswith(("http://", "https://")):
        return path
    return f"{BMW_IMAGE_BASE}{path}"


def get_danawa_value(danawa_spec, *keys):
    for key in keys:
        value = danawa_spec.get(key)
        if value:
            return value
    return None


def normalize_transmission(value):
    if not value:
        return None
    v = str(value).strip()
    if "자동" in v:
        return "automatic"
    if "수동" in v:
        return "manual"
    return v.lower()


def normalize_drive_type(value):
    if not value:
        return None
    v = str(value).strip().upper()
    mapping = {
        "FR": "RWD",
        "MR": "RWD",
        "RR": "RWD",
        "FF": "FWD",
        "FWD": "FWD",
        "4WD": "AWD",
        "AWD": "AWD",
    }
    return mapping.get(v, v)


def clean_title(text):
    if not text:
        return ""
    t = str(text).replace("_", " ").strip()
    t = re.sub(r"\s+", " ", t)
    return t


def strip_bmw_prefix(text):
    if not text:
        return text
    t = text.strip()
    t = re.sub(r"^THE NEW BMW\s+", "", t, flags=re.I)
    t = re.sub(r"^THE NEW\s+", "", t, flags=re.I)
    t = re.sub(r"^BMW\s+", "", t, flags=re.I)
    return t.strip()


def context_text(data, source_path=None, trim_name=None):
    vehicle = data.get("vehicle", {}) or {}
    return " ".join(
        x for x in [
            source_path.stem if source_path else "",
            vehicle.get("edition_name", ""),
            trim_name or "",
            data.get("danawa_model_name", ""),
        ] if x
    ).upper()


def extract_trim_info(filename=None):
    trim_name = None
    trim_code = None

    if not filename:
        return {"trim_name": None, "trim_code": None}

    stem = Path(filename).stem
    parts = stem.split("_")

    if len(parts) >= 3:
        second = parts[1].upper()
        if re.fullmatch(r"[0-9A-Z]{3,5}", second) and second not in INVALID_TRIM_CODES:
            trim_code = second
            trim_name = clean_title("_".join(parts[2:]))
        else:
            trim_name = clean_title("_".join(parts[1:]))

    trim_name = strip_bmw_prefix(trim_name)

    if trim_name in {"iX", "iX1", "iX2", "iX3", "i5", "i7", "X7"}:
        trim_name = None

    return {
        "trim_name": trim_name or None,
        "trim_code": trim_code,
    }


def infer_model_family(data, source_path=None, trim_name=None):
    vehicle = data.get("vehicle", {}) or {}
    model_family = vehicle.get("model_family")
    danawa_model_name = (data.get("danawa_model_name") or "").upper()
    model_name = (vehicle.get("edition_name") or "").upper()
    text = context_text(data, source_path=source_path, trim_name=trim_name)

    bad_family = {
        "320I", "340I", "440I", "520I", "530I", "550E", "740I", "750E",
        "850I", "40D", "40I", "M60I", "20", "20I"
    }
    if model_family and model_family.upper() in bad_family:
        model_family = None

    if model_family:
        return model_family

    for key, value in SERIES_FAMILY_MAP.items():
        if key in danawa_model_name or key in model_name or key in text:
            return value

    if "M440I" in text:
        return "4 Series"
    if "M340I" in text or "320I" in text or "M3" in text:
        return "3 Series"
    if "520I" in text or "530I" in text or "550E" in text:
        return "5 Series"
    if "740I" in text or "750E" in text or "I7" in text:
        return "7 Series"
    if "M850I" in text:
        return "8 Series"
    if "M240I" in text or "M235" in text:
        return "2 Series"
    if "Z4" in text:
        return "Z4"

    return None


def normalize_fuel_type(data, source_path=None, trim_name=None):
    vehicle = data.get("vehicle", {}) or {}
    danawa = data.get("danawa_spec", {}) or {}

    raw = get_danawa_value(danawa, "연료") or vehicle.get("fuel_type") or ""
    text = context_text(data, source_path=source_path, trim_name=trim_name)

    if any(x in text for x in ["IX1", "IX2", "IX3", " I5", " I7", " IX ", "EDRIVE", "전기(배터리)", "BEV"]):
        return "electric"

    if any(x in text for x in ["550E", "750E", "XM", "가솔린+전기", "휘발유+전기"]):
        return "plug_in_hybrid"

    if any(x in text for x in ["40D", "30D", "20D", "DIESEL", "경유"]):
        return "diesel"

    if "가솔린" in raw or "휘발유" in raw or "GASOLINE" in str(raw).upper():
        return "gasoline"

    if "전기" in raw:
        return "electric"

    return raw.lower() if raw else None


def infer_drive_type(data, source_path=None, trim_name=None):
    danawa = data.get("danawa_spec", {}) or {}
    base = normalize_drive_type(get_danawa_value(danawa, "굴림방식"))
    text = context_text(data, source_path=source_path, trim_name=trim_name)

    if "XDRIVE" in text:
        return "AWD"
    if "EDRIVE" in text:
        if "IX1" in text or "IX2" in text:
            return "FWD"
        return "RWD"
    if "M70" in text:
        return "AWD"

    return base


def infer_body_type(model_name, trim_name=None, model_family=None):
    text = " ".join(x for x in [model_name, trim_name, model_family] if x).upper()

    if any(x in text for x in ["X1", "X2", "X3", "X5", "X6", "X7", "XM", "IX", "IX1", "IX2", "IX3"]):
        return "suv"
    if "컨버터블" in text:
        return "convertible"
    if "ROADSTER" in text or "Z4" in text:
        return "roadster"
    if any(x in text for x in ["COUPE", "쿠페", "M240I", "M235"]):
        return "coupe"
    return "sedan"


def infer_segment(model_family, model_name=None, trim_name=None):
    text = " ".join(x for x in [model_family, model_name, trim_name] if x).upper()

    if any(x in text for x in ["IX1", "IX2", "X1", "X2", "2 SERIES", "M240I", "M235"]):
        return "compact"
    if any(x in text for x in ["7 SERIES", "I7", "X7", "XM", "8 SERIES"]):
        return "large"
    if any(x in text for x in ["5 SERIES", "I5", "X5", "X6", "IX"]):
        return "mid_large"
    if any(x in text for x in ["3 SERIES", "4 SERIES", "M3", "M4", "X3", "X4", "IX3", "Z4"]):
        return "mid_size"

    return None


def choose_power_ps(danawa, fuel_type):
    if fuel_type == "electric":
        return parse_number(get_danawa_value(danawa, "모터 최고출력", "최고출력"))
    return parse_number(get_danawa_value(danawa, "최고출력", "모터 최고출력"))


def choose_torque_kgm(danawa, fuel_type):
    if fuel_type == "electric":
        return parse_number(get_danawa_value(danawa, "모터 최대토크", "최대토크"))
    return parse_number(get_danawa_value(danawa, "최대토크", "모터 최대토크"))


def apply_manual_spec_overrides(specs, source_path=None, trim_name=None):
    text = " ".join(
        x for x in [
            source_path.stem if source_path else "",
            trim_name or "",
        ] if x
    ).upper()

    for key, override in MANUAL_SPEC_OVERRIDES.items():
        if key in text:
            for k, v in override.items():
                specs[k] = v
            break

    return specs


def cleanup_specs_for_fuel_type(specs, fuel_type):
    specs = dict(specs)

    specs.pop("fuel_type", None)
    specs.pop("drive_type", None)

    if fuel_type in {"gasoline", "diesel"}:
        specs["battery_kwh"] = None
        specs["range_km"] = None
        specs["efficiency_km_per_kwh"] = None
        specs["efficiency_city_km_per_kwh"] = None
        specs["efficiency_highway_km_per_kwh"] = None
        specs["fast_charge_min"] = None
        specs["slow_charge_hour"] = None

    return specs


def build_specs(data, fuel_type, source_path=None, trim_name=None):
    danawa = data.get("danawa_spec", {}) or {}

    specs = {
        "power_ps": choose_power_ps(danawa, fuel_type),
        "torque_kgm": choose_torque_kgm(danawa, fuel_type),
        "acceleration_0_100_sec": parse_number(get_danawa_value(danawa, "제로백")),
        "top_speed_kmh": parse_number(get_danawa_value(danawa, "최고속도")),
        "battery_kwh": parse_number(get_danawa_value(danawa, "배터리 용량")),
        "range_km": parse_number(get_danawa_value(danawa, "복합 주행거리")),
        "efficiency_km_per_kwh": parse_number(get_danawa_value(danawa, "복합전비")),
        "efficiency_city_km_per_kwh": parse_number(get_danawa_value(danawa, "도심전비")),
        "efficiency_highway_km_per_kwh": parse_number(get_danawa_value(danawa, "고속전비")),
        "energy_efficiency_grade": parse_number(get_danawa_value(danawa, "에너지소비효율")),
        "fast_charge_min": parse_number(get_danawa_value(danawa, "충전시간 (급속)")),
        "slow_charge_hour": parse_number(get_danawa_value(danawa, "충전시간 (완속)")),
        "length_mm": parse_number(get_danawa_value(danawa, "전장")),
        "width_mm": parse_number(get_danawa_value(danawa, "전폭")),
        "height_mm": parse_number(get_danawa_value(danawa, "전고")),
        "wheelbase_mm": parse_number(get_danawa_value(danawa, "축거")),
        "curb_weight_kg": parse_number(get_danawa_value(danawa, "공차중량")),
        "trunk_l": parse_number(get_danawa_value(danawa, "트렁크 (후) 용량", "트렁크 (전) 용량")),
        "seats": parse_number(get_danawa_value(danawa, "승차정원")),
    }

    specs = apply_manual_spec_overrides(specs, source_path=source_path, trim_name=trim_name)
    specs = cleanup_specs_for_fuel_type(specs, fuel_type)
    return specs


def is_service_image(path_text):
    if not path_text:
        return False
    t = str(path_text)
    if "/edition/MTPL" in t:
        return True
    return False


def is_vehicle_image(raw_or_abs_image, edition_id):
    if not raw_or_abs_image:
        return False

    text = str(raw_or_abs_image)

    if is_service_image(text):
        return False

    if edition_id and (f"/edition/M{edition_id}/" in text or f"/edition/{edition_id}/" in text):
        return True

    if "/images/opm/" in text:
        return True

    return False


def build_images(data):
    vehicle = data.get("vehicle", {}) or {}
    gallery = data.get("gallery", []) or []
    feature_groups = data.get("feature_groups", []) or []
    edition_id = vehicle.get("edition_id")

    main = make_absolute_image_url(vehicle.get("main_image"))
    gallery_urls = []

    for item in gallery:
        raw_image = item.get("image")
        image = make_absolute_image_url(raw_image)
        if image and image != main and image not in gallery_urls:
            if is_vehicle_image(raw_image or image, edition_id):
                gallery_urls.append(image)

    for group in feature_groups:
        for item in group.get("items", []) or []:
            raw_image = item.get("image")
            image = make_absolute_image_url(raw_image)
            if image and image != main and image not in gallery_urls:
                if is_vehicle_image(raw_image or image, edition_id):
                    gallery_urls.append(image)

    return {
        "main": main,
        "gallery": gallery_urls[:10],
    }


def build_highlights(data):
    result = []

    for item in data.get("highlights", []) or []:
        title = str(item).strip()
        if not title or title in SERVICE_HIGHLIGHT_BLACKLIST:
            continue
        if len(title) <= 2:
            continue
        if title not in result:
            result.append(title)

    for group in data.get("feature_groups", []) or []:
        for item in group.get("items", []) or []:
            title = (item.get("title") or "").strip()
            if not title or title in SERVICE_HIGHLIGHT_BLACKLIST:
                continue
            if len(title) <= 2:
                continue
            if title not in result:
                result.append(title)

    return result[:10]


def split_feature_list(text):
    if not text:
        return []
    return [x.strip() for x in str(text).split(",") if x.strip()]


def unique_keep_order(items):
    seen = set()
    out = []
    for x in items:
        if x and x not in seen:
            seen.add(x)
            out.append(x)
    return out


def build_features_summary(data):
    danawa = data.get("danawa_spec", {}) or {}

    safety = []
    comfort = []
    multimedia = []

    safety.extend(split_feature_list(danawa.get("주행안전")))
    comfort.extend(split_feature_list(danawa.get("운전석")))
    comfort.extend(split_feature_list(danawa.get("동승석")))
    comfort.extend(split_feature_list(danawa.get("2열")))
    comfort.extend(split_feature_list(danawa.get("3열")))
    comfort.extend(split_feature_list(danawa.get("트렁크")))
    comfort.extend(split_feature_list(danawa.get("에어컨")))
    comfort.extend(split_feature_list(danawa.get("온도조절 범위")))
    comfort.extend(split_feature_list(danawa.get("파워 아웃렛")))
    multimedia.extend(split_feature_list(danawa.get("주요기능")))
    multimedia.extend(split_feature_list(danawa.get("부가기능")))
    multimedia.extend(split_feature_list(danawa.get("사운드시스템")))

    return {
        "safety": unique_keep_order(safety)[:8],
        "comfort": unique_keep_order(comfort)[:8],
        "multimedia": unique_keep_order(multimedia)[:8],
    }


def normalize_model_name(data, trim_name=None):
    vehicle = data.get("vehicle", {}) or {}
    raw = vehicle.get("edition_name") or ""

    if raw == "BMW 30주년 기념 스페셜 에디션" and trim_name:
        return f"BMW {trim_name}"

    return raw


def apply_top_level_overrides(summary, source_path=None, trim_name=None):
    text = " ".join(
        x for x in [
            source_path.stem if source_path else "",
            trim_name or "",
            summary.get("model_name") or "",
        ] if x
    ).upper()

    for key, override in MANUAL_TOP_LEVEL_OVERRIDES.items():
        if key in text:
            if "fuel_type" in override:
                summary["fuel_type"] = override["fuel_type"]
                summary["is_electric"] = override["fuel_type"] == "electric"
            if "drive_type" in override:
                summary["drive_type"] = override["drive_type"]
            if "model_family" in override:
                summary["model_family"] = override["model_family"]
            if "body_type" in override:
                summary["body_type"] = override["body_type"]
            if "segment" in override:
                summary["segment"] = override["segment"]
            break

    return summary


def build_summary(data, source_path=None):
    vehicle = data.get("vehicle", {}) or {}
    trim_info = extract_trim_info(source_path.name if source_path else None)

    trim_name = trim_info["trim_name"]
    trim_code = trim_info["trim_code"]

    model_family = infer_model_family(data, source_path=source_path, trim_name=trim_name)
    model_name = normalize_model_name(data, trim_name=trim_name)
    fuel_type = normalize_fuel_type(data, source_path=source_path, trim_name=trim_name)
    drive_type = infer_drive_type(data, source_path=source_path, trim_name=trim_name)
    body_type = infer_body_type(model_name, trim_name=trim_name, model_family=model_family)
    segment = infer_segment(model_family, model_name=model_name, trim_name=trim_name)

    summary = {
        "brand": vehicle.get("brand"),
        "model_family": model_family,
        "model_name": model_name,
        "trim_name": trim_name,
        "trim_code": trim_code,
        "edition_id": vehicle.get("edition_id"),

        "fuel_type": fuel_type,
        "is_electric": fuel_type == "electric",
        "body_type": body_type,
        "segment": segment,
        "drive_type": drive_type,
        "transmission": normalize_transmission(get_danawa_value(data.get("danawa_spec", {}), "변속기")),

        "price": {
            "currency": vehicle.get("currency", "KRW"),
            "base_price": None,
            "price_min": None,
            "price_max": None,
            "price_display": None,
        },

        "specs": build_specs(data, fuel_type, source_path=source_path, trim_name=trim_name),
        "images": build_images(data),
        "highlights": build_highlights(data),
        "features_summary": build_features_summary(data),

        "source": {
            "sales_type": vehicle.get("sales_type"),
            "stock_flag": vehicle.get("stock_flag"),
            "page_type": data.get("page_type"),
            "danawa_lineup_id": data.get("danawa_lineup_id"),
            "danawa_model_name": data.get("danawa_model_name"),
            "danawa_source_url": data.get("danawa_source_url"),
        },

        "raw_data": {
            "danawa_spec": data.get("danawa_spec", {}),
            "feature_groups": data.get("feature_groups", []),
            "promotions": data.get("promotions", []),
            "notices": data.get("notices", []),
        },
    }

    summary = apply_top_level_overrides(summary, source_path=source_path, trim_name=trim_name)
    summary["specs"] = cleanup_specs_for_fuel_type(summary["specs"], summary["fuel_type"])
    return summary


def main():
    BASE_DIR = Path(__file__).resolve().parent
    INPUT_DIR = BASE_DIR / "data" / "danawa_spec"
    OUTPUT_DIR = BASE_DIR / "data" / "summary_final"
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    files = sorted(
        p for p in INPUT_DIR.glob("*.json")
        if p.name != "summary.json"
    )

    print("INPUT_DIR =", INPUT_DIR)
    print("OUTPUT_DIR =", OUTPUT_DIR)
    print("input files =", len(files))

    for path in files:
        try:
            with open(path, "r", encoding="utf-8-sig") as f:
                data = json.load(f)

            summary = build_summary(data, source_path=path)

            out_path = OUTPUT_DIR / path.name
            with open(out_path, "w", encoding="utf-8-sig") as f:
                json.dump(summary, f, ensure_ascii=False, indent=2)

            print("[OK]", path.name)

        except Exception as e:
            print("[ERROR]", path.name, e)


if __name__ == "__main__":
    main()