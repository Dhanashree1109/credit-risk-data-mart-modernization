-- =====================================================
-- Load legacy source tables into raw target tables
-- Simulates SQL Server to Snowflake ingestion
-- =====================================================

TRUNCATE TABLE raw.credit_scores;
TRUNCATE TABLE raw.payments;
TRUNCATE TABLE raw.loan_snapshots;
TRUNCATE TABLE raw.loans;
TRUNCATE TABLE raw.customers;


INSERT INTO raw.customers (
    customer_id,
    customer_name,
    state,
    annual_income,
    customer_since,
    source_system,
    load_timestamp,
    batch_id
)
SELECT
    customer_id,
    customer_name,
    state,
    annual_income,
    customer_since,
    'LEGACY_POSTGRES',
    CURRENT_TIMESTAMP,
    'BATCH_20260721_001'
FROM public.customers;


INSERT INTO raw.loans (
    loan_id,
    customer_id,
    loan_product,
    original_amount,
    interest_rate,
    start_date,
    term_months,
    source_system,
    load_timestamp,
    batch_id
)
SELECT
    loan_id,
    customer_id,
    loan_product,
    original_amount,
    interest_rate,
    start_date,
    term_months,
    'LEGACY_POSTGRES',
    CURRENT_TIMESTAMP,
    'BATCH_20260721_001'
FROM public.loans;


INSERT INTO raw.loan_snapshots (
    snapshot_date,
    loan_id,
    outstanding_balance,
    days_past_due,
    source_system,
    load_timestamp,
    batch_id
)
SELECT
    snapshot_date,
    loan_id,
    outstanding_balance,
    days_past_due,
    'LEGACY_POSTGRES',
    CURRENT_TIMESTAMP,
    'BATCH_20260721_001'
FROM public.loan_snapshots;


INSERT INTO raw.payments (
    payment_id,
    loan_id,
    payment_date,
    payment_amount,
    payment_status,
    source_system,
    load_timestamp,
    batch_id
)
SELECT
    payment_id,
    loan_id,
    payment_date,
    payment_amount,
    payment_status,
    'LEGACY_POSTGRES',
    CURRENT_TIMESTAMP,
    'BATCH_20260721_001'
FROM public.payments;


INSERT INTO raw.credit_scores (
    customer_id,
    score_date,
    credit_score,
    source_system,
    load_timestamp,
    batch_id
)
SELECT
    customer_id,
    score_date,
    credit_score,
    'LEGACY_POSTGRES',
    CURRENT_TIMESTAMP,
    'BATCH_20260721_001'
FROM public.credit_scores;