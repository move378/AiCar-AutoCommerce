import schedule
import time
import json
from dataclasses import asdict
from playwright.sync_api import sync_playwright
from collections import Counter

from crawlers.benz.summary_crawler import run_summary_crawler
from crawlers.fuel_efficiency import crawl_fuel_efficiency
from db.parser.benz.summary_parser import summary_parser
from db.parser.benz.fuel_efficiency_parser import enrich_fuel_efficiency
from db.db import save


def job():
    print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] 크롤링 작업을 시작합니다.")

    # ── 크롤링 ──
    with sync_playwright() as p:
        try:
            # run_summary_crawler(p)
            crawl_fuel_efficiency(p, 'benz', '벤츠')
            print("크롤링 완료!")
        except Exception as e:
            print(f"크롤링 오류: {e}")
            return

    # ── 파싱 ──
    try:
        vehicles = summary_parser()
        vehicles = enrich_fuel_efficiency(vehicles, "benz")
        print(f"파싱 완료: {len(vehicles)}개 차량")


        d = [v.trim.body_type_code for v in vehicles]
        counter = Counter(d)

        # for d, count in counter.items():
        #     # print(f"{d}: {count}개")

        with open("vehicles_debug.json", "w", encoding="utf-8") as f:
            json.dump([asdict(v) for v in vehicles], f, ensure_ascii=False, indent=2)
        print("vehicles_debug.json 저장 완료!")
    except Exception as e:
        print(f"파싱 오류: {e}")
        return

    # ── DB 저장 ──
    try:
        save(vehicles)
    except Exception as e:
        print(f"DB 저장 오류: {e}")


job()
# schedule.every().day.at("03:00").do(job)

# while True:
#     schedule.run_pending()
#     time.sleep(60)