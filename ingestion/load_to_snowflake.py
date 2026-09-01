import os
import json
import tempfile
import requests
import snowflake.connector
from dotenv import load_dotenv

load_dotenv()

API_BASE_URL = os.getenv("MOCK_API_BASE_URL")
PAGE_SIZE = 1000


def get_snowflake_connection():
    return snowflake.connector.connect(
        account=os.getenv("SNOWFLAKE_ACCOUNT"),
        user=os.getenv("SNOWFLAKE_USER"),
        password=os.getenv("SNOWFLAKE_PASSWORD"),
        role=os.getenv("SNOWFLAKE_ROLE"),
        warehouse=os.getenv("SNOWFLAKE_WAREHOUSE"),
        database=os.getenv("SNOWFLAKE_DATABASE"),
        schema=os.getenv("SNOWFLAKE_SCHEMA"),
    )


def fetch_all_orders():
    all_orders = []
    page = 1

    while True:
        response = requests.get(
            f"{API_BASE_URL}/orders",
            params={
                "page": page,
                "page_size": PAGE_SIZE
            },
            timeout=30,
        )

        response.raise_for_status()
        payload = response.json()

        for order in payload["data"]:
            order["_source_page"] = page

        all_orders.extend(payload["data"])

        print(
            f"Fetched page {page} — "
            f"{len(payload['data'])} records "
            f"(running total: {len(all_orders)})"
        )

        if not payload["has_more"]:
            break

        page += 1

    return all_orders


def write_ndjson(orders):
    fd, path = tempfile.mkstemp(
        suffix=".json",
        prefix="orders_"
    )

    with os.fdopen(fd, "w", encoding="utf-8") as file:
        for order in orders:
            file.write(
                json.dumps(order, separators=(",", ":")) + "\n"
            )

    return path


def load_to_raw(local_file_path, conn):
    cursor = conn.cursor()

    stage_file_name = os.path.basename(local_file_path)

    try:
        cursor.execute(
            f"PUT file://{local_file_path} "
            f"@~/orders_stage "
            f"AUTO_COMPRESS=TRUE "
            f"OVERWRITE=TRUE"
        )

        print(f"Staged {stage_file_name}")

        cursor.execute("""
            DELETE FROM raw_orders
        """)

        print("Deleted existing RAW records")

        cursor.execute(f"""
            COPY INTO raw_orders (
                order_id,
                raw_payload,
                _source_page
            )
            FROM (
                SELECT
                    $1:order_id::NUMBER,
                    $1,
                    $1:_source_page::NUMBER
                FROM @~/orders_stage/{stage_file_name}.gz
            )
            FILE_FORMAT = (
                TYPE = JSON
            )
            ON_ERROR = 'ABORT_STATEMENT'
        """)

        conn.commit()

        print("RAW data loaded successfully")

        cursor.execute(
            f"REMOVE @~/orders_stage/{stage_file_name}.gz"
        )

    except Exception:
        conn.rollback()
        raise

    finally:
        cursor.close()


def main():
    print("Starting ingestion run...")

    if not API_BASE_URL:
        raise ValueError(
            "MOCK_API_BASE_URL is not set in .env"
        )

    orders = fetch_all_orders()

    print(
        f"Total records fetched from API: "
        f"{len(orders)}"
    )

    local_path = write_ndjson(orders)

    print(f"Wrote NDJSON file: {local_path}")

    conn = get_snowflake_connection()

    try:
        load_to_raw(local_path, conn)
    finally:
        conn.close()

        if os.path.exists(local_path):
            os.remove(local_path)

    print("Ingestion complete.")


if __name__ == "__main__":
    main()