"""
벤츠 서머리 파서
data/{모델명}/summary.json → list[VehicleData]
"""

import os
import json
import re
from dataclasses import dataclass, field
from typing import Optional
from config import BENZ_SUMMARY_DIR


# ──────────────────────────────────────────────
# 공통 dataclass (inventory parser에서도 import)
# ──────────────────────────────────────────────

@dataclass
class BrandData:
    name: str
    country: Optional[str] = None
    logo_url: Optional[str] = None


@dataclass
class ModelData:
    model_name: str
    category: Optional[str] = None
    classification: Optional[str] = None
    segment: Optional[str] = None


@dataclass
class TrimData:
    trim_name: str
    baumuster: Optional[str] = None
    year: Optional[str] = None
    base_price: Optional[int] = None
    fuel_type: Optional[str] = None
    seating_capacity: Optional[int] = None
    trunk_capacity: Optional[int] = None
    max_output: Optional[int] = None
    drive_type: Optional[float] = None
    acceleration: Optional[float] = None
    length: Optional[int] = None
    width: Optional[int] = None
    height: Optional[int] = None
    wheelbase: Optional[int] = None
    curb_weight: Optional[int] = None
    transmission: Optional[str] = None
    image_url: Optional[str] = None
    top_speed: Optional[int] = None
    doors: Optional[int] = None


@dataclass
class IceSpecData:
    displacement: Optional[int] = None
    fuel_tank_capacity: Optional[int] = None
    fuel_eff_combined: Optional[float] = None
    fuel_eff_city: Optional[float] = None
    fuel_eff_highway: Optional[float] = None
    energy_grade: Optional[int] = None
    cylinder: Optional[int] = None


@dataclass
class EvSpecData:
    battery_capacity: Optional[float] = None
    max_range: Optional[int] = None
    eff_combined: Optional[float] = None
    eff_city: Optional[float] = None
    eff_highway: Optional[float] = None
    energy_grade: Optional[int] = None


@dataclass
class OptionData:
    option_code: str
    name: str
    category: Optional[str] = None
    description: Optional[str] = None
    price: Optional[int] = None
    is_standard: bool = True


@dataclass
class VehicleData:
    brand: BrandData
    model: ModelData
    trim: TrimData
    ice_spec: Optional[IceSpecData] = None
    ev_spec: Optional[EvSpecData] = None
    options: list[OptionData] = field(default_factory=list)

@dataclass
class VehicleModel:
    


# ──────────────────────────────────────────────
# 유틸
# ──────────────────────────────────────────────

def to_float(value: str) -> Optional[float]:
    if not value:
        return None
    try:
        return float(re.search(r"[\d.]+", value).group())
    except:
        return None


def to_int(value: str) -> Optional[int]:
    if not value:
        return None
    try:
        return int(re.sub(r"[^\d]", "", value))
    except:
        return None


def get_tech_value(tech_groups: list, tech_id: str) -> Optional[str]:
    for group in tech_groups:
        for val in group.get("technicalValues", []):
            if val.get("id") == tech_id:
                return val.get("rawValue")
    return None


def _init_brand():
    return BrandData(name="Mercedes-Benz", country="독일")

# ──────────────────────────────────────────────
# 옵션 파서
# ──────────────────────────────────────────────

def _parse_options(summary: dict) -> list[OptionData]:
    options = []
    overview = summary.get("configurationOverview", {})

    for section_key, is_standard in [("standard", True), ("optional", False)]:
        section = overview.get(section_key, {})
        for cat in section.get("categories", []):
            category = cat.get("id")
            for comp in cat.get("components", []):
                name = comp.get("name")
                if not name:
                    continue
                options.append(OptionData(
                    option_code = comp.get("id", ""),
                    name        = name,
                    category    = category,
                    price       = int(comp.get("price", {}).get("price", 0) or 0),
                    is_standard = is_standard,
                ))

    return options


def summary_parser() -> list[VehicleData]:
    vehicles = []
    brand = _init_brand()

    for model_name in os.listdir(BENZ_SUMMARY_DIR):
        summary_file = os.path.join(BENZ_SUMMARY_DIR, model_name, "summary.json")
        if not os.path.exists(summary_file):
            continue

        with open(summary_file, "r", encoding="utf-8") as f:
            data = json.load(f)

        try:

            
            

        except Exception as e:
            print(f"[서머리 파서 오류] {model_name}: {e}")
            continue


# ──────────────────────────────────────────────
# 서머리 파서
# ──────────────────────────────────────────────

def parse() -> list[VehicleData]:
    vehicles = []
    brand = BrandData(name="Mercedes-Benz", country="독일")

    for model_name in os.listdir(BENZ_SUMMARY_DIR):
        summary_file = os.path.join(BENZ_SUMMARY_DIR, model_name, "summary.json")
        if not os.path.exists(summary_file):
            continue

        with open(summary_file, "r", encoding="utf-8") as f:
            data = json.load(f)

        try:
            vehicle_info = data["vehicle"]
            summary      = data["summary"]
            tech_groups  = summary.get("technicalInformationSection", {}) \
                                  .get("technicalInformationGroup", [])
            price_info   = summary.get("priceInformation", {})

            model = ModelData(
                model_name=vehicle_info.get("name", model_name),
            )

            fuel_type    = get_tech_value(tech_groups, "technicalInformation.engine.fuelType")
            transmission = get_tech_value(tech_groups, "technicalInformation.transmission.name")

            trim = TrimData(
                trim_name        = vehicle_info.get("name", model_name),
                baumuster        = vehicle_info.get("baumuster"),
                base_price       = int(price_info.get("basePrice", {}).get("price", 0) or 0),
                fuel_type        = fuel_type,
                transmission     = transmission,
                max_output       = to_int(get_tech_value(tech_groups, "technicalInformation.engine.power")),
                acceleration     = to_float(get_tech_value(tech_groups, "technicalInformation.acceleration")),
                length           = to_int(get_tech_value(tech_groups, "technicalInformation.dimensions.length")),
                width            = to_int(get_tech_value(tech_groups, "technicalInformation.dimensions.widthWithoutMirrors")),
                height           = to_int(get_tech_value(tech_groups, "technicalInformation.dimensions.height")),
                seating_capacity = to_int(get_tech_value(tech_groups, "technicalInformation.seats")),
                top_speed        = to_int(get_tech_value(tech_groups, "technicalInformation.topSpeed")),
                doors            = to_int(get_tech_value(tech_groups, "technicalInformation.doors")),
                image_url        = vehicle_info.get("imageUrl"),
            )

            is_ev = "전기" in (fuel_type or "")

            options = _parse_options(summary)

            if not is_ev:
                ice_spec = IceSpecData(
                    displacement       = to_int(get_tech_value(tech_groups, "technicalInformation.engine.capacity")),
                    fuel_tank_capacity = to_int(get_tech_value(tech_groups, "technicalInformation.capacityWithReserve")),
                    cylinder           = to_int(get_tech_value(tech_groups, "technicalInformation.engine.cylinder")),
                )
                vehicles.append(VehicleData(brand=brand, model=model, trim=trim, ice_spec=ice_spec, options=options))
            else:
                ev_spec = EvSpecData()
                vehicles.append(VehicleData(brand=brand, model=model, trim=trim, ev_spec=ev_spec, options=options))

        except Exception as e:
            print(f"[서머리 파서 오류] {model_name}: {e}")
            continue

    print(f"서머리 파싱 완료: {len(vehicles)}개 차량")
    return vehicles