# 내장 모듈 임포트
from dataclasses import dataclass, field
from typing import List, Optional

# 외부에서 이 모듈을 import * 할 때 노출할 클래스들
__all__ = ['Brand', 'Model', 'IceSpec', 'EvSpec', 'Option', 'Trim', 'VehicleData']

# ==========================================
# 공통 차량 데이터 모델 (Data Models)
# ==========================================

@dataclass
class Brand:
    name: str                   # 브랜드명 (예: Mercedes-Benz)
    country: Optional[str] = None # 제조 국가 (예: Germany)
    logo_url: Optional[str] = None # 로고 이미지 URL

@dataclass
class Model:
    name: str                   # 모델명 (예: EQA)
    classification: Optional[str] = None # 차급 분류 (예: 중형, 소형)
    segment: Optional[str] = None        # 세그먼트 (예: C-Segment)

@dataclass
class IceSpec:
    """내연기관(가솔린, 디젤 등) 상세 제원"""
    displacement: Optional[int] = None         # 배기량 (cc)
    fuel_tank_capacity: Optional[int] = None   # 연료 탱크 용량 (L)
    efficiency_combined: Optional[float] = None # 복합 연비 (km/l)
    efficiency_city: Optional[float] = None     # 도심 연비 (km/l)
    efficiency_highway: Optional[float] = None  # 고속도로 연비 (km/l)
    energy_grade: Optional[int] = None         # 연비/에너지 소비 효율 등급
    cylinders: Optional[int] = None            # 실린더 수 / 기통 (예: 4, 6)

@dataclass
class EvSpec:
    """전기차(EV) 상세 제원"""
    battery_capacity: Optional[float] = None   # 배터리 용량 (kWh)
    max_range: Optional[int] = None            # 1회 충전 최대 주행거리 (km)
    efficiency_combined: Optional[float] = None # 복합 전비 (km/kWh)
    efficiency_city: Optional[float] = None     # 도심 전비 (km/kWh)
    efficiency_highway: Optional[float] = None  # 고속도로 전비 (km/kWh)
    energy_grade: Optional[int] = None         # 연비/에너지 소비 효율 등급

@dataclass
class Option:
    name: str                   # 옵션명 (예: 파노라마 선루프)
    category: Optional[str] = None # 옵션 분류 (예: 외관, 편의)
    description: Optional[str] = None # 상세 설명
    price: int = 0              # 추가 가격 (원)
    is_standard: bool = False   # 기본 탑재 여부 (True: 기본, False: 선택옵션)
    availability: bool = True   # 현재 적용 가능 여부

@dataclass
class Trim:
    name: str                   # 트림명 (예: EQA 250 AMG Line)
    baumuster: str
    
    # Model에서 Trim으로 이동된 바디 타입 정보!
    body_type: Optional[str] = None      # 차량 형태 (예: SUV) -> JSON의 vehicleBody
    body_type_code: Optional[str] = None # 차량 형태 시스템 코드 (예: OFFROADER) -> JSON의 vehicleBodyId
    
    model_year: Optional[str] = None # 연식 (예: 806 -> 추후 2024 등으로 변환 필요할 수 있음)
    base_price: Optional[int] = None      # 트림 기본 가격 (원)
    fuel_type: Optional[str] = None  # 연료 타입 (예: EV, Gasoline, Diesel)
    
    # 공간 & 성능 제원
    seating_capacity: Optional[int] = None # 승차 정원 (인)
    max_output: Optional[int] = None       # 최고 출력 (마력/kW)
    acceleration_0_100: Optional[float] = None # 제로백 (초)
    top_speed: Optional[int] = None        # 최고 속도 (km/h)
    
    # 크기 & 무게 제원
    length: Optional[int] = None    # 전장 (mm)
    width: Optional[int] = None     # 전폭 (mm)
    height: Optional[int] = None    # 전고 (mm)
    curb_weight: Optional[int] = None # 공차 중량 (kg)
    
    # 기타 차량 정보
    transmission: Optional[str] = None # 변속기 (예: 자동 8단)
    doors: Optional[int] = None        # 도어 수 (문 개수)
    image_url: Optional[str] = None    # 대표 이미지 URL
    
    # 내연기관/전기차 스펙 & 옵션 목록
    ice_spec: Optional[IceSpec] = None 
    ev_spec: Optional[EvSpec] = None   
    options: List[Option] = field(default_factory=list) 

@dataclass
class TrimImage:
    image_url: str
    image_type: Optional[str] = None  # 'exterior_front', 'exterior_side', 'interior'

# ==========================================
# 파싱용 최상위 Aggregate Root
# ==========================================

@dataclass
class VehicleData:
    """
    한 대의 차량(특정 트림)의 모든 데이터를 담기 위한 최상위 래퍼 클래스입니다.
    """
    brand: Brand # 소속 브랜드
    model: Model # 소속 모델
    trim: Trim   # 상세 트림 및 제원/옵션 정보
    images: List[TrimImage] = field(default_factory=list)