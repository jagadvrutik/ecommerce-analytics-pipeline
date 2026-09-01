from flask import Flask, jsonify, request
from data_generator import generate_order

app = Flask(__name__)

TOTAL_RECORDS = 60000  
PAGE_SIZE_DEFAULT = 500
PAGE_SIZE_MAX = 1000


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok"}), 200


@app.route("/orders", methods=["GET"])
def get_orders():
   
    page = int(request.args.get("page", 1))
    page_size = min(int(request.args.get("page_size", PAGE_SIZE_DEFAULT)), PAGE_SIZE_MAX)

    start_id = (page - 1) * page_size + 1
    end_id = min(start_id + page_size - 1, TOTAL_RECORDS)

    if start_id > TOTAL_RECORDS:
        return jsonify({"data": [], "page": page, "has_more": False}), 200

    orders = [generate_order(oid) for oid in range(start_id, end_id + 1)]
    has_more = end_id < TOTAL_RECORDS

    return jsonify({
        "data": orders,
        "page": page,
        "page_size": page_size,
        "total_records": TOTAL_RECORDS,
        "has_more": has_more,
    }), 200


if __name__ == "__main__":
    app.run(debug=True, port=5000)