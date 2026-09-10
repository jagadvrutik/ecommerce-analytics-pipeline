# E-Commerce Analytics Pipeline

A mock API generates 60,000+ order records → an idempotent Python script
loads them into Snowflake → dbt Cloud transforms raw data into tested,
documented models → CI runs on every PR → a scheduled job handles daily
orchestration. Built to learn how a real pipeline fits together end to end,
not just the dbt part.

## Flow

Mock REST API (Flask + Faker, paginated, 60K orders)
│
▼
Python ingestion (atomic PUT + COPY INTO, idempotent)
│
▼
Snowflake RAW (VARIANT, untouched)
│
▼
dbt Cloud: staging → intermediate → marts
(sources, seeds, snapshots, incremental, tests, docs)
│
├──► CI on every PR (dbt build)
└──► Scheduled production job (daily)


## Stack
Python, Flask, Snowflake, dbt Cloud (Fusion engine), GitHub, dbt Cloud CI/scheduling.

## Data model
9 dbt models · 2 seeds · 1 snapshot

| Layer | Models |
|---|---|
| Staging | `stg_orders`, `stg_customers`, `stg_products` |
| Intermediate | `int_orders_enriched` (joins orders + cost, calculates margin) |
| Marts | `dim_customers`, `dim_products`, `fct_orders` (incremental), `mart_customer_summary`, `mart_daily_sales` |

## Worth knowing before you dig in

- **Idempotent, verified not assumed** — ran ingestion twice, confirmed 60,000 rows both times.
- **Found and fixed a real atomicity bug** — an early delete-then-insert wasn't transactional; a mid-run failure left the table half-emptied. Rebuilt as one atomic `TRUNCATE` + `COPY INTO`.
- **Referential gaps are intentional** — seed data covers only part of the customer/product ID range, so `relationships` tests have something real to catch. Set to `warn` with a threshold, not silenced.
- **Snapshot history, actually proven** — forced a real segment change in the seed data, reran, confirmed two-row SCD Type 2 history (closed + current).
- **Incremental came last, on purpose** — built `fct_orders` as a plain table first, converted once tests were solid, to avoid debugging incremental logic and business logic at the same time.

## RBAC
Three least-privilege Snowflake roles, one per pipeline stage — `LOADER` (RAW only), `TRANSFORMER` (dbt, staging/marts), `ANALYST` (read-only) — each with its own service user, not a personal login.

## Known limits
Mock data is static per run, so incremental picks up zero new rows after the first load — expected here, not a real-world streaming setup. Everything currently lands in one production schema rather than split across staging/marts, a fair tradeoff at this scale.

## Run it locally
bash
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt

cd mock_api && python app.py          # terminal 1
cd ingestion && python load_to_snowflake.py   # terminal 2

dbt itself runs through dbt Cloud — see `dbt_project/`.

## Structure

mock_api/       — Flask + Faker mock order API
ingestion/      — Idempotent, atomic Python → Snowflake loader
snowflake/      — RBAC and schema setup SQL
dbt_project/    — dbt Cloud project
