-- =====================================================
-- Credit Risk Modernization Project
-- Staging Credit Risk Dataset
-- PostgreSQL simulation of Snowflake staging layer
-- =====================================================

DROP TABLE IF EXISTS staging.credit_risk_clean;

CREATE TABLE staging.credit_risk_clean AS

SELECT
    ls.snapshot_date,

    c.customer_id,
    TRIM(c.customer_name) AS customer_name,
    UPPER(TRIM(c.state)) AS state,
    c.annual_income,
    c.customer_since,

    l.loan_id,
    TRIM(l.loan_product) AS loan_product,
    l.original_amount,
    l.interest_rate,
    l.start_date,
    l.term_months,

    ls.outstanding_balance,
    ls.days_past_due,

    cs.credit_score,

    CASE
        WHEN ls.days_past_due = 0
            THEN 'Current'

        WHEN ls.days_past_due BETWEEN 1 AND 29
            THEN 'Early Delinquency'

        WHEN ls.days_past_due BETWEEN 30 AND 59
            THEN 'Delinquent'

        WHEN ls.days_past_due BETWEEN 60 AND 89
            THEN 'High Risk'

        WHEN ls.days_past_due >= 90
            THEN 'Default'

        ELSE 'Unknown'
    END AS risk_category,

    CASE
        WHEN ls.days_past_due >= 90
            THEN 1
        ELSE 0
    END AS default_flag,

    ls.source_system,
    ls.load_timestamp,
    ls.batch_id

FROM raw.customers c

INNER JOIN raw.loans l
    ON c.customer_id = l.customer_id

INNER JOIN raw.loan_snapshots ls
    ON l.loan_id = ls.loan_id

LEFT JOIN raw.credit_scores cs
    ON c.customer_id = cs.customer_id
    AND cs.score_date = ls.snapshot_date;