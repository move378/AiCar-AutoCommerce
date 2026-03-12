import os
from dotenv import load_dotenv

load_dotenv()

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

BENZ_SUMMARY_DIR    = os.path.join(BASE_DIR, "crawlers", "benz", "data", "summary")  # 수정
BENZ_INVENTORY_PATH = os.path.join(BASE_DIR, "crawlers", "benz", "data", "inventory_data.json")

USER_DATA_DIR = os.path.join(BASE_DIR, "sessions", "benz user session")
SESSIONS_DIR  = os.path.join(BASE_DIR, "sessions", "benz user session")
URL_DIR       = os.path.join(BASE_DIR, "crawlers", "benz", "url")

MAX_RETRIES      = 3
RATE_LIMIT_WAIT  = 60

DB_HOST     = os.getenv("DB_HOST", "localhost")
DB_PORT     = int(os.getenv("DB_PORT", 5432))
DB_NAME     = os.getenv("DB_NAME", "")
DB_USER     = os.getenv("DB_USER", "")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")