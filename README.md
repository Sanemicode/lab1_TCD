# Modern Data Stack — Music Streaming (варіант 13)

Навчальний проєкт з дисципліни «Технології сховищ даних» (НУ «Львівська політехніка»).
Повний ELT-конвеєр для сервісу стрімінгу музики.

## Предметна область
| Таблиця | Тип | Опис |
|---|---|---|
| listeners | вимір | слухачі |
| tracks | вимір | треки |
| artists | вимір | виконавці |
| streams | факт | прослуховування |
| subscriptions | факт | оплати підписок |

## Архітектура (ЛР №1)
`Python (Faker + Pandas) → Parquet (data_lake/) + PostgreSQL 15 у Docker → схема raw`

Raw-шар зберігає дані «як є», включно з навмисними дефектами:
дублікати слухачів (~5%), NULL email (10%), NULL promo_code (20%), NULL device (~3%).

## Запуск
```bash
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
docker compose up -d
python data_generator.py
```
Підключення: `postgresql://admin:adminpassword@localhost:5432/music_dwh`

Перевірка: `docker exec -it dwh_postgres psql -U admin -d music_dwh -c "select count(*) from raw.streams;"`

## Roadmap
- [x] ЛР1 — Ingestion (Python + Docker + PostgreSQL)
- [ ] ЛР2 — dbt, схема «Зірка»
- [ ] ЛР3 — Airflow
- [ ] ЛР4 — Metabase + Data Lineage
