import json
import re
from typing import List
from db.dto import VehicleData, Brand, Model, Trim, IceSpec, EvSpec, Option,TrimImage

def normalize(text: str) -> str:
    text = text.lower()
    text = text.replace("mercedes-benz", "")
    text = text.replace("-", "")
    text = re.sub(r'\s+', '', text)
    return text

def enrich_fuel_efficiency(vehicles, brand: str):
    with open(f"crawlers/{brand}/data/fuel_efficiency.json", "r", encoding="utf-8") as f:
        data = json.load(f)

    fuel_list = data.get("list", [])

    for vehicle in vehicles:
        trim_name = normalize(vehicle.trim.name)

        candidates = [
            row for row in fuel_list
            if normalize(row.get("MODL_NM", "")) in trim_name
        ]

        if not candidates:
            continue

        best = sorted(candidates, key=lambda x: x.get("INJUNG_DT", ""), reverse=True)[0]

        fuel_kind = best.get("FUEL_KIND_NM", "")

        if fuel_kind == "전기":
            if vehicle.trim.ev_spec is None:
                vehicle.trim.ev_spec = EvSpec()

            total_range = best.get("TOTAL_CHARGE_MILEAGE")
            efficiency = best.get("MIXMD_MILEAGE")

            # 정확한 데이터 없음
            # vehicle.trim.ev_spec.battery_capacity = round(total_range / efficiency, 1) if total_range and efficiency else None
            vehicle.trim.ev_spec.efficiency_combined = best.get("MIXMD_MILEAGE")
            vehicle.trim.ev_spec.efficiency_city = best.get("CITY_MILEAGE")
            vehicle.trim.ev_spec.efficiency_highway = best.get("HIGH_MILEAGE")
            vehicle.trim.ev_spec.max_range = best.get("TOTAL_CHARGE_MILEAGE")
            vehicle.trim.ev_spec.energy_grade = best.get("GRD")
        else:
            if vehicle.trim.ice_spec is None:
                vehicle.trim.ice_spec = IceSpec()

            vehicle.trim.ice_spec.efficiency_combined = best.get("TOTAL_MILEAGE")
            vehicle.trim.ice_spec.efficiency_city = best.get("CITY_MILEAGE")
            vehicle.trim.ice_spec.efficiency_highway = best.get("HIGH_MILEAGE")
            vehicle.trim.ice_spec.energy_grade = best.get("GRD")
            vehicle.trim.ice_spec.displacement = best.get("BAEGI_AMT")
            vehicle.trim.ice_spec.fuel_tank_capacity = best.get("FUEL_CAPA")

    return vehicles