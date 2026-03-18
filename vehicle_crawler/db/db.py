"""
DB 저장 로직
list[VehicleData] → PostgreSQL INSERT
"""

import psycopg2
from psycopg2.extras import RealDictCursor

from config import DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD
from db.dto import VehicleData, Brand, Model, Trim, IceSpec, EvSpec, Option,TrimImage
from config import DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD

def get_connection():
    return psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
    )


def save(vehicles: list[VehicleData]):
    print(DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD)

    conn = get_connection()
    try:
        with conn:
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                for v in vehicles:
                    try:
                        brand_id = _upsert_brand(cur, v)
                        model_id = _upsert_model(cur, v, brand_id)
                        trim_id  = _upsert_trim(cur, v, model_id)
                        _upsert_images(cur, v, trim_id)

                        if v.trim.ice_spec:
                            _upsert_ice_spec(cur, v, trim_id)
                        if v.trim.ev_spec:
                            _upsert_ev_spec(cur, v, trim_id)

                        for option in v.trim.options:
                            option_id = _upsert_option(cur, option)
                            _upsert_trim_option(cur, trim_id, option_id, option)

                    except Exception as e:
                        print(f"❌ 저장 실패 [{v.trim.name}]: {e}")
                        raise

        print(f"DB 저장 완료: {len(vehicles)}개 차량")
    finally:
        conn.close()


def _upsert_brand(cur, v: VehicleData) -> str:
    cur.execute("""
        INSERT INTO vehicles_brands (name, country, logo_url)
        VALUES (%s, %s, %s)
        ON CONFLICT (name) DO UPDATE
            SET country  = EXCLUDED.country,
                logo_url = EXCLUDED.logo_url
        RETURNING id
    """, (v.brand.name, v.brand.country, v.brand.logo_url))
    return cur.fetchone()["id"]


def _upsert_model(cur, v: VehicleData, brand_id: str) -> str:
    cur.execute("""
        INSERT INTO vehicles_models (brand_id, model_name, classification, segment)
        VALUES (%s, %s, %s, %s)
        ON CONFLICT (brand_id, model_name) DO UPDATE
            SET classification = EXCLUDED.classification,
                segment        = EXCLUDED.segment
        RETURNING id
    """, (brand_id, v.model.name, v.model.classification, v.model.segment))
    return cur.fetchone()["id"]


def _upsert_trim(cur, v: VehicleData, model_id: str) -> str:
    cur.execute("""
        INSERT INTO vehicles_trims (
            model_id, trim_name, body_type, body_type_code,
            year, base_price, fuel_type,
            seating_capacity, max_output, acceleration,
            top_speed, length, width, height,
            curb_weight, transmission, transmission_type, image_url, doors
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (model_id, trim_name) DO UPDATE
            SET body_type        = EXCLUDED.body_type,
                body_type_code   = EXCLUDED.body_type_code,
                year             = EXCLUDED.year,
                base_price       = EXCLUDED.base_price,
                fuel_type        = EXCLUDED.fuel_type,
                seating_capacity = EXCLUDED.seating_capacity,
                max_output       = EXCLUDED.max_output,
                acceleration     = EXCLUDED.acceleration,
                top_speed        = EXCLUDED.top_speed,
                length           = EXCLUDED.length,
                width            = EXCLUDED.width,
                height           = EXCLUDED.height,
                curb_weight      = EXCLUDED.curb_weight,
                transmission     = EXCLUDED.transmission,
                image_url        = EXCLUDED.image_url,
                doors            = EXCLUDED.doors
        RETURNING id
    """, (
        model_id, v.trim.name, v.trim.body_type, v.trim.body_type_code,
        v.trim.model_year, v.trim.base_price, v.trim.fuel_type,
        v.trim.seating_capacity, v.trim.max_output, v.trim.acceleration_0_100,
        v.trim.top_speed, v.trim.length, v.trim.width, v.trim.height,
        v.trim.curb_weight, v.trim.transmission, v.trim.image_url, v.trim.doors,
    ))
    return cur.fetchone()["id"]


def _upsert_ice_spec(cur, v: VehicleData, trim_id: str):
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
        trim_id,
        v.trim.ice_spec.displacement,
        v.trim.ice_spec.fuel_tank_capacity,
        v.trim.ice_spec.efficiency_combined,
        v.trim.ice_spec.efficiency_city,
        v.trim.ice_spec.efficiency_highway,
        v.trim.ice_spec.energy_grade,
        v.trim.ice_spec.cylinders,
    ))


def _upsert_ev_spec(cur, v: VehicleData, trim_id: str):
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
        trim_id,
        v.trim.ev_spec.battery_capacity,
        v.trim.ev_spec.max_range,
        v.trim.ev_spec.efficiency_combined,
        v.trim.ev_spec.efficiency_city,
        v.trim.ev_spec.efficiency_highway,
        v.trim.ev_spec.energy_grade,
    ))


def _upsert_option(cur, option) -> str:
    cur.execute("""
        INSERT INTO vehicles_options (name, category, description)
        VALUES (%s, %s, %s)
        ON CONFLICT DO NOTHING
        RETURNING id
    """, (option.name, option.category, option.description))
    row = cur.fetchone()
    if row:
        return row["id"]
    cur.execute("SELECT id FROM vehicles_options WHERE name = %s", (option.name,))
    return cur.fetchone()["id"]


def _upsert_trim_option(cur, trim_id: str, option_id: str, option):
    cur.execute("""
        INSERT INTO vehicles_trim_options (trim_id, option_id, price, is_standard, availability)
        VALUES (%s, %s, %s, %s, %s)
        ON CONFLICT DO NOTHING
    """, (trim_id, option_id, option.price, option.is_standard, option.availability))


def _upsert_images(cur, v: VehicleData, trim_id: str):
    for img in v.images:
        cur.execute("""
            INSERT INTO vehicles_trim_images (trim_id, image_url, image_type)
            VALUES (%s, %s, %s)
            ON CONFLICT DO NOTHING
        """, (trim_id, img.image_url, img.image_type))
