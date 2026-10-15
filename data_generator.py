"""ЛР №1 (варіант 13: Стрімінг музики) — генерація OLTP-даних та завантаження в raw-шар DWH.

Виміри: listeners, tracks, artists
Факти:  streams, subscriptions
Навмисні "брудні" дані: 10% NULL email, ~5% дублікатів слухачів,
20% NULL у subscriptions.promo_code, ~3% NULL у streams.device.
"""
import os
import random

import pandas as pd
from faker import Faker
from sqlalchemy import create_engine, text

fake = Faker("en_US")
Faker.seed(42)
random.seed(42)

DB_URL = os.getenv(
    "DWH_URL", "postgresql+psycopg2://admin:adminpassword@localhost:5433/music_dwh"
   )
GENRES = ["Pop", "Rock", "Hip-Hop", "Electronic", "Jazz", "Classical", "Indie", "Metal"]
PLANS = {"Free": 0.0, "Individual": 9.99, "Duo": 12.99, "Family": 15.99, "Student": 4.99}


# ---------------- ВИМІРИ ----------------
def generate_artists(n=100):
    return pd.DataFrame([{
        "artist_id": i,
        "artist_name": fake.name() if random.random() > 0.5 else fake.word().capitalize() + " " + fake.word().capitalize(),
        "country": fake.country(),
        "debut_year": random.randint(1980, 2024),
    } for i in range(1, n + 1)])


def generate_tracks(artist_ids, n=1000):
    return pd.DataFrame([{
        "track_id": i,
        "artist_id": random.choice(artist_ids),
        "title": fake.catch_phrase(),
        "genre": random.choice(GENRES),
        "duration_sec": random.randint(90, 420),
        "release_date": fake.date_between(start_date="-10y", end_date="today"),
    } for i in range(1, n + 1)])


def generate_listeners(n=1000):
    rows = [{
        "listener_id": i,
        "full_name": fake.name(),
        "email": fake.email() if random.random() > 0.1 else None,  # 10% NULL
        "country": fake.country(),
        "registration_date": fake.date_between(start_date="-2y", end_date="today"),
    } for i in range(1, n + 1)]
    df = pd.DataFrame(rows)
    dups = df.sample(frac=0.05, random_state=42)  # ~5% дублікатів
    return pd.concat([df, dups], ignore_index=True)


# ---------------- ФАКТИ ----------------
def generate_streams(listener_ids, track_ids, n=20000):
    devices = ["mobile", "desktop", "web", "smart_speaker", "tv"]
    return pd.DataFrame([{
        "stream_id": fake.uuid4(),
        "listener_id": random.choice(listener_ids),
        "track_id": random.choice(track_ids),
        "stream_ts": fake.date_time_between(start_date="-1y", end_date="now"),
        "seconds_played": random.randint(5, 420),
        "device": random.choice(devices) if random.random() > 0.03 else None,
    } for _ in range(n)])


def generate_subscriptions(listener_ids, n=3000):
    rows = []
    for i in range(1, n + 1):
        plan = random.choice(list(PLANS))
        rows.append({
            "subscription_id": i,
            "listener_id": random.choice(listener_ids),
            "plan": plan,
            "amount": PLANS[plan],
            "payment_date": fake.date_time_between(start_date="-1y", end_date="now"),
            "payment_status": random.choices(["paid", "failed", "refunded"], weights=[90, 7, 3])[0],
            "promo_code": fake.bothify("PROMO-????-##").upper() if random.random() > 0.2 else None,  # 20% NULL
        })
    return pd.DataFrame(rows)


def build_all():
    df_artists = generate_artists()
    df_tracks = generate_tracks(df_artists["artist_id"].tolist())
    df_listeners = generate_listeners()
    listener_ids = df_listeners["listener_id"].unique().tolist()  # лише унікальні ID
    track_ids = df_tracks["track_id"].tolist()
    return {
        "artists": df_artists,
        "tracks": df_tracks,
        "listeners": df_listeners,
        "streams": generate_streams(listener_ids, track_ids),
        "subscriptions": generate_subscriptions(listener_ids),
    }


def save_parquet(tables):
    os.makedirs("data_lake", exist_ok=True)
    for name, df in tables.items():
        df.to_parquet(f"data_lake/raw_{name}.parquet", index=False)


def load_data_to_dwh(tables=None):
    """Full Load у схему raw (if_exists='replace' => ідемпотентно)."""
    tables = tables or build_all()
    engine = create_engine(DB_URL)
    with engine.begin() as conn:
        conn.execute(text("CREATE SCHEMA IF NOT EXISTS raw;"))
    for name, df in tables.items():
        print(f"Завантаження {name} ({len(df)} рядків)...")
        df.to_sql(name, engine, schema="raw", if_exists="replace", index=False)
    print("Дані успішно завантажені у схему 'raw'!")


if __name__ == "__main__":
    data = build_all()
    for n, d in data.items():
        print(f"Згенеровано {n}: {len(d)} рядків")
    save_parquet(data)
    load_data_to_dwh(data)
