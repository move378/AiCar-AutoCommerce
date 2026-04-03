# crawl_bmw_details.py
# Python 3.10+
#
# 기능
# 1. 42개 모델의 상세 JSON API를 순회 요청
# 2. raw JSON 저장
# 3. vehicle / trim / usp를 정규화한 summary JSON 저장
#
# 사용 전 꼭 바꿔야 할 것
# - DETAIL_API_TEMPLATE
# - MODEL_IDENTIFIERS
# - 필요하면 HEADERS / PARAMS_BUILDER

from __future__ import annotations

import json
import os
import re
import time
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Any, Dict, List, Optional

import requests


# =========================================================
# 설정
# =========================================================

# 예시:
# 실제 BMW 상세 JSON API 주소 형식으로 바꿔야 함.
# 예: "https://www.bmw.co.kr/xxxxx?editionId={model_id}"
DETAIL_API_TEMPLATE = "https://shop.bmw.co.kr/shop/api/opm/{model_id}"

# 42개 차량 식별자 넣기
# editionId, model code, slug 등 실제 API에 들어가는 값으로 교체
MODEL_CONFIGS = [
    {"model_id": "OIM26020001", "template_path": "/reservation/oim/"},
    {"model_id": "OIM25060012", "template_path": "/reservation/oim/"},
    {"model_id": "OIM24020001", "template_path": "/reservation/oim/"},
    {"model_id": "OIU1123010", "template_path": "/reservation/oim/"},
    {"model_id": "PMG7022071", "template_path": "/online/opm/model/"},
    {"model_id": "OEM24090005", "template_path": "/edition/oem/"},
    {"model_id": "OPM23080001", "template_path": "/reservation/oim/"},
    {"model_id": "OEM25120004", "template_path": "/edition/oem/"},
    {"model_id": "OPM25110006", "template_path": "/online/opm/model/"},
    {"model_id": "PMG7022080", "template_path": "/online/opm/model/"},
    {"model_id": "OEM26020003", "template_path": "/edition/oem/"},
    {"model_id": "OEM26020002", "template_path": "/edition/oem/"},
    {"model_id": "OEM26010003", "template_path": "/edition/oem/"},
    {"model_id": "OOM23090001", "template_path": "/online/oom/"},
    {"model_id": "OEM26010002", "template_path": "/edition/oem/"},
    {"model_id": "OOM23110001", "template_path": "/online/oom/"},
    {"model_id": "OEM25110003", "template_path": "/edition/oem/"},
    {"model_id": "OEM25100005", "template_path": "/edition/oem/"},
    {"model_id": "OOM24090001", "template_path": "/online/oom/"},
    {"model_id": "OOM24090002", "template_path": "/online/oom/"},
    {"model_id": "OEM25120002", "template_path": "/edition/oem/"},
    {"model_id": "OMG4223020", "template_path": "/online/oom/"},
    {"model_id": "OEM25060007", "template_path": "/edition/oem/"},
    {"model_id": "OEM25100001", "template_path": "/edition/oem/"},
    {"model_id": "OEM25100004", "template_path": "/edition/oem/"},
    {"model_id": "OEM25100002", "template_path": "/edition/oem/"},
    {"model_id": "OEM24120001", "template_path": "/edition/oem/"},
    {"model_id": "OEM23120003", "template_path": "/edition/oem/"},
    {"model_id": "OEM25120001", "template_path": "/edition/oem/"},
    {"model_id": "OEM25090006", "template_path": "/edition/oem/"},
    {"model_id": "OEM25040005", "template_path": "/edition/oem/"},
]

