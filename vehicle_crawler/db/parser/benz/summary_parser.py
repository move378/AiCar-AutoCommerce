import os
import json
from config import BENZ_SUMMARY_DIR
from db.dto import VehicleData, Brand, Model, Trim, IceSpec, EvSpec, Option,TrimImage
from db.parser.utils import determine_segment_by_length
from db.parser.utils import determine_classification_by_length


def _init_brand():
    return Brand(name="Mercedes-Benz", country="독일")


def _get_nested(data, *keys, cast=None, default=None):
    for key in keys:
        if isinstance(data, list):
            data = next((item for item in data if isinstance(item, dict) and item.get("label") == key), None)
        elif isinstance(data, dict):
            data = data.get(key)
        else:
            return default
        if data is None:
            return default
    if cast and data is not None:
        try:
            return cast(data)
        except (ValueError, TypeError):
            return default
    return data


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
            tags = summary.get("tags", [])


            vehicle_length = _get_nested(tech_groups, "치수", "technicalValues", "길이", "rawValue", cast=int)

            model = Model(
                name=vehicle_info.get("vehicleClass", model_folder),
                classification=determine_classification_by_length(vehicle_length),
                segment=determine_segment_by_length(vehicle_length)
            )

            engine_type  = _get_nested(vehicle_info, "plsInformationSection", "technicalData", "engine", "type")

            if engine_type == "ELECTRIC":
                max_output = _get_nested(tech_groups, "출력", "technicalValues", "출력 (kw)", "rawValue", cast=int)
                ice_spec = None
                ev_spec = EvSpec()
            else:
                max_output = _get_nested(vehicle_info, "ocapiInformation", "technicalValues", "마력", "rawValue", cast=int)
                
                
                ice_spec = IceSpec(
                    displacement=_get_nested(tech_groups, "출력", "technicalValues", "배기량", "rawValue", cast=int),
                    cylinders=_get_nested(tech_groups, "출력", "technicalValues", "실린더 수", "rawValue"),
                    fuel_tank_capacity=_get_nested(tech_groups, "세부 내용", "technicalValues", "탱크 용량(기본)", "rawValue", cast=int),
                )
                ev_spec = None
            

            trim = Trim(
                name=vehicle_info.get("name", "Unknown Trim"),
                baumuster = vehicle_info.get("baumuster", "Unknown Trim"),
                body_type=vehicle_info.get("vehicleBody"),
                body_type_code=vehicle_info.get("vehicleBodyId"),
                model_year=vehicle_info.get("modelYear"),
                base_price=_get_nested(summary, "configurationOverview", "priceInformation", "basePrice", "price", cast=int),
                fuel_type= _get_nested(tech_groups, "출력", "technicalValues", "연료 유형", "rawValue"),
                length=vehicle_length,
                width=_get_nested(tech_groups, "치수", "technicalValues", "전폭(사이드 미러 제외)", "rawValue", cast=int),
                height=_get_nested(tech_groups, "치수", "technicalValues", "높이", "rawValue", cast=int),
                seating_capacity=_get_nested(tech_groups, "세부 내용", "technicalValues", "좌석", "rawValue", cast=int),
                doors=_get_nested(tech_groups, "세부 내용", "technicalValues", "도어 수", "rawValue", cast=int),
                acceleration_0_100=_get_nested(tech_groups, "출력", "technicalValues", "가속력 (0->100km/h：초)", "rawValue", cast=float),
                top_speed=_get_nested(tech_groups, "출력", "technicalValues", "최고속도", "rawValue", cast=int),
                max_output=max_output,
                transmission = _get_nested(tags, "변속기", "rawValue"),
                curb_weight = _get_nested(vehicle_info, "ocapiInformation", "technicalValues", "공차 중량", "rawValue", cast=int),
                ice_spec=ice_spec,
                ev_spec=ev_spec,
            )

            base_url = _get_nested(vehicle_info, "stageV2", "metaData", "baseInfo", "baseUrl")
            cosy_id = _get_nested(vehicle_info, "stageV2", "cosyId")
            additional_params = _get_nested(vehicle_info, "stageV2", "metaData", "views", "EXTERIOR_360", "additionalParameters") or []
            additional_dict = {p.get("key"): p.get("value") for p in additional_params if isinstance(p, dict)}

            def _build_image_url(pov: str) -> str | None:
                if not base_url or not cosy_id:
                    return None
                params = {**additional_dict, "IMGT": "W27", "POV": pov}
                query_string = "&".join(f"{k}={v}" for k, v in params.items())
                return f"{base_url}?q={cosy_id}&{query_string}&imwidth=1280"

            images = [
                TrimImage(image_url=_build_image_url("BE000"), image_type="exterior_front"),
                TrimImage(image_url=_build_image_url("BE090"), image_type="exterior_side"),
                TrimImage(image_url=_build_image_url("BIS1"),  image_type="interior"),
            ]

            vehicle_data = VehicleData(
                brand=brand,
                model=model,
                trim=trim,
                images=images
            )

            vehicles.append(vehicle_data)

        except Exception as e:
            print(f"[서머리 파서 오류] {model_folder}: {e}")
            continue

    return vehicles