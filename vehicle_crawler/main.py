import schedule
import time
from playwright.sync_api import sync_playwright

from crawlers.benz.summary_crawler import run_summary_crawler
from crawlers.benz.inventory_crwaler import run_inventory_crawler
# from db.parser.benz.benz_inventory_parser import enrich
# from db.db import save


def job():
    print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] 크롤링 작업을 시작합니다.")

    #── 크롤링 ──
    with sync_playwright() as p:
        try:
            run_summary_crawler(p)
            run_inventory_crawler(p)
            print("크롤링 완료!")
        except Exception as e:
            print(f"크롤링 오류: {e}")
            return

    # # ── 파싱 ──
    # try:
    #     vehicles = parse()
    #     vehicles = enrich(vehicles)
    #     print(f"파싱 완료: {len(vehicles)}개 차량")
    # except Exception as e:
    #     print(f"파싱 오류: {e}")
    #     return

    # # ── DB 저장 ──
    # try:
    #     save(vehicles)
    # except Exception as e:
    #     print(f"DB 저장 오류: {e}")


job()
# schedule.every().day.at("03:00").do(job)

# while True:
#     schedule.run_pending()
#     time.sleep(60)