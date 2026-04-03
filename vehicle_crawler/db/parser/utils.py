from typing import List, Optional

BODY_TYPE_MAP = {
    "SUV": "SUV",
    "Sedan": "세단",
    "Coupé": "쿠페",
    "4-Door Coupé": "쿠페",
    "Cabriolet": "카브리올레",
    "Roadster": "로드스터",
    "Hatch": "해치백",
    "Cross-country vehicle": "SUV",
    "Long": "세단",
    "MAYBACH": "세단",
}

def normalize_body_type(body_type: str | None) -> str | None:
    if not body_type:
        return None
    return BODY_TYPE_MAP.get(body_type, body_type)

def get_sub_brand(body_type: str | None) -> str | None:
    if not body_type:
        return None
    return SUB_BRAND_MAP.get(body_type, None)

def determine_segment_by_length(length_mm: int) -> str:
    """
    차량의 전장(length)을 기준으로 유럽식 세그먼트를 자동 분류합니다.
    (기준 수치는 일반적인 유럽/국내 혼합 기준이며, 필요에 따라 조정 가능합니다.)
    """
    if length_mm is None or length_mm <= 0:
        return "Unknown"
        
    if length_mm < 3600:
        return "A-Segment" # 경차 (예: 스마트 포투, 모닝)
    elif length_mm < 4300:
        return "B-Segment" # 소형차/소형 SUV (예: 르노 클리오, 코나)
    elif length_mm < 4600:
        return "C-Segment" # 준중형차/컴팩트 SUV (예: 벤츠 EQA, 아반떼)
    elif length_mm < 4900:
        return "D-Segment" # 중형차/중형 SUV (예: 벤츠 C-Class, 쏘나타)
    elif length_mm < 5100:
        return "E-Segment" # 준대형/대형차 (예: 벤츠 E-Class, 그랜저)
    else:
        return "F-Segment" # 대형 럭셔리카 (예: 벤츠 S-Class, G90)
    
def determine_classification_by_length(length_mm: int) -> str:
    """
    차량의 전장을 기준으로 한국식 차급을 자동 분류합니다.
    """
    if length_mm is None or length_mm <= 0:
        return "미분류"
        
    if length_mm < 3600:
        return "경차"
    elif length_mm < 4300:
        return "소형"
    elif length_mm < 4600:
        return "준중형"
    elif length_mm < 4900:
        return "중형"
    elif length_mm < 5100:
        return "준대형"
    else:
        return "대형"
    
def find_dict_in_list(list: List[dict], target_key: str, target_str: str) -> Optional[dict]:
    if not list:
        return None
        
    for item in list:
        if item.get(target_key) == target_str:
            return item
                
    return None # 못 찾았을 경우 None 반환