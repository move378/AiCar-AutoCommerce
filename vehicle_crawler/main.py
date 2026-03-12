import schedule
import time
import sys
import os
from playwright.sync_api import sync_playwright
from crawlers.crawler_benz.summary_crawler import run_summary_crawler
from crawlers.crawler_benz.inventory_crwaler import run_inventory_crawler

def job():
    print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] 크롤링 작업을 시작합니다.")
    with sync_playwright() as p:
        try:
            # run_summary_crawler(p)
            run_inventory_crawler(p)
            print("작업 완료!")
        except Exception as e:
            print(f"오류 발생: {e}")

# 매일 새벽 3시에 실행하도록 예약 (시간은 원하시는 대로 수정 가능)
job()
# schedule.every().day.at("18:00").do(job)

# print("스케줄러가 가동되었습니다. 이제 이 프로그램은 종료되지 않고 새벽마다 크롤러를 실행합니다.")

while True:
    schedule.run_pending()
    time.sleep(60) # 1분마다 확인