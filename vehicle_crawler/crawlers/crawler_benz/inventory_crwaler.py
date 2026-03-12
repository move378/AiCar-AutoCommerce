import os
import time
import json
from playwright.sync_api import sync_playwright
from crawlers.crawler_benz.benz_crawler_utils import handle_cookie_banner
from crawlers.crawler_benz.benz_crawler_utils import get_benz_context


BASE_DIR = os.path.dirname(os.path.abspath(__file__))

TARGET_URL = "https://www.mercedes-benz.co.kr/passengercars/buy/new-car/search-results.html/vehicleCategory-new-passenger-cars/sortType-price-asc"

LOAD_MORE_SELECTOR = "button[data-datadog-id='load-more-button']"
SPINNER_SELECTOR   = "wbx-spinner"
SESSION_FILE = os.path.join(BASE_DIR, "session_products.json")


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


def run_inventory_crawler(playwright):
    user_data_dir = os.path.join(BASE_DIR, "./sessions/benz_user_session")
    context, page = get_benz_context(playwright, user_data_dir)

    page.goto(TARGET_URL, wait_until="domcontentloaded", timeout=50000)
    handle_cookie_banner(page)
    page.wait_for_timeout(2000)

    if os.path.exists(SESSION_FILE):
        print("session_products.json 이미 존재 → 차량 더 보기 스킵")
    else:
        _click_load_more(page)
        _session_load(page)

    input("\nEnter 누르면 브라우저 닫힙니다...")
    context.close()


if __name__ == "__main__":
    with sync_playwright() as p:
        run_inventory_crawler(p)