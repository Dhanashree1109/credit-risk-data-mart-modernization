-- =====================================================
-- Raw target tables
-- These simulate the Snowflake raw layer
-- =====================================================

DROP TABLE IF EXISTS raw.credit_scores;
DROP TABLE IF EXISTS raw.payments;
DROP TABLE IF EXISTS raw.loan_snapshots;
DROP TABLE IF EXISTS raw.loans;
DROP TABLE IF EXISTS raw.customers;


CREATE TABLE raw.customers (
    customer_id VARCHAR(10),
    customer_name VARCHAR(100),
    state CHAR(2),
    annual_income NUMERIC(12,2),
    customer_since DATE,
    source_system VARCHAR(50),
    load_timestamp TIMESTAMP,
    batch_id VARCHAR(50)
);


CREATE TABLE raw.loans (
    loan_id VARCHAR(10),
    customer_id VARCHAR(10),
    loan_product VARCHAR(50),
    original_amount NUMERIC(14,2),
    interest_rate NUMERIC(5,2),
    start_date DATE,
    term_months INTEGER,
    source_system VARCHAR(50),
    load_timestamp TIMESTAMP,
    batch_id VARCHAR(50)
);


CREATE TABLE raw.loan_snapshots (
    snapshot_date DATE,
    loan_id VARCHAR(10),
    outstanding_balance NUMERIC(14,2),
    days_past_due INTEGER,
    source_system VARCHAR(50),
    load_timestamp TIMESTAMP,
    batch_id VARCHAR(50)
);


CREATE TABLE raw.payments (
    payment_id VARCHAR(10),
    loan_id VARCHAR(10),
    payment_date DATE,
    payment_amount NUMERIC(14,2),
    payment_status VARCHAR(20),
    source_system VARCHAR(50),
    load_timestamp TIMESTAMP,
    batch_id VARCHAR(50)
);


CREATE TABLE raw.credit_scores (
    customer_id VARCHAR(10),
    score_date DATE,
    credit_score INTEGER,
    source_system VARCHAR(50),
    load_timestamp TIMESTAMP,
    batch_id VARCHAR(50)
);