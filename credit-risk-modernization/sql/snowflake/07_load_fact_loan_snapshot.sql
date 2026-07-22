-- =====================================================
-- Load Loan Snapshot Fact Table
-- =====================================================

INSERT INTO mart.fact_loan_snapshot (
    date_key,
    customer_key,
    loan_key,
    risk_key,
    outstanding_balance,
    days_past_due,
    credit_score,
    default_flag,
    source_system,
    load_timestamp,
    batch_id
)
SELECT
    d.date_key,
    c.customer_key,
    l.loan_key,
    r.risk_key,

    s.outstanding_balance,
    s.days_past_due,
    s.credit_score,
    s.default_flag,

    s.source_system,
    s.load_timestamp,
    s.batch_id

FROM staging.credit_risk_clean s

INNER JOIN mart.dim_customer c
    ON s.customer_id = c.customer_id

INNER JOIN mart.dim_loan l
    ON s.loan_id = l.loan_id

INNER JOIN mart.dim_date d
    ON s.snapshot_date = d.full_date

INNER JOIN mart.dim_risk_category r
    ON s.risk_category = r.risk_category;