import json
import os
import re
from typing import Optional

BASE_URL = "https://min24.energy.or.kr/trans_hp/AHP/HP_03/HP_03_01_010.do"
API_URL = "AHP_L.do"

def crawl_fuel_efficiency(p, brand: str, brand_label: Optional[str] = None):
    label = brand_label if brand_label else brand

    browser = p.chromium.launch(headless=False)
    page = browser.new_page()

    captured_data = []

    def handle_response(response):
        if API_URL in response.url and response.request.method == "POST":
            try:
                body = response.json()
                captured_data.append(body)
                print(f"✅ 캡처 성공: {len(body.get('list', []))}건")
            except Exception as e:
                print(f"❌ 파싱 실패: {e}")

    page.on("response", handle_response)

    print(f"페이지 접속 중... (브랜드: {label})")
    page.goto(BASE_URL, wait_until="networkidle")

    # _csrf 토큰 추출
    csrf_token = page.evaluate("""
        () => {
            const el = document.querySelector('input[name="_csrf"]');
            return el ? el.value : null;
        }
    """)
    print(f"_csrf: {csrf_token}")

    # li 클릭으로 체크박스 선택
    li = page.locator('li', has_text=re.compile(f'^{label}$')).first
    if li.count() == 0 and brand_label:
        print(f"'{label}' 로 못 찾음, '{brand}' 로 재시도")
        li = page.locator(f'li:has-text("{brand}")').first
    li.click()
    page.wait_for_timeout(1000)

    # 검색 버튼 클릭 (실제 selector 확인 필요)
    page.click('.search_button_wrap a.search_button')
    page.wait_for_load_state("networkidle")
    page.wait_for_timeout(2000)

    # JSON 저장
    if captured_data:
        os.makedirs("crawlers/{brand}/data", exist_ok=True)
        save_path = f"crawlers/{brand}/data/fuel_efficiency.json"
        with open(save_path, "w", encoding="utf-8") as f:
            json.dump(captured_data[-1], f, ensure_ascii=False, indent=2)
        print(f"✅ 저장 완료: {save_path}")
    else:
        print("❌ 캡처된 데이터 없음")

    browser.close()