-- =====================================================
-- Credit Risk Modernization Project
-- Source-to-Target Reconciliation
-- =====================================================


-- -----------------------------------------------------
-- 1. Row-count comparison
-- -----------------------------------------------------

SELECT
    'loan_snapshot_row_count' AS validation_name,

    (
        SELECT COUNT(*)
        FROM public.vw_credit_risk_source
    ) AS source_value,

    (
        SELECT COUNT(*)
        FROM mart.fact_loan_snapshot
    ) AS target_value,

    (
        SELECT COUNT(*)
        FROM public.vw_credit_risk_source
    )
    -
    (
        SELECT COUNT(*)
        FROM mart.fact_loan_snapshot
    ) AS difference;


-- -----------------------------------------------------
-- 2. Outstanding-balance comparison
-- -----------------------------------------------------

SELECT
    'total_outstanding_balance' AS validation_name,

    (
        SELECT SUM(outstanding_balance)
        FROM public.vw_credit_risk_source
    ) AS source_value,

    (
        SELECT SUM(outstanding_balance)
        FROM mart.fact_loan_snapshot
    ) AS target_value,

    (
        SELECT SUM(outstanding_balance)
        FROM public.vw_credit_risk_source
    )
    -
    (
        SELECT SUM(outstanding_balance)
        FROM mart.fact_loan_snapshot
    ) AS difference;


-- -----------------------------------------------------
-- 3. Default-count comparison
-- -----------------------------------------------------

SELECT
    'default_loan_count' AS validation_name,

    (
        SELECT COUNT(*)
        FROM public.vw_credit_risk_source
        WHERE default_flag = 1
    ) AS source_value,

    (
        SELECT COUNT(*)
        FROM mart.fact_loan_snapshot
        WHERE default_flag = 1
    ) AS target_value,

    (
        SELECT COUNT(*)
        FROM public.vw_credit_risk_source
        WHERE default_flag = 1
    )
    -
    (
        SELECT COUNT(*)
        FROM mart.fact_loan_snapshot
        WHERE default_flag = 1
    ) AS difference;


-- -----------------------------------------------------
-- 4. Credit-score comparison
-- -----------------------------------------------------

SELECT
    'average_credit_score' AS validation_name,

    (
        SELECT ROUND(AVG(credit_score), 2)
        FROM public.vw_credit_risk_source
    ) AS source_value,

    (
        SELECT ROUND(AVG(credit_score), 2)
        FROM mart.fact_loan_snapshot
    ) AS target_value,

    (
        SELECT ROUND(AVG(credit_score), 2)
        FROM public.vw_credit_risk_source
    )
    -
    (
        SELECT ROUND(AVG(credit_score), 2)
        FROM mart.fact_loan_snapshot
    ) AS difference;