# 요청 헤더가 필요하면 추가
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Mobile Safari/537.36 Edg/146.0.0.0",
    "Accept": "application/json, text/plain, */*",
    "Referer": "https://shop.bmw.co.kr/reservation/oim/OPM23080001",
    "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbk5vdGVzIjoiQk1XT05MSU5FU0VSVklDRSIsImlzcyI6IkJNVyIsImV4cCI6MTk4NzgzMDI4OX0.0EQ2ZABT5pywtJjQbiy0WOdw7cDXahWITyr8729PT0k",
    "x-m-x-token": "5adea3a5-014e-4249-9a1b-db55858da256",
    "Cookie": "_fbp=fb.2.1774322776451.896530996494650149; WG_CLIENT_ID=uORHCTUAfRJ4LY0WAYFa; WG_VER_CLIENT=V.21.2.24; _gcl_au=1.1.1107555843.1774322777; _ga=GA1.1.41342587.1774322778; cc_consentCookie=%7B%22bmw_korea_family%22%3A%7B%22cmm%22%3A%7B%22advertising%22%3A1%7D%2C%22cdc%22%3A1%2C%22tp%22%3A1763970144114%2C%22lmt%22%3A1774323789947%7D%7D; oms_unique=true; M-X-TOKEN=5adea3a5-014e-4249-9a1b-db55858da256; C5tM5s_origin=%7B%22sentAnomalies%22%3A%5B%5D%2C%22from%22%3A%22shop_bmw_co_kr%22%2C%22sid%22%3A%2225161983598195237657279108932712486050%22%7D; bmwdtm_hq_vs=1774839940; launchSession=R3mozC1BAB0; AMCVS_B52D1CFE5330949C0A490D45%40AdobeOrg=1; s_cc=true; AMCV_B52D1CFE5330949C0A490D45%40AdobeOrg=1176715910%7CMCMID%7C70948083600041638684130828339601276744%7CMCAAMLH-1775462288%7C11%7CMCAAMB-1775462288%7C6G1ynYcLPuiQxYZrsz_pkqfLG9yMXBpb2zX5dvJdYQJzPXImdj0y%7CMCOPTOUT-1774864688s%7CNONE%7CMCAID%7CNONE%7CvVersion%7C5.4.0; bmwdtm_hq_previouspage_meta=%257B%2522pageSubCategory01%2522%253A%257B%2522currValue%2522%253A%2522datalayer%2520field%2520empty%2522%257D%252C%2522pageName%2522%253A%257B%2522currValue%2522%253A%2522sales%2520%253E%2520boost%2520vehicle%2520details%2522%257D%252C%2522url%2522%253A%257B%2522currValue%2522%253A%2522https%253A%252F%252Fshop.bmw.co.kr%252Fedition%252Foem%252FOEM25120004%2522%257D%252C%2522pathName%2522%253A%257B%2522currValue%2522%253A%2522https%253A%252F%252Fshop.bmw.co.kr%252Fedition%252Foem%252FOEM25120004%2522%257D%252C%2522pagePrimaryCategory%2522%253A%257B%2522currValue%2522%253A%2522korea%2520boost%2520pages%2522%257D%257D; bmwdtm_hq_sid=0.3537625816925881; s_ips=1148; s_sq=bmwgroup.group.global.all%252Cbmwgroup.bmw.kr.market%3D%2526c.%2526a.%2526activitymap.%2526page%253Dhttps%25253A%25252F%25252Fshop.bmw.co.kr%25252Freservation%25252Foim%25252FOPM23080001%2526link%253D%2525EC%25259E%252590%2525EC%252584%2525B8%2525ED%25259E%252588%252520%2525EB%2525B3%2525B4%2525EA%2525B8%2525B0%2526region%253DWrap%2526.activitymap%2526.a%2526.c; s_tp=1148; s_ppv=https%253A%2F%2Fshop.bmw.co.kr%2Freservation%2Foim%2FOPM23080001%2C100%2C100%2C1148%2C1%2C1; _dd_s=rum=2&id=b5f1817d-38ac-4e54-ab8e-1834cb093fec&created=1774857486080&expire=1774859266599&logs=1; _ga_1XM07VW7WF=GS2.1.s1774857488$o10$g1$t1774858366$j57$l0$h0",
}

REQUEST_TIMEOUT = 20
REQUEST_SLEEP = 0.7
MAX_RETRIES = 3

BASE_DIR = Path("bmw_detail_output")
RAW_DIR = BASE_DIR / "raw"
SUMMARY_DIR = BASE_DIR / "summary"
INDEX_FILE = BASE_DIR / "index.json"


