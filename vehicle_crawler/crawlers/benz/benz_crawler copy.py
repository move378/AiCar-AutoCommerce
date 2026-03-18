import json
import os
import time
import random
from playwright.sync_api import sync_playwright

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
SAVE_DIR = os.path.join(BASE_DIR, 'entries', 'Benz')
if not os.path.exists(SAVE_DIR):
    os.makedirs(SAVE_DIR)

MAX_RETRIES = 3
RATE_LIMIT_WAIT = 60

def _handle_cookie_banner(page):
    selectors = [
        "wb7-button[data-test='handle-accept-all-button']",
        "wb7-button.button--accept-all",
        "button[data-test='handle-accept-all-button']",
        ".button--accept-all"
    ]
    print("   => 쿠키 배너 확인 중...")
    for selector in selectors:
        try:
            button = page.wait_for_selector(selector, timeout=1000, state="visible")
            if button:
                time.sleep(random.uniform(0.5, 1.5))
                button.click()
                print(f"   => [쿠키 자동 수락] '{selector}' 클릭 완료")
                page.wait_for_timeout(2000)
                return True
        except:
            continue
    print("   => 쿠키 배너 없음")
    return False

def _urlCollect(page):
    try:
        url = "https://www.mercedes-benz.co.kr/passengercars/configurator.html?group=all&subgroup=see-all"
        page.goto(url, timeout=50000)
        # _handle_cookie_banner(page)
        page.wait_for_timeout(1000)

        links = page.query_selector_all("._vmos-cards-list__wrapper_m8x1e_58 ._vmos-card-button-group__list_zw8m0_137 .wbx-button.wbx-button--medium.wbx-button--primary")
        target_urls = []
        for link in links:
            href = link.get_attribute("href")
            if href and "/car-configurator.html/motorization/" in href:
                full_url = "https://www.mercedes-benz.co.kr" + href if href.startswith('/') else href
                target_urls.append(full_url)

        target_urls = list(set(target_urls))
        print(f"발견된 URL: {len(target_urls)}개")

        with open(os.path.join(BASE_DIR, "urls.json"), "w", encoding="utf-8") as f:
            json.dump(target_urls, f, ensure_ascii=False, indent=4)
        print(f"urls.json 저장 완료")

        return target_urls
    except Exception as e:
        print(f"메인 페이지 접속 실패: {e}")
        return []


def _first_page(page, url):
    try:
        captured = []

        def handle_response(response):
            if "entry?vehicleId=" in response.url:
                try:
                    captured.append(response.json())
                except:
                    pass

        page.on("response", handle_response)

        page.goto(url, timeout=10000)
        page.wait_for_selector("wb7-button")
        page.locator("wb7-button", has_text="지금 시작").click()
        page.wait_for_timeout(3000)
        page.remove_listener("response", handle_response) 

        if captured:
            motorization_data = captured[0]
            model_count = len(motorization_data["motorizations"]["tiles"])
            print(f"모델 {model_count}개 발견")
            _second_page(page, model_count)

    except Exception as e:
        print(f"첫번째 페이지 접속 실패: {e}")
        return None
        
def _second_page(page, model_count):
    for i in range(model_count):
        print(f"{i+1}번째 모델 처리 중...")
        
        summary_data = []
        
        def handle_summary(response):
            if "entry?vehicleId=" in response.url:
                try:
                    data = response.json()
                    if data.get("step") == "SUMMARY":
                        summary_data.append(data)
                except:
                    pass
        
        success = False
        for retry in range(MAX_RETRIES):
            summary_data.clear()
            page.on("response", handle_summary)
            page.locator("wb7-link", has_text="기술 데이터 및 기본 사양 표시").nth(i).click()
            page.wait_for_selector("[data-testid='wb-modal-close-button']")
            
            timeout = 10
            start = time.time()
            while not summary_data and time.time() - start < timeout:
                page.wait_for_timeout(500)
            
            page.remove_listener("response", handle_summary)
            
            if summary_data:
                success = True
                break
            
            print(f"{i+1}번째 모델 SUMMARY 수신 실패 - 재시도 {retry+1}/{MAX_RETRIES}")
            page.locator("[data-testid='wb-modal-close-button']").first.click()
            page.wait_for_selector("wb7-modal[visible]", state="detached", timeout=5000)
        
        if not success:
            print(f"{i+1}번째 모델 SUMMARY 수신 최종 실패, 스킵")
        else:
            data = summary_data[0]
            model_name = data['vehicle']['name']
            print(f"SUMMARY 데이터 수신: {model_name}")
            
            model_dir = os.path.join(SAVE_DIR, model_name)
            os.makedirs(model_dir, exist_ok=True)
            
            with open(os.path.join(model_dir, "summary.json"), "w", encoding="utf-8") as f:
                json.dump(data, f, ensure_ascii=False, indent=4)
            
            print(f"저장 완료: {model_name}/summary.json")
        
        page.locator("[data-testid='wb-modal-close-button']").first.click()
        page.wait_for_selector("wb7-modal[visible]", state="detached", timeout=5000)   

def run_benz_crawler(playwright):
    user_data_dir = os.path.join(BASE_DIR, "./sessions/benz_user_session")
    context = playwright.chromium.launch_persistent_context(
        user_data_dir,
        headless=False,
        args=['--disable-quic', '--disable-http2', '--disable-blink-features=AutomationControlled'],
        user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
    )
    page = context.pages[0]
    page.add_init_script("""
        Object.defineProperty(navigator, 'webdriver', { get: () => false });
    """)

    target_urls = _urlCollect(page)
    if not target_urls:
        return

    for url in target_urls:
        _first_page(page,url)


if __name__ == "__main__":
    with sync_playwright() as p:
        run_benz_crawler(p)