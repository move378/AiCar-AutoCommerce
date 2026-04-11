"""
차량 이미지 다운로드 스크립트

vehicles_debug.json에서 이미지 URL을 읽어 Playwright로 다운로드한 후
로컬 디렉토리에 저장한다.

사용법:
  cd vehicle_crawler
  python download_images.py

저장 경로: /var/data/images/{brand}/{model}_{trim}_{angle}.webp
"""

import json
import os
import re
import time
from pathlib import Path
from playwright.sync_api import sync_playwright

# 설정
VEHICLES_JSON = "vehicles_debug.json"
IMAGE_DIR = os.environ.get("IMAGE_DIR", "/var/data/images")
SERVER_BASE_URL = os.environ.get("SERVER_BASE_URL", "http://18.191.163.53:8080")


def safe_filename(text: str) -> str:
    """파일명에 사용할 수 없는 문자를 제거하고 소문자로 변환"""
    text = text.strip().lower()
    text = re.sub(r"[\\/:*?\"<>|+\s]+", "_", text)
    text = re.sub(r"_+", "_", text)
    return text[:100] if text else "unknown"


def download_image(page, url: str, save_path: str) -> bool:
    """Playwright 페이지 컨텍스트로 이미지를 다운로드"""
    try:
        response = page.request.get(url, timeout=15000)
        if response.status == 200:
            body = response.body()
            if len(body) > 1000:  # 최소 1KB 이상이어야 실제 이미지
                os.makedirs(os.path.dirname(save_path), exist_ok=True)
                with open(save_path, "wb") as f:
                    f.write(body)
                return True
            else:
                print(f"  [SKIP] 이미지 크기 너무 작음: {len(body)} bytes")
                return False
        else:
            print(f"  [FAIL] HTTP {response.status}")
            return False
    except Exception as e:
        print(f"  [ERROR] {e}")
        return False


def main():
    # vehicles_debug.json 로드
    with open(VEHICLES_JSON, "r", encoding="utf-8") as f:
        vehicles = json.load(f)

    print(f"총 {len(vehicles)}대 차량, 이미지 다운로드 시작")
    print(f"저장 경로: {IMAGE_DIR}")

    # DB 업데이트용 매핑 저장
    url_mapping = []  # [{old_url, new_url, brand, model, trim, angle}]

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context()

        # 벤츠 사이트에 먼저 접속하여 쿠키/세션 확보
        page = context.new_page()
        print("벤츠 사이트 세션 확보 중...")
        try:
            page.goto(
                "https://www.mercedes-benz.co.kr/passengercars/configurator.html",
                timeout=30000,
            )
            page.wait_for_timeout(3000)
            # 쿠키 배너 처리
            try:
                accept_btn = page.query_selector(
                    "button.wb-button--accept-all, button[data-test='handle-accept-all']"
                )
                if accept_btn:
                    accept_btn.click()
                    page.wait_for_timeout(1000)
            except Exception:
                pass
            print("세션 확보 완료")
        except Exception as e:
            print(f"세션 확보 실패: {e} — 직접 다운로드 시도")

        success_count = 0
        fail_count = 0

        for i, vehicle in enumerate(vehicles):
            brand_name = safe_filename(vehicle["brand"]["name"])
            model_name = safe_filename(vehicle["model"]["name"])
            trim_name = safe_filename(vehicle["trim"]["name"])
            images = vehicle.get("images", [])

            if not images:
                continue

            print(
                f"\n[{i+1}/{len(vehicles)}] {vehicle['brand']['name']} {vehicle['trim']['name']}"
            )

            for img in images:
                url = img.get("image_url")
                angle = img.get("image_type", "unknown")
                if not url:
                    continue

                filename = f"{model_name}_{trim_name}_{angle}.webp"
                save_path = os.path.join(IMAGE_DIR, brand_name, filename)

                # 이미 다운로드된 파일은 스킵
                if os.path.exists(save_path):
                    print(f"  [EXIST] {angle}")
                    new_url = f"{SERVER_BASE_URL}/static/images/{brand_name}/{filename}"
                    url_mapping.append(
                        {
                            "old_url": url,
                            "new_url": new_url,
                            "brand": brand_name,
                            "model": model_name,
                            "trim": trim_name,
                            "angle": angle,
                        }
                    )
                    success_count += 1
                    continue

                print(f"  [{angle}] 다운로드 중...")
                if download_image(page, url, save_path):
                    print(f"  [OK] {save_path}")
                    new_url = f"{SERVER_BASE_URL}/static/images/{brand_name}/{filename}"
                    url_mapping.append(
                        {
                            "old_url": url,
                            "new_url": new_url,
                            "brand": brand_name,
                            "model": model_name,
                            "trim": trim_name,
                            "angle": angle,
                        }
                    )
                    success_count += 1
                else:
                    fail_count += 1

                time.sleep(0.5)  # Rate limiting

        browser.close()

    # URL 매핑 저장
    mapping_path = "image_url_mapping.json"
    with open(mapping_path, "w", encoding="utf-8") as f:
        json.dump(url_mapping, f, ensure_ascii=False, indent=2)

    print(f"\n{'='*50}")
    print(f"완료: 성공 {success_count}, 실패 {fail_count}")
    print(f"URL 매핑: {mapping_path}")
    print(f"이미지 경로: {IMAGE_DIR}")


if __name__ == "__main__":
    main()
