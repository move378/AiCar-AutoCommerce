import os
import time
import json
from config import BASE_DIR
from playwright.sync_api import sync_playwright
from crawlers.benz.benz_crawler_utils import handle_cookie_banner
from crawlers.benz.benz_crawler_utils import get_benz_context

TARGET_URL = "https://www.mercedes-benz.co.kr/passengercars/buy/new-car/search-results.html/vehicleCategory-new-passenger-cars/sortType-price-asc"

LOAD_MORE_SELECTOR = "button[data-datadog-id='load-more-button']"
SPINNER_SELECTOR   = "wbx-spinner"
SESSION_FILE = os.path.join(BASE_DIR, "data/inventory_data.json")

BASE_URL = "https://www.mercedes-benz.co.kr/passengercars/buy/new-car/product.html/"
OUTPUT_URLS_FILE = os.path.join(BASE_DIR, "url/inventory_urls.json")

def _click_load_more(page):
    click_count = 0
 
    while True:
        try:
            btn = page.locator("button[data-datadog-id='load-more-button']")
            btn.wait_for(state="visible", timeout=5000)
 
            btn.click()
            click_count += 1
            print(f"[{click_count}] 차량 더 보기 클릭")
 
            # 버튼 disabled 될 때까지 대기 (로딩 시작)
            page.wait_for_selector(
                "button[data-datadog-id='load-more-button']:disabled",
                timeout=5000
            )
            print(f"[{click_count}] 로딩 중...")
 
            # 버튼 enabled 될 때까지 대기 (로딩 완료) or 버튼 사라지면 종료
            try:
                page.wait_for_selector(
                    "button[data-datadog-id='load-more-button']:not(:disabled)",
                    timeout=30000
                )
                print(f"[{click_count}] 로딩 완료")
            except Exception:
                print("모든 차량 로딩 완료")
                break
 
            page.wait_for_timeout(1000)
            
 
        except Exception as e:
            print(f"루프 탈출: {e}")
            break
 
    print(f"\n총 {click_count}회 클릭 완료.")

def _session_load(page):
    data = page.evaluate("() => JSON.parse(sessionStorage.getItem('market-kr-ko-foc-prod-emh_ncos_products'))")

    with open(SESSION_FILE, "w", encoding="utf-8") as f:  # 여기
        json.dump(data, f, ensure_ascii=False, indent=4)

    print(f"세션 스토리지 저장 완료: {len(data)}개 항목")

def _extract_urls():
    with open(SESSION_FILE, "r", encoding="utf-8") as f:
        data = json.load(f)
 
    results = data.get("results", [])
    print(f"전체 차량 수: {len(results)}개")
 
    seen = set()
    vehicles = []
 
    for item in results:
        try:
            tech = item["technicalInformation"]
            model = item["vehicleModel"]
            code  = item["identification"]["code"]
 
            name        = model.get("name", "")
            fuel_type   = tech["engine"]["fuelType"]["formattedValue"]
            transmission = tech["transmission"]["transmissionCategory"]["formattedValue"]
            power       = tech["engine"]["power"]["combinedValue"]["formattedValue"]
 
            key = (name, fuel_type, transmission, power)
 
            if key in seen:
                continue
 
            seen.add(key)
            vehicles.append({
                "name": name,
                "fuel_type": fuel_type,
                "transmission": transmission,
                "power": power,
                "url": BASE_URL + code
            })
 
        except (KeyError, TypeError):
            continue
 
    print(f"중복 제거 후 차량 수: {len(vehicles)}개")
 
    os.makedirs(os.path.dirname(OUTPUT_URLS_FILE), exist_ok=True)
    with open(OUTPUT_URLS_FILE, "w", encoding="utf-8") as f:
        json.dump(vehicles, f, ensure_ascii=False, indent=4)
 
    print(f"저장 완료: vehicle_urls.json")


def run_inventory_crawler(playwright):
    
    context, page = get_benz_context(playwright)

    page.goto(TARGET_URL, wait_until="domcontentloaded", timeout=50000)
    handle_cookie_banner(page)
    page.wait_for_timeout(2000)

    if os.path.exists(SESSION_FILE):
        print("session_products.json 이미 존재 → 차량 더 보기 스킵")
        _extract_urls()  # 여기 추가
    else:
        _click_load_more(page)
        _session_load(page)
        page.wait_for_timeout(1000)
        _extract_urls()

    context.close()


if __name__ == "__main__":
    with sync_playwright() as p:
        run_inventory_crawler(p)