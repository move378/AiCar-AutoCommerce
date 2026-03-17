"""
벤츠 인벤토리 파서
inventory_data.json → 서머리 파싱 결과에 연비/전비 보완
"""

import os
import json
from typing import Optional
from config import BENZ_INVENTORY_PATH

from db.parser.benz.benz_summary_parser import (
    VehicleData, IceSpecData, EvSpecData,
    to_float, to_int,
)


# ──────────────────────────────────────────────
# 인벤토리 인덱스 빌드
# ──────────────────────────────────────────────

def _build_index(inventory_path: str) -> dict:
    """
    inventory_data.json → {baumuster: wltp_attrs}
    """
    if not os.path.exists(inventory_path):
        return {}

    with open(inventory_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    index = {}
    for item in data.get("results", []):
        try:
            baumuster = item["vehicleModel"]["baumuster"]

            if baumuster not in index:
                attrs = (
                    item["technicalInformation"]
                    .get("emissionAndConsumption", {})
                    .get("wltp", {})
                    .get("attributes", [])
                )
                index[baumuster] = attrs
        except (KeyError, TypeError):
            continue

    return index


def _get_attr(attrs: list, attr_id: str) -> Optional[str]:
    for a in attrs:
        if a.get("id") == attr_id:
            return a.get("displayValue")
    return None


def _find_attrs(index: dict, baumuster: str) -> list:
    """
    서머리 baumuster.startswith(인벤토리 baumuster) 로 매칭
    후보가 여러 개면 가장 긴 것 선택
    """
    if not baumuster:
        return []
    candidates = [
        inv_bm for inv_bm in index
        if baumuster.startswith(inv_bm)
    ]
    if not candidates:
        return []
    best = max(candidates, key=len)
    return index[best]


# ──────────────────────────────────────────────
# 연비 보완
# ──────────────────────────────────────────────

def enrich(vehicles: list[VehicleData]) -> list[VehicleData]:
    """
    서머리 파서 결과(vehicles)에 연비/전비 데이터 보완
    """
    index = _build_index(BENZ_INVENTORY_PATH)

    for v in vehicles:
        attrs = _find_attrs(index, v.trim.baumuster or "")

        if v.ice_spec is not None:
            v.ice_spec.fuel_eff_combined = to_float(_get_attr(attrs, "FuelConsumptionAverage"))
            v.ice_spec.fuel_eff_city     = to_float(_get_attr(attrs, "FuelConsumptionCity"))
            v.ice_spec.fuel_eff_highway  = to_float(_get_attr(attrs, "FuelConsumptionHighway"))
            v.ice_spec.energy_grade      = to_int(_get_attr(attrs, "FuelEconomyGrade"))

        if v.ev_spec is not None:
            v.ev_spec.max_range    = to_int(_get_attr(attrs, "ElectricRange"))
            v.ev_spec.eff_combined = to_float(_get_attr(attrs, "ElectricConsumptionCombined"))
            v.ev_spec.eff_city     = to_float(_get_attr(attrs, "ElectricConsumptionCity"))
            v.ev_spec.eff_highway  = to_float(_get_attr(attrs, "ElectricConsumptionHighway"))

    print(f"인벤토리 보완 완료: {len(vehicles)}개 차량")
    return vehicles