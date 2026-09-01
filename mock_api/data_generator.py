from faker import Faker
import random
from datetime import datetime, timedelta

fake = Faker()

PRODUCT_CATEGORIES = [
    "Electronics", "Home & Kitchen", "Clothing", "Books",
    "Sports & Outdoors", "Beauty", "Toys", "Grocery"
]

PAYMENT_METHODS = ["credit_card", "debit_card", "upi", "net_banking", "cod"]
ORDER_STATUSES = ["completed", "shipped", "cancelled", "returned", "pending"]


def generate_order(order_id: int) -> dict:
    """Generate a single realistic e-commerce order record."""
    order_date = fake.date_time_between(start_date="-2y", end_date="now")
    quantity = random.randint(1, 5)
    unit_price = round(random.uniform(5.0, 500.0), 2)

    return {
        "order_id": order_id,
        "customer_id": random.randint(1, 5000),   # 5,000 distinct customers
        "product_id": random.randint(1, 800),      # 800 distinct products
        "product_category": random.choice(PRODUCT_CATEGORIES),
        "quantity": quantity,
        "unit_price": unit_price,
        "total_amount": round(quantity * unit_price, 2),
        "payment_method": random.choice(PAYMENT_METHODS),
        "order_status": random.choice(ORDER_STATUSES),
        "order_date": order_date.isoformat(),
        "shipping_city": fake.city(),
        "shipping_country": "India",
        "created_at": datetime.utcnow().isoformat(),
    }