# =========================================================
# 데이터 구조
# =========================================================

@dataclass
class VehicleInfo:
    edition_id: str
    edition_name: str
    edition_price: Optional[str]
    btn_title: Optional[str]
    stock_flag: Optional[bool]
    sales_type: Optional[str]
    electric_yn: Optional[str]
    main_image: Optional[str]


@dataclass
class TrimOption:
    category_title: str
    category_code: str
    pcode: Optional[str]
    trim_name: Optional[str]
    trim_img: Optional[str]
    activation: Optional[bool]
    status: Optional[bool]
    sf_yn: Optional[str]


@dataclass
class UspItem:
    section_seq: Optional[int]
    section_type: Optional[str]
    section_title: Optional[str]
    section_subtitle: Optional[str]
    section_image: Optional[str]
    item_seq: Optional[int]
    item_type: Optional[str]
    item_title: Optional[str]
    item_description: Optional[str]
    item_image: Optional[str]
    link: Optional[str]


# =========================================================
# 유틸
# =========================================================

def build_referer_url(model_id: str, template_path: str) -> str:
    return f"https://shop.bmw.co.kr{template_path}{model_id}"

def ensure_dirs() -> None:
    RAW_DIR.mkdir(parents=True, exist_ok=True)
    SUMMARY_DIR.mkdir(parents=True, exist_ok=True)


def safe_filename(text: str) -> str:
    text = text.strip()
    text = re.sub(r"[\\/:*?\"<>|]+", "_", text)
    text = re.sub(r"\s+", "_", text)
    return text[:150] if text else "unknown"


def request_json(url: str, model_id: str, template_path: str) -> Dict[str, Any]:
    last_error = None

    for attempt in range(1, MAX_RETRIES + 1):
        try:
            headers = HEADERS.copy()
            headers["Referer"] = build_referer_url(model_id, template_path)

            resp = requests.get(url, headers=headers, timeout=REQUEST_TIMEOUT)
            resp.raise_for_status()
            return resp.json()
        except Exception as e:
            last_error = e
            print(f"[WARN] attempt={attempt} failed: {url} -> {e}")
            time.sleep(1.0 * attempt)

    raise RuntimeError(f"Failed to fetch after {MAX_RETRIES} retries: {url}\n{last_error}")


def build_detail_url(model_id: str) -> str:
    return DETAIL_API_TEMPLATE.format(model_id=model_id)


# =========================================================
# 파싱
# =========================================================

def parse_vehicle(data: Dict[str, Any]) -> VehicleInfo:
    vehicle = data.get("vehicle", {}) or {}
    return VehicleInfo(
        edition_id=vehicle.get("editionId", ""),
        edition_name=vehicle.get("editionName", ""),
        edition_price=vehicle.get("editionPrice"),
        btn_title=vehicle.get("btnTitle"),
        stock_flag=vehicle.get("stockFlag"),
        sales_type=vehicle.get("salesType"),
        electric_yn=vehicle.get("electricYn"),
        main_image=vehicle.get("mainKeyVisualImag"),
    )


def parse_trims(data: Dict[str, Any]) -> List[TrimOption]:
    results: List[TrimOption] = []

    trim_list = data.get("trim") or []
    for category in trim_list:
        category = category or {}

        category_title = category.get("title")
        category_code = category.get("code")

        for item in category.get("trimArrayList") or []:
            item = item or {}

            results.append(
                TrimOption(
                    category_title=category_title,
                    category_code=category_code,
                    pcode=item.get("pcode"),
                    trim_name=item.get("trimNm"),
                    trim_img=item.get("trimImg"),
                    activation=item.get("activation"),
                    status=item.get("status"),
                    sf_yn=item.get("sfYN"),
                )
            )

    return results


def parse_usp(data: Dict[str, Any]) -> List[UspItem]:
    results: List[UspItem] = []

    usp_list = data.get("usp") or []
    for section in usp_list:
        section = section or {}

        section_seq = section.get("editionDispSeq")
        section_type = section.get("editionDispType")
        section_title = section.get("editionDispTitle")
        section_subtitle = section.get("editionDispSubTitle")
        section_image = section.get("editionImg")

        sub_items = section.get("uspSubInfoDTOList") or []

        if not sub_items:
            results.append(
                UspItem(
                    section_seq=section_seq,
                    section_type=section_type,
                    section_title=section_title,
                    section_subtitle=section_subtitle,
                    section_image=section_image,
                    item_seq=None,
                    item_type=None,
                    item_title=None,
                    item_description=None,
                    item_image=None,
                    link=section.get("link"),
                )
            )
            continue

        for item in sub_items:
            item = item or {}

            results.append(
                UspItem(
                    section_seq=section_seq,
                    section_type=section_type,
                    section_title=section_title,
                    section_subtitle=section_subtitle,
                    section_image=section_image,
                    item_seq=item.get("editionDispSeq"),
                    item_type=item.get("editionSubType"),
                    item_title=item.get("editionDispTitle"),
                    item_description=item.get("editionDispDescription"),
                    item_image=item.get("editionImg"),
                    link=item.get("link"),
                )
            )

    return results


def normalize_detail_json(payload: Dict[str, Any]) -> Dict[str, Any]:
    root = payload.get("response") or {}
    if not isinstance(root, dict):
        root = {}

    vehicle = parse_vehicle(root)
    trims = parse_trims(root)
    usps = parse_usp(root)

    return {
        "vehicle": asdict(vehicle),
        "trim_count": len(trims),
        "usp_count": len(usps),
        "trims": [asdict(x) for x in trims],
        "usps": [asdict(x) for x in usps],
    }


# =========================================================
# 저장
# =========================================================

def save_json(path: Path, data: Any) -> None:
    path.write_text(
        json.dumps(data, ensure_ascii=False, indent=2),
        encoding="utf-8"
    )


def crawl_one(model_config: Dict[str, str]) -> Dict[str, Any]:
    model_id = model_config["model_id"]
    template_path = model_config["template_path"]

    url = build_detail_url(model_id)
    print(f"[INFO] fetching {model_id} -> {url}")

    payload = request_json(url, model_id, template_path)
    print(json.dumps(payload, ensure_ascii=False)[:500])

    if not payload.get("success") or not payload.get("response"):
        return {
            "model_id": model_id,
            "template_path": template_path,
            "success": False,
            "error": payload.get("apiError", {}).get("message", "Unknown API error"),
            "raw_file": None,
            "summary_file": None,
        }

    normalized = normalize_detail_json(payload)

    vehicle = normalized.get("vehicle", {})
    edition_id = vehicle.get("edition_id") or model_id
    edition_name = vehicle.get("edition_name") or model_id
    file_stub = safe_filename(f"{edition_id}_{edition_name}")

    raw_path = RAW_DIR / f"{file_stub}.json"
    summary_path = SUMMARY_DIR / f"{file_stub}.json"

    save_json(raw_path, payload)
    save_json(summary_path, normalized)

    return {
        "model_id": model_id,
        "template_path": template_path,
        "edition_id": edition_id,
        "edition_name": edition_name,
        "raw_file": str(raw_path),
        "summary_file": str(summary_path),
        "trim_count": normalized.get("trim_count", 0),
        "usp_count": normalized.get("usp_count", 0),
        "success": True,
    }


def main() -> None:
    ensure_dirs()

    results = []
    for model_config in MODEL_CONFIGS:
        try:
            result = crawl_one(model_config)
            results.append(result)
        except Exception as e:
            print(f"[ERROR] {model_config['model_id']}: {e}")
            results.append({
                "model_id": model_config["model_id"],
                "template_path": model_config["template_path"],
                "success": False,
                "error": str(e),
            })

        time.sleep(REQUEST_SLEEP)

    save_json(INDEX_FILE, results)
    ok_count = sum(1 for x in results if x.get("success"))
    print(f"[DONE] success={ok_count}/{len(results)}")
    print(f"[DONE] index saved -> {INDEX_FILE}")


if __name__ == "__main__":
    main()