import requests
import json
import re
import time
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

def extract_number(text):
    """문자열에서 숫자(소수점 포함)만 추출하여 float로 반환합니다."""
    if not text:
        return None
    try:
        found = re.findall(r"[-+]?\d*\.\d+|\d+", str(text))
        return float(found[0]) if found else None
    except Exception:
        return None

def create_session():
    """재시도 로직이 포함된 HTTP 세션을 생성합니다."""
    session = requests.Session()
    # 지수 백오프 적용 (1초, 2초, 4초... 간격으로 최대 3번 재시도)
    retry = Retry(
        total=3,
        backoff_factor=1,
        status_forcelist=[429, 500, 502, 503, 504],
        allowed_methods=["POST"]
    )
    adapter = HTTPAdapter(max_retries=retry)
    session.mount("https://", adapter)
    return session

def get_efficiency_by_baumuster(baumuster):
    """
    벤츠 검색 API(GraphQL)를 직접 호출하여 특정 Baumuster 모델의 연비 데이터를 수집합니다.
    타임아웃과 세션을 강화하여 연결 안정성을 높였습니다.
    """
    url = "https://www.mercedes-benz.co.kr/api/graphql"
    
    query = """
    query getEfficiencyData($filter: SearchFilterInput) {
      search(filter: $filter) {
        results {
          identification {
            code
          }
          vehicleModel {
            baumuster
            name
          }
          emissionAndConsumption {
            attributes {
              FuelEconomyGrade
              FuelConsumptionAverage
              FuelConsumptionCity
              FuelConsumptionHighway
            }
          }
        }
      }
    }
    """
    
    variables = {
        "filter": {
            "baumuster": [baumuster],
            "first": 1
        }
    }
    
    # 헤더를 실제 브라우저와 더 유사하게 보강
    headers = {
        "Content-Type": "application/json",
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36",
        "Accept": "application/json, text/plain, */*",
        "Origin": "https://www.mercedes-benz.co.kr",
        "Referer": "https://www.mercedes-benz.co.kr/passengercars/buy/new-car/search-results.html/",
        "Accept-Language": "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7",
        "Sec-Fetch-Dest": "empty",
        "Sec-Fetch-Mode": "cors",
        "Sec-Fetch-Site": "same-origin"
    }

    session = create_session()

    try:
        payload = {"query": query, "variables": variables}
        # 타임아웃을 30초로 넉넉하게 연장
        response = session.post(url, json=payload, headers=headers, timeout=30)
        response.raise_for_status()
        
        data = response.json()
        results = data.get("data", {}).get("search", {}).get("results", [])
        
        if not results:
            print(f"[-] {baumuster} 모델의 재고 데이터를 찾을 수 없습니다. (현재 판매 중이 아닐 수 있음)")
            return None
            
        target_car = results[0]
        eff_attr = target_car.get("emissionAndConsumption", {}).get("attributes", {})
        
        return {
            "model_name": target_car["vehicleModel"]["name"],
            "baumuster": target_car["vehicleModel"]["baumuster"],
            "efficiency": {
                "combined": extract_number(eff_attr.get("FuelConsumptionAverage")),
                "city": extract_number(eff_attr.get("FuelConsumptionCity")),
                "highway": extract_number(eff_attr.get("FuelConsumptionHighway")),
                "grade": extract_number(eff_attr.get("FuelEconomyGrade"))
            }
        }

    except requests.exceptions.Timeout:
        print(f"[!] 타임아웃 발생: 서버 응답이 너무 느립니다. (Baumuster: {baumuster})")
    except Exception as e:
        print(f"[!] API 호출 중 오류 발생: {e}")
    finally:
        session.close()
    return None

if __name__ == "__main__":
    # 테스트할 Baumuster (A 220 예시)
    target_baumuster = "17704412" 
    
    print(f"[*] {target_baumuster} 모델의 연비 수집 시작...")
    result = get_efficiency_by_baumuster(target_baumuster)
    
    if result:
        print(f"[+] 수집 및 정제 완료: {result['model_name']}")
        print(f"    - 복합 연비: {result['efficiency']['combined']} km/ℓ")
        print(f"    - 연비 등급: {int(result['efficiency']['grade']) if result['efficiency']['grade'] else 'N/A'}등급")
    else:
        print("[-] 데이터 수집에 실패했습니다. 네트워크 상태나 Baumuster 코드를 확인하세요.")