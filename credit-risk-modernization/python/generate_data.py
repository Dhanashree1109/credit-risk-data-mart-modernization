from pathlib import Path
import csv
import random
from datetime import date, timedelta


# Makes the generated data repeatable.
# Every time you run the script, you will get the same records.
random.seed(42)


# ---------------------------------------------------------
# Locate the project folders
# ---------------------------------------------------------

current_file = Path(__file__).resolve()

# generate_data.py is inside:
# credit-risk-modernization/python/
project_folder = current_file.parent.parent

raw_data_folder = project_folder / "data" / "raw"

# Create the folder if it does not already exist.
raw_data_folder.mkdir(parents=True, exist_ok=True)


# ---------------------------------------------------------
# Reference values
# ---------------------------------------------------------

first_names = [
    "Amy", "John", "Sarah", "Michael", "Emily",
    "David", "Priya", "James", "Sophia", "Daniel",
    "Olivia", "Robert", "Neha", "William", "Ava",
    "Joseph", "Mia", "Arjun", "Isabella", "Ethan"
]

last_names = [
    "Smith", "Patel", "Brown", "Lee", "Davis",
    "Wilson", "Johnson", "Garcia", "Miller", "Taylor",
    "Anderson", "Thomas", "Moore", "Martin", "Jackson"
]

states = [
    "NY", "CA", "TX", "FL", "WA",
    "IL", "NJ", "PA", "OH", "GA"
]

loan_products = [
    "Mortgage",
    "Auto",
    "Personal",
    "Credit Card"
]

payment_statuses = [
    "Completed",
    "Completed",
    "Completed",
    "Completed",
    "Failed"
]


# ---------------------------------------------------------
# Helper functions
# ---------------------------------------------------------

def random_date(start_date: date, end_date: date) -> date:
    """
    Return a random date between start_date and end_date.
    """
    total_days = (end_date - start_date).days
    random_days = random.randint(0, total_days)
    return start_date + timedelta(days=random_days)


def get_term_months(loan_product: str) -> int:
    """
    Return a realistic loan term based on product type.
    """
    if loan_product == "Mortgage":
        return random.choice([180, 240, 360])

    if loan_product == "Auto":
        return random.choice([36, 48, 60, 72])

    if loan_product == "Personal":
        return random.choice([12, 24, 36, 48, 60])

    # Credit cards are revolving credit.
    return 0


def get_original_amount(loan_product: str) -> float:
    """
    Return a realistic original loan amount.
    """
    if loan_product == "Mortgage":
        return round(random.uniform(150000, 650000), 2)

    if loan_product == "Auto":
        return round(random.uniform(15000, 65000), 2)

    if loan_product == "Personal":
        return round(random.uniform(5000, 50000), 2)

    return round(random.uniform(1000, 25000), 2)


def get_interest_rate(loan_product: str) -> float:
    """
    Return a realistic interest-rate range.
    """
    if loan_product == "Mortgage":
        return round(random.uniform(4.5, 7.5), 2)

    if loan_product == "Auto":
        return round(random.uniform(5.0, 11.0), 2)

    if loan_product == "Personal":
        return round(random.uniform(8.0, 18.0), 2)

    return round(random.uniform(15.0, 29.0), 2)


def get_days_past_due() -> int:
    """
    Generate days-past-due values across multiple risk groups.
    """
    risk_bucket = random.choices(
        population=[
            "Current",
            "Early Delinquency",
            "Delinquent",
            "High Risk",
            "Default"
        ],
        weights=[55, 18, 12, 8, 7],
        k=1
    )[0]

    if risk_bucket == "Current":
        return 0

    if risk_bucket == "Early Delinquency":
        return random.randint(1, 29)

    if risk_bucket == "Delinquent":
        return random.randint(30, 59)

    if risk_bucket == "High Risk":
        return random.randint(60, 89)

    return random.randint(90, 150)


# ---------------------------------------------------------
# Create the datasets
# ---------------------------------------------------------

customers = []
loans = []
loan_snapshots = []
payments = []
credit_scores = []

snapshot_date = date(2026, 7, 21)


for record_number in range(1, 101):

    customer_id = f"C{record_number:03d}"
    loan_id = f"L{record_number:03d}"
    payment_id = f"P{record_number:03d}"

    customer_name = (
        f"{random.choice(first_names)} "
        f"{random.choice(last_names)}"
    )

    customer_since = random_date(
        date(2015, 1, 1),
        date(2025, 12, 31)
    )

    annual_income = random.randint(35000, 220000)

    state = random.choice(states)

    # Customer record
    customers.append({
        "customer_id": customer_id,
        "customer_name": customer_name,
        "state": state,
        "annual_income": annual_income,
        "customer_since": customer_since.isoformat()
    })

    # Loan information
    loan_product = random.choice(loan_products)
    original_amount = get_original_amount(loan_product)
    interest_rate = get_interest_rate(loan_product)
    term_months = get_term_months(loan_product)

    loan_start_date = random_date(
        max(customer_since, date(2016, 1, 1)),
        date(2026, 6, 30)
    )

    loans.append({
        "loan_id": loan_id,
        "customer_id": customer_id,
        "loan_product": loan_product,
        "original_amount": original_amount,
        "interest_rate": interest_rate,
        "start_date": loan_start_date.isoformat(),
        "term_months": term_months
    })

    # Current loan condition
    outstanding_percentage = random.uniform(0.20, 0.95)

    outstanding_balance = round(
        original_amount * outstanding_percentage,
        2
    )

    days_past_due = get_days_past_due()

    loan_snapshots.append({
        "snapshot_date": snapshot_date.isoformat(),
        "loan_id": loan_id,
        "outstanding_balance": outstanding_balance,
        "days_past_due": days_past_due
    })

    # Payment record
    payment_date = random_date(
        date(2026, 1, 1),
        snapshot_date
    )

    payment_amount = round(
        random.uniform(100, max(150, original_amount * 0.02)),
        2
    )

    payment_status = random.choice(payment_statuses)

    payments.append({
        "payment_id": payment_id,
        "loan_id": loan_id,
        "payment_date": payment_date.isoformat(),
        "payment_amount": payment_amount,
        "payment_status": payment_status
    })

    # Credit-score record
    credit_score = random.randint(520, 820)

    credit_scores.append({
        "customer_id": customer_id,
        "score_date": snapshot_date.isoformat(),
        "credit_score": credit_score
    })


# ---------------------------------------------------------
# Write CSV files
# ---------------------------------------------------------

def write_csv(file_name: str, records: list[dict]) -> None:
    """
    Write a list of dictionaries into a CSV file.
    """
    if not records:
        raise ValueError(f"No data available for {file_name}")

    file_path = raw_data_folder / file_name

    with file_path.open(
        mode="w",
        newline="",
        encoding="utf-8"
    ) as csv_file:

        writer = csv.DictWriter(
            csv_file,
            fieldnames=records[0].keys()
        )

        writer.writeheader()
        writer.writerows(records)

    print(f"Created {file_path} with {len(records)} records.")


write_csv("customers.csv", customers)
write_csv("loans.csv", loans)
write_csv("loan_snapshots.csv", loan_snapshots)
write_csv("payments.csv", payments)
write_csv("credit_scores.csv", credit_scores)

print("\nData generation completed successfully.")