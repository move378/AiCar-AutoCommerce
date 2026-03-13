"""
DB 저장 로직
list[VehicleData] → PostgreSQL INSERT
"""

import psycopg2
from psycopg2.extras import RealDictCursor

from config import DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD
from vehicle_crawler.db.parser.benz._ import VehicleData


# ──────────────────────────────────────────────
# 연결
# ──────────────────────────────────────────────

def get_connection():
    return psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
    )


# ──────────────────────────────────────────────
# 저장
# ──────────────────────────────────────────────

def save(vehicles: list[VehicleData]):
    conn = get_connection()
    try:
        with conn:
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                for v in vehicles:
                    brand_id = _upsert_brand(cur, v)
                    model_id = _upsert_model(cur, v, brand_id)
                    trim_id  = _upsert_trim(cur, v, model_id)

                    if v.ice_spec:
                        _upsert_ice_spec(cur, v, trim_id)
                    if v.ev_spec:
                        _upsert_ev_spec(cur, v, trim_id)

        print(f"DB 저장 완료: {len(vehicles)}개 차량")
    finally:
        conn.close()


# ──────────────────────────────────────────────
# UPSERT 함수들
# ──────────────────────────────────────────────

def _upsert_brand(cur, v: VehicleData) -> int:
    cur.execute("""
        INSERT INTO vehicles_brands (name, country, logo_url)
        VALUES (%s, %s, %s)
        ON CONFLICT (name) DO UPDATE
            SET country  = EXCLUDED.country,
                logo_url = EXCLUDED.logo_url
        RETURNING id
    """, (v.brand.name, v.brand.country, v.brand.logo_url))
    return cur.fetchone()["id"]


def _upsert_model(cur, v: VehicleData, brand_id: int) -> int:
    cur.execute("""
        INSERT INTO vehicles_models (brand_id, model_name, category, classification, segment)
        VALUES (%s, %s, %s, %s, %s)
        ON CONFLICT (brand_id, model_name) DO UPDATE
            SET category       = EXCLUDED.category,
                classification = EXCLUDED.classification,
                segment        = EXCLUDED.segment
        RETURNING id
    """, (brand_id, v.model.model_name, v.model.category, v.model.classification, v.model.segment))
    return cur.fetchone()["id"]


def _upsert_trim(cur, v: VehicleData, model_id: int) -> int:
    cur.execute("""
        INSERT INTO vehicles_trims (
            model_id, trim_name, year, base_price, fuel_type,
            seating_capacity, trunk_capacity, max_output, drive_type,
            acceleration, length, width, height, wheelbase,
            curb_weight, transmission, image_url, top_speed, doors
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (model_id, trim_name) DO UPDATE
            SET year             = EXCLUDED.year,
                base_price       = EXCLUDED.base_price,
                fuel_type        = EXCLUDED.fuel_type,
                seating_capacity = EXCLUDED.seating_capacity,
                trunk_capacity   = EXCLUDED.trunk_capacity,
                max_output       = EXCLUDED.max_output,
                drive_type       = EXCLUDED.drive_type,
                acceleration     = EXCLUDED.acceleration,
                length           = EXCLUDED.length,
                width            = EXCLUDED.width,
                height           = EXCLUDED.height,
                wheelbase        = EXCLUDED.wheelbase,
                curb_weight      = EXCLUDED.curb_weight,
                transmission     = EXCLUDED.transmission,
                image_url        = EXCLUDED.image_url,
                top_speed        = EXCLUDED.top_speed,
                doors            = EXCLUDED.doors
        RETURNING id
    """, (
        model_id, v.trim.trim_name, v.trim.year, v.trim.base_price, v.trim.fuel_type,
        v.trim.seating_capacity, v.trim.trunk_capacity, v.trim.max_output, v.trim.drive_type,
        v.trim.acceleration, v.trim.length, v.trim.width, v.trim.height, v.trim.wheelbase,
        v.trim.curb_weight, v.trim.transmission, v.trim.image_url, v.trim.top_speed, v.trim.doors,
    ))
    return cur.fetchone()["id"]


def _upsert_ice_spec(cur, v: VehicleData, trim_id: int):
    cur.execute("""
        INSERT INTO vehicles_ice_specs (
            trim_id, displacement, fuel_tank_capacity,
            fuel_eff_combined, fuel_eff_city, fuel_eff_highway,
            energy_grade, cylinder
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (trim_id) DO UPDATE
            SET displacement       = EXCLUDED.displacement,
                fuel_tank_capacity = EXCLUDED.fuel_tank_capacity,
                fuel_eff_combined  = EXCLUDED.fuel_eff_combined,
                fuel_eff_city      = EXCLUDED.fuel_eff_city,
                fuel_eff_highway   = EXCLUDED.fuel_eff_highway,
                energy_grade       = EXCLUDED.energy_grade,
                cylinder           = EXCLUDED.cylinder
    """, (
        trim_id, v.ice_spec.displacement, v.ice_spec.fuel_tank_capacity,
        v.ice_spec.fuel_eff_combined, v.ice_spec.fuel_eff_city, v.ice_spec.fuel_eff_highway,
        v.ice_spec.energy_grade, v.ice_spec.cylinder,
    ))


def _upsert_ev_spec(cur, v: VehicleData, trim_id: int):
    cur.execute("""
        INSERT INTO vehicles_ev_specs (
            trim_id, battery_capacity, max_range,
            eff_combined, eff_city, eff_highway, energy_grade
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (trim_id) DO UPDATE
            SET battery_capacity = EXCLUDED.battery_capacity,
                max_range        = EXCLUDED.max_range,
                eff_combined     = EXCLUDED.eff_combined,
                eff_city         = EXCLUDED.eff_city,
                eff_highway      = EXCLUDED.eff_highway,
                energy_grade     = EXCLUDED.energy_grade
    """, (
        trim_id, v.ev_spec.battery_capacity, v.ev_spec.max_range,
        v.ev_spec.eff_combined, v.ev_spec.eff_city, v.ev_spec.eff_highway,
        v.ev_spec.energy_grade,
    ))