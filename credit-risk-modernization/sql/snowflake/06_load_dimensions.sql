-- =====================================================
-- Load Credit Risk Data Mart Dimensions
-- =====================================================


-- -----------------------------------------------------
-- Customer Dimension
-- -----------------------------------------------------

INSERT INTO mart.dim_customer (
    customer_id,
    customer_name,
    state,
    annual_income,
    customer_since
)
SELECT DISTINCT
    customer_id,
    customer_name,
    state,
    annual_income,
    customer_since
FROM staging.credit_risk_clean;


-- -----------------------------------------------------
-- Loan Dimension
-- -----------------------------------------------------

INSERT INTO mart.dim_loan (
    loan_id,
    customer_id,
    loan_product,
    original_amount,
    interest_rate,
    start_date,
    term_months
)
SELECT DISTINCT
    loan_id,
    customer_id,
    loan_product,
    original_amount,
    interest_rate,
    start_date,
    term_months
FROM staging.credit_risk_clean;


-- -----------------------------------------------------
-- Date Dimension
-- -----------------------------------------------------

INSERT INTO mart.dim_date (
    date_key,
    full_date,
    day_number,
    month_number,
    month_name,
    quarter_number,
    year_number
)
SELECT DISTINCT
    TO_CHAR(snapshot_date, 'YYYYMMDD')::INTEGER AS date_key,
    snapshot_date AS full_date,
    EXTRACT(DAY FROM snapshot_date)::INTEGER,
    EXTRACT(MONTH FROM snapshot_date)::INTEGER,
    TRIM(TO_CHAR(snapshot_date, 'Month')),
    EXTRACT(QUARTER FROM snapshot_date)::INTEGER,
    EXTRACT(YEAR FROM snapshot_date)::INTEGER
FROM staging.credit_risk_clean;


-- -----------------------------------------------------
-- Risk Category Dimension
-- -----------------------------------------------------

INSERT INTO mart.dim_risk_category (
    risk_key,
    risk_category,
    risk_rank,
    risk_description
)
VALUES
    (1, 'Current', 1, 'Loan is not past due'),
    (2, 'Early Delinquency', 2, 'Loan is between 1 and 29 days past due'),
    (3, 'Delinquent', 3, 'Loan is between 30 and 59 days past due'),
    (4, 'High Risk', 4, 'Loan is between 60 and 89 days past due'),
    (5, 'Default', 5, 'Loan is 90 or more days past due'),
    (6, 'Unknown', 6, 'Risk category could not be determined');