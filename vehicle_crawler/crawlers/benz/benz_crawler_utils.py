import os
import time
import random
from config import SESSIONS_DIR

os.makedirs(SESSIONS_DIR, exist_ok=True)

def handle_cookie_banner(page):
    try:
        btn = page.locator("wb7-button[data-test='handle-accept-all-button']").first
        btn.wait_for(state="visible", timeout=5000)
        time.sleep(random.uniform(0.5, 1.2))
        btn.click()
        print("   => [Cookie] 전체 동의 완료")
        page.wait_for_timeout(2000)
        return True
    except Exception as e:
        print(f"   => [Cookie] 배너 없음 또는 실패: {e}")
    return False

def get_benz_context(playwright):
    context = playwright.chromium.launch_persistent_context(
        SESSIONS_DIR,
        headless=False,
        args=[
            '--disable-quic', 
            '--disable-http2', 
            '--disable-blink-features=AutomationControlled'
        ],
        user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
    )
    
    page = context.pages[0]
    page.add_init_script("""
        Object.defineProperty(navigator, 'webdriver', { get: () => false });
    """)
    
    return context, page