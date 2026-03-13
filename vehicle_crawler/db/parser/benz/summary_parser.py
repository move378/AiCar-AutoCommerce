import os
import json
from config import BENZ_SUMMARY_DIR
from db.dto import VehicleData, Brand, Model, Trim, IceSpec, EvSpec, Option
from db.parser import determine_segment_by_length
from db.parser import determine_classification_by_length
from db.parser import find_dict_in_list

def _init_brand():
    return Brand(name="Mercedes-Benz", country="독일")


def _get_length(group):
    d1 = find_dict_in_list(group, "label", "치수")
    tech_values_list = d1.get("technicalValues", [])
    d2 = find_dict_in_list(tech_values_list, "label", "길이")

    if d2 and d2.get("rawValue"):
        try:
            # "4463" 같은 문자열을 숫자로 변환
            length_mm = int(d2.get("rawValue"))
            return length_mm
        except ValueError:
            return "Unknown"

    return "Unknown"

def summary_parser() -> list[VehicleData]:
    vehicles = []
    brand = _init_brand()

    for model_folder in os.listdir(BENZ_SUMMARY_DIR):
        summary_file = os.path.join(BENZ_SUMMARY_DIR, model_folder, "summary.json")
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

            vehicle_length = _get_length(tech_groups)
           # 1. Model 객체 생성
            model = Model(
                name=vehicle_info.get("vehicleClass", model_folder), 
                classification = determine_classification_by_length(vehicle_length),
                segment = determine_segment_by_length(vehicle_length)
            )

            # 2. Trim 객체 생성 (기본 정보만 우선 삽입)
            # 바디 타입 정보 등 추가 가능
            trim = Trim(
                name=vehicle_info.get("name", "Unknown Trim"),
                body_type=vehicle_info.get("vehicleBody"),
                body_type_code=vehicle_info.get("vehicleBodyId"),
                model_year=vehicle_info.get("modelYear"),
                fuel_type = find_dict_in_list(tech_groups, "label", "출력")
            )

            # 3. 최종 VehicleData 객체 생성
            vehicle_data = VehicleData(
                brand=brand,
                model=model,
                trim=trim
            )
            
            vehicles.append(vehicle_data)

            
            

        except Exception as e:
            print(f"[서머리 파서 오류] {model_name}: {e}")
            continue