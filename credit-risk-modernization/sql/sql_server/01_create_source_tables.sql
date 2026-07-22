-- =====================================================
-- Credit Risk Modernization Project
-- PostgreSQL Source Tables
-- =====================================================

DROP TABLE IF EXISTS credit_scores;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS loan_snapshots;
DROP TABLE IF EXISTS loans;
DROP TABLE IF EXISTS customers;

-- 1. Customer table
-- Grain: One row per customer

CREATE TABLE customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    state CHAR(2),
    annual_income NUMERIC(12,2),
    customer_since DATE
);

-- 2. Loan table
-- Grain: One row per loan

CREATE TABLE loans (
    loan_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10) NOT NULL,
    loan_product VARCHAR(50),
    original_amount NUMERIC(14,2),
    interest_rate NUMERIC(5,2),
    start_date DATE,
    term_months INTEGER,

    CONSTRAINT fk_loans_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

-- 3. Loan snapshot table
-- Grain: One row per loan per snapshot date

CREATE TABLE loan_snapshots (
    snapshot_date DATE NOT NULL,
    loan_id VARCHAR(10) NOT NULL,
    outstanding_balance NUMERIC(14,2),
    days_past_due INTEGER,

    CONSTRAINT pk_loan_snapshots
        PRIMARY KEY (snapshot_date, loan_id),

    CONSTRAINT fk_snapshot_loan
        FOREIGN KEY (loan_id)
        REFERENCES loans(loan_id)
);

-- 4. Payment table
-- Grain: One row per payment transaction

CREATE TABLE payments (
    payment_id VARCHAR(10) PRIMARY KEY,
    loan_id VARCHAR(10) NOT NULL,
    payment_date DATE,
    payment_amount NUMERIC(14,2),
    payment_status VARCHAR(20),

    CONSTRAINT fk_payment_loan
        FOREIGN KEY (loan_id)
        REFERENCES loans(loan_id)
);

-- 5. Credit score table
-- Grain: One row per customer per score date

CREATE TABLE credit_scores (
    customer_id VARCHAR(10) NOT NULL,
    score_date DATE NOT NULL,
    credit_score INTEGER,

    CONSTRAINT pk_credit_scores
        PRIMARY KEY (customer_id, score_date),

    CONSTRAINT fk_credit_score_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);