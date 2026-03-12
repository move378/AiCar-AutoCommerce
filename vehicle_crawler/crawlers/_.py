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

FIND_IN_SHADOW_JS = """
    function findInShadow(root, selector, depth = 0) {
        if (depth > 10) return [];
        const results = [];
        for (const el of root.querySelectorAll('*')) {
            if (el.shadowRoot) results.push(...findInShadow(el.shadowRoot, selector, depth + 1));
        }
        results.push(...root.querySelectorAll(selector));
        return results;
    }
"""

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
            button = page.wait_for_selector(selector, timeout=5000, state="visible")
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
        page.goto(url, timeout=90000)
        _handle_cookie_banner(page)
        page.wait_for_timeout(1)

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

def _is_rate_limited(page):
    try:
        content = page.content()
        if "429" in content or "Too Many Requests" in content or "Access Denied" in content:
            return True
        if "error" in page.url or "blocked" in page.url:
            return True
    except:
        pass
    return False

def _get_model_names(page):
    """Shadow DOM에서 모델명 목록 반환"""
    return page.evaluate(f"""
        () => {{
            {FIND_IN_SHADOW_JS}
            const btns = findInShadow(document, '.cc-motorization-tile-card-content-bar__select');
            // 선택된 첫 번째 모델은 버튼이 없으므로, 선택된 모델명도 포함해서 전체 수집
            const allNames = findInShadow(document, '[class*="heading"]');
            // 모델 카드 heading만 필터링 (중복 제거)
            const names = [];
            for (const el of allNames) {{
                const text = el.textContent.trim();
                if (text && !names.includes(text) && el.closest('[class*="motorization-tile"]')) {{
                    names.push(text);
                }}
            }}
            return names;
        }}
    """)

def _click_nth_select_btn(page, index):
    """Shadow DOM 안의 n번째 '내 차량 만들기' 버튼 클릭"""
    page.evaluate(f"""
        () => {{
            {FIND_IN_SHADOW_JS}
            const btns = findInShadow(document, '.cc-motorization-tile-card-content-bar__select');
            if (btns[{index}]) btns[{index}].click();
        }}
    """)

def _click_detail_link(page):
    """선택된 모델의 '기술 데이터 및 기본 사양 표시' 클릭 → SUMMARY API 트리거"""
    page.evaluate(f"""
        () => {{
            {FIND_IN_SHADOW_JS}
            const all = findInShadow(document, '*');
            const el = all.find(e => e.textContent?.trim() === '기술 데이터 및 기본 사양 표시');
            if (el) el.click();
        }}
    """)

def save_summary_data(data, model_name):
    try:
        clean_name = model_name.replace('/', '_').replace('\\', '_').replace(':', '_').replace(' ', '_')
        model_dir = os.path.join(SAVE_DIR, clean_name)
        os.makedirs(model_dir, exist_ok=True)

        filepath = os.path.join(model_dir, "summary.json")
        with open(filepath, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=4)
        print(f"   ✅ [저장 완료] Benz/{clean_name}/summary.json")
        return True
    except Exception as e:
        print(f"   ❌ [저장 에러] {e}")
    return False

def crawl_url(page, url):
    # 1. start 페이지 이동
    page.goto(url, wait_until="domcontentloaded", timeout=60000)
    page.wait_for_timeout(2000)

    if _is_rate_limited(page):
        raise Exception("RATE_LIMITED")

    # 2. 지금 시작 클릭 → MOTORIZATION 페이지로 이동
    with page.expect_response(
        lambda r: "api.oneweb.mercedes-benz.com" in r.url
                  and "entry" in r.url
                  and "proposedStep=MOTORIZATION" in r.url
                  and r.status == 200,
        timeout=45000
    ) as _:
        start_btn = page.wait_for_selector("text=지금 시작", timeout=10000, state="visible")
        start_btn.click()
        print(f"   => '지금 시작' 클릭")

    page.wait_for_timeout(2000)

    if _is_rate_limited(page):
        raise Exception("RATE_LIMITED")

    # 3. 모델명 목록 가져오기
    model_names = _get_model_names(page)
    print(f"   => 모델 {len(model_names)}개 발견: {model_names}")

    if not model_names:
        print("   ⚠️ 모델 없음, 스킵")
        return

    # 4. 각 모델 처리
    for i, model_name in enumerate(model_names):
        print(f"   => [{i+1}/{len(model_names)}] {model_name} 처리 중...")

        for attempt in range(1, MAX_RETRIES + 1):
            try:
                if attempt > 1:
                    print(f"      재시도 {attempt}/{MAX_RETRIES}")

                # i > 0이면 "내 차량 만들기" 클릭으로 해당 모델 선택
                if i > 0:
                    _click_nth_select_btn(page, i - 1)
                    print(f"      => '내 차량 만들기' 클릭")
                    page.wait_for_timeout(1500)

                # "기술 데이터 및 기본 사양 표시" 클릭 → SUMMARY API 캐치
                with page.expect_response(
                    lambda r: "api.oneweb.mercedes-benz.com" in r.url
                              and "entry" in r.url
                              and "proposedStep=SUMMARY" in r.url
                              and r.status == 200,
                    timeout=45000
                ) as response_info:
                    _click_detail_link(page)
                    print(f"      => '기술 데이터 및 기본 사양 표시' 클릭")

                response = response_info.value

                if response.status == 429:
                    raise Exception("RATE_LIMITED")

                data = response.json()
                save_summary_data(data, model_name)
                break

            except Exception as e:
                if "RATE_LIMITED" in str(e):
                    print(f"      ⚠️ [차단 감지] {RATE_LIMIT_WAIT}초 대기...")
                    time.sleep(RATE_LIMIT_WAIT)
                else:
                    print(f"      ⚠️ [에러] {e}")
                    wait = random.uniform(5, 10) * attempt
                    print(f"      => {wait:.1f}초 대기 후 재시도...")
                    time.sleep(wait)

        time.sleep(random.uniform(2, 4))

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

    failed_urls = []

    print("\nStep 2: 데이터 수집 시작...")
    for index, url in enumerate(target_urls):
        print(f"\n[{index+1}/{len(target_urls)}] {url}")

        for attempt in range(1, MAX_RETRIES + 1):
            try:
                if attempt > 1:
                    print(f"   => URL 재시도 {attempt}/{MAX_RETRIES}")
                crawl_url(page, url)
                break
            except Exception as e:
                if "RATE_LIMITED" in str(e):
                    print(f"   ⚠️ [차단 감지] {RATE_LIMIT_WAIT}초 대기...")
                    time.sleep(RATE_LIMIT_WAIT)
                else:
                    print(f"   ⚠️ [에러] {e}")
                    if attempt == MAX_RETRIES:
                        failed_urls.append(url)
                    else:
                        wait = random.uniform(5, 10) * attempt
                        time.sleep(wait)

        time.sleep(random.uniform(5, 8))

    if failed_urls:
        with open(os.path.join(BASE_DIR, "failed_urls.json"), "w", encoding="utf-8") as f:
            json.dump(failed_urls, f, ensure_ascii=False, indent=4)
        print(f"\n❌ 실패한 URL {len(failed_urls)}개 → failed_urls.json 저장됨")

    print(f"\n✅ 완료! 성공: {len(target_urls) - len(failed_urls)}/{len(target_urls)}")
    context.close()

if __name__ == "__main__":
    with sync_playwright() as p:
        run_benz_crawler(p)