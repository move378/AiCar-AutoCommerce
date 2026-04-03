import re
import json
import time
from pathlib import Path

import cloudscraper
from bs4 import BeautifulSoup

BASE_DIR = Path(__file__).resolve().parent
INPUT_DIR = BASE_DIR / "data" / "summary"
OUTPUT_DIR = BASE_DIR / "data" / "danawa_spec"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

LINEUP_MAP = {
    "BMW 5시리즈": "53465",
    "BMW The New iX3": "53717",
    "BMW 3 Series": "53453",
    "BMW X3": "53503",
    "BMW X5": "53499",
    "BMW X6": "53506",
    "BMW X7": "53511",
    "BMW iX": "53354",
    "BMW iX1": "53452",
    "BMW iX2": "53549",
    "BMW i5": "53473",
    "BMW i7": "52643",
    "BMW 7 Series": "52641",
    "BMW 8 Series": "52580",
    "BMW Z4": "53493",
    "BMW M240i": "53489",
    "BMW XM": "53540",
}

scraper = cloudscraper.create_scraper(
    browser={"browser": "chrome", "platform": "windows", "mobile": False}
)

COMMON_HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/136.0.0.0 Safari/537.36"
    ),
    "Referer": "https://auto.danawa.com/",
    "Accept-Language": "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
    "Connection": "keep-alive",
}

def normalize_name(name: str) -> str:
    name = name.replace("_", " ")
    name = re.sub(r"\.json$", "", name, flags=re.I)
    name = re.sub(r"^(OEM|OIM|OIU|OOM|OPM|OMG|PMG)\d+(_[A-Z0-9]+)?_", "", name)

    # 앞쪽 수식어 제거
    name = name.replace("THE NEW ", "")
    name = name.replace("The New ", "")
    name = name.replace("뉴 ", "")

    # 에디션 문구 제거
    remove_phrases = [
        "프로즌 딥 그린 에디션",
        "M 스포츠 프로 스페셜 에디션",
        "M 퍼포먼스 파츠 에디션",
        "30주년 기념 스페셜 에디션",
        "인디비주얼 에디션",
        "베스트셀러 에디션",
        "인디비주얼 투톤 드라빗 그레이 에디션",
        "퍼스트 에디션",
        "30주년 에디션",
        "프로",
        "그란 쿠페",
        "컨버터블",
        "쿠페",
        "xDrive",
        "eDrive",
        "M 스포츠",
        "Label",
    ]
    for phrase in remove_phrases:
        name = name.replace(phrase, "")

    name = re.sub(r"\s+", " ", name).strip()
    return name

def infer_lineup_id(filename: str):
    n = normalize_name(filename)

    # 직접 키 매칭
    for model_name, lineup_id in sorted(LINEUP_MAP.items(), key=lambda x: len(x[0]), reverse=True):
        key = model_name.replace("The New ", "").replace("THE NEW ", "")
        if key in n:
            return model_name, lineup_id

    # 예외 매핑
    if "iX3" in n:
        return "BMW The New iX3", "53717"
    if "iX2" in n:
        return "BMW iX2", "53549"
    if "iX1" in n:
        return "BMW iX1", "53452"
    if re.search(r"\bX3\b", n):
        return "BMW X3", "53503"
    if re.search(r"\bX5\b", n):
        return "BMW X5", "53499"
    if re.search(r"\bX6\b", n):
        return "BMW X6", "53506"
    if re.search(r"\bX7\b", n):
        return "BMW X7", "53511"
    if re.search(r"\bi5\b", n):
        return "BMW i5", "53473"
    if re.search(r"\bi7\b", n):
        return "BMW i7", "52643"
    if re.search(r"\biX\b", n):
        return "BMW iX", "53354"
    if "520i" in n or "530i" in n or "550e" in n:
        return "BMW 5시리즈", "53465"
    if "320i" in n or "M340i" in n or "M3" in n or "M440i" in n:
        return "BMW 3 Series", "53453"
    if "740i" in n or "750e" in n:
        return "BMW 7 Series", "52641"
    if "M850i" in n:
        return "BMW 8 Series", "52580"
    if "Z4" in n:
        return "BMW Z4", "53493"
    if "M240i" in n or "M235" in n:
        return "BMW M240i", "53489"
    if "XM" in n:
        return "BMW XM", "53540"

    return None, None

def parse_spec_table(html: str):
    soup = BeautifulSoup(html, "html.parser")
    result = {}

    for table in soup.select("table"):
        for row in table.select("tr"):
            th = row.find("th")
            td = row.find("td")
            if th and td:
                key = th.get_text(" ", strip=True)
                val = td.get_text(" ", strip=True)
                if key and val:
                    result[key] = val

    return result

def fetch_danawa_spec(lineup_id: str):
    url = f"https://auto.danawa.com/auto/modelPopup.php?Type=spec&Lineup={lineup_id}"
    resp = scraper.get(url, headers=COMMON_HEADERS, timeout=30)
    resp.raise_for_status()
    resp.encoding = "utf-8"
    spec_data = parse_spec_table(resp.text)
    return spec_data, url

def main():
    print("BASE_DIR =", BASE_DIR)
    print("INPUT_DIR =", INPUT_DIR)
    print("INPUT_DIR exists =", INPUT_DIR.exists())

    files = sorted(
        p for p in INPUT_DIR.glob("*.json")
        if p.name != "summary.json"
    )

    print("json 파일 수 =", len(files))
    for f in files[:10]:
        print("[FOUND]", f.name)

    success, skip, fail = 0, 0, 0

    for path in files:
        print(f"[PROCESS] {path.name}")

        model_name, lineup_id = infer_lineup_id(path.name)

        if not lineup_id:
            print(f"[SKIP] 매칭 실패: {path.name}")
            skip += 1
            continue

        try:
            spec_data, source_url = fetch_danawa_spec(lineup_id)

            with open(path, "r", encoding="utf-8") as f:
                original = json.load(f)

            original["danawa_lineup_id"] = lineup_id
            original["danawa_model_name"] = model_name
            original["danawa_source_url"] = source_url
            original["danawa_spec"] = spec_data

            out_path = OUTPUT_DIR / path.name
            with open(out_path, "w", encoding="utf-8-sig") as f:
                json.dump(original, f, ensure_ascii=False, indent=2)

            print(f"[OK] {path.name}")
            success += 1
            time.sleep(1)

        except Exception as e:
            print(f"[ERROR] {path.name}: {e}")
            fail += 1

    print("\n===== 완료 =====")
    print(f"성공: {success}")
    print(f"건너뜀: {skip}")
    print(f"실패: {fail}")

if __name__ == "__main__":
    main()