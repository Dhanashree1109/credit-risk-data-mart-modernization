-- =====================================================
-- Credit Risk Modernization Project
-- Credit Risk Data Mart
-- PostgreSQL simulation of Snowflake mart layer
-- =====================================================


-- -----------------------------------------------------
-- Drop fact table first because it depends on dimensions
-- -----------------------------------------------------

DROP TABLE IF EXISTS mart.fact_loan_snapshot;
DROP TABLE IF EXISTS mart.dim_risk_category;
DROP TABLE IF EXISTS mart.dim_date;
DROP TABLE IF EXISTS mart.dim_loan;
DROP TABLE IF EXISTS mart.dim_customer;


-- =====================================================
-- 1. Customer Dimension
-- Grain: One row per customer
-- =====================================================

CREATE TABLE mart.dim_customer (
    customer_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id VARCHAR(10) NOT NULL UNIQUE,
    customer_name VARCHAR(100),
    state CHAR(2),
    annual_income NUMERIC(12,2),
    customer_since DATE
);


-- =====================================================
-- 2. Loan Dimension
-- Grain: One row per loan
-- =====================================================

CREATE TABLE mart.dim_loan (
    loan_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    loan_id VARCHAR(10) NOT NULL UNIQUE,
    customer_id VARCHAR(10),
    loan_product VARCHAR(50),
    original_amount NUMERIC(14,2),
    interest_rate NUMERIC(5,2),
    start_date DATE,
    term_months INTEGER
);


-- =====================================================
-- 3. Date Dimension
-- Grain: One row per calendar date
-- =====================================================

CREATE TABLE mart.dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    day_number INTEGER,
    month_number INTEGER,
    month_name VARCHAR(20),
    quarter_number INTEGER,
    year_number INTEGER
);


-- =====================================================
-- 4. Risk Category Dimension
-- Grain: One row per risk category
-- =====================================================

CREATE TABLE mart.dim_risk_category (
    risk_key INTEGER PRIMARY KEY,
    risk_category VARCHAR(30) NOT NULL UNIQUE,
    risk_rank INTEGER,
    risk_description VARCHAR(200)
);


-- =====================================================
-- 5. Loan Snapshot Fact
-- Grain: One row per loan per snapshot date
-- =====================================================

CREATE TABLE mart.fact_loan_snapshot (
    loan_snapshot_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    date_key INTEGER NOT NULL,
    customer_key INTEGER NOT NULL,
    loan_key INTEGER NOT NULL,
    risk_key INTEGER NOT NULL,

    outstanding_balance NUMERIC(14,2),
    days_past_due INTEGER,
    credit_score INTEGER,
    default_flag INTEGER,

    source_system VARCHAR(50),
    load_timestamp TIMESTAMP,
    batch_id VARCHAR(50),

    CONSTRAINT fk_fact_date
        FOREIGN KEY (date_key)
        REFERENCES mart.dim_date(date_key),

    CONSTRAINT fk_fact_customer
        FOREIGN KEY (customer_key)
        REFERENCES mart.dim_customer(customer_key),

    CONSTRAINT fk_fact_loan
        FOREIGN KEY (loan_key)
        REFERENCES mart.dim_loan(loan_key),

    CONSTRAINT fk_fact_risk
        FOREIGN KEY (risk_key)
        REFERENCES mart.dim_risk_category(risk_key),

    CONSTRAINT uq_fact_loan_snapshot
        UNIQUE (date_key, loan_key)
);