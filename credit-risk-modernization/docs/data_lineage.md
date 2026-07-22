# Credit Risk Data Lineage

## Objective

This document describes how customer, loan, payment, credit-score,
and loan-snapshot data moves from the legacy source system into the
Credit Risk Data Mart.

---

## End-to-End Lineage

Legacy PostgreSQL Source
        ↓
Raw Target Layer
        ↓
Staging Credit Risk Dataset
        ↓
Credit Risk Data Mart
        ↓
Power BI Semantic Model
        ↓
Credit Risk Dashboard

---

## Customer Data Lineage

Source:
public.customers

Raw target:
raw.customers

Staging:
staging.credit_risk_clean

Data mart:
mart.dim_customer

Power BI usage:
Customer, state, income, and customer-tenure analysis

Important fields:

public.customers.customer_id
    → raw.customers.customer_id
    → staging.credit_risk_clean.customer_id
    → mart.dim_customer.customer_id

public.customers.customer_name
    → raw.customers.customer_name
    → staging.credit_risk_clean.customer_name
    → mart.dim_customer.customer_name

public.customers.state
    → raw.customers.state
    → staging.credit_risk_clean.state
    → mart.dim_customer.state

Transformation:
State values are trimmed and converted to uppercase in the staging layer.

---

## Loan Data Lineage

Source:
public.loans

Raw target:
raw.loans

Staging:
staging.credit_risk_clean

Data mart:
mart.dim_loan

Power BI usage:
Loan-product, original amount, interest-rate, and term analysis

Important fields:

public.loans.loan_id
    → raw.loans.loan_id
    → staging.credit_risk_clean.loan_id
    → mart.dim_loan.loan_id

public.loans.loan_product
    → raw.loans.loan_product
    → staging.credit_risk_clean.loan_product
    → mart.dim_loan.loan_product

Transformation:
Loan-product values are trimmed in the staging layer.

---

## Loan Snapshot Lineage

Source:
public.loan_snapshots

Raw target:
raw.loan_snapshots

Staging:
staging.credit_risk_clean

Data mart:
mart.fact_loan_snapshot

Power BI usage:
Outstanding exposure, delinquency, default, and credit-risk analysis

Important fields:

public.loan_snapshots.snapshot_date
    → raw.loan_snapshots.snapshot_date
    → staging.credit_risk_clean.snapshot_date
    → mart.dim_date.full_date
    → mart.fact_loan_snapshot.date_key

public.loan_snapshots.outstanding_balance
    → raw.loan_snapshots.outstanding_balance
    → staging.credit_risk_clean.outstanding_balance
    → mart.fact_loan_snapshot.outstanding_balance

public.loan_snapshots.days_past_due
    → raw.loan_snapshots.days_past_due
    → staging.credit_risk_clean.days_past_due
    → mart.fact_loan_snapshot.days_past_due

---

## Credit Score Lineage

Source:
public.credit_scores

Raw target:
raw.credit_scores

Staging:
staging.credit_risk_clean

Data mart:
mart.fact_loan_snapshot

Power BI usage:
Average credit score and credit-risk segmentation

Important field:

public.credit_scores.credit_score
    → raw.credit_scores.credit_score
    → staging.credit_risk_clean.credit_score
    → mart.fact_loan_snapshot.credit_score

Join condition:

customer_id and score_date are matched to customer_id and snapshot_date.

---

## Derived Risk Category

Source fields:

raw.loan_snapshots.days_past_due

Transformation:

0 days:
Current

1–29 days:
Early Delinquency

30–59 days:
Delinquent

60–89 days:
High Risk

90 or more days:
Default

Target:

staging.credit_risk_clean.risk_category
    → mart.dim_risk_category.risk_category
    → mart.fact_loan_snapshot.risk_key

---

## Derived Default Flag

Source field:

raw.loan_snapshots.days_past_due

Transformation:

days_past_due >= 90:
default_flag = 1

days_past_due < 90:
default_flag = 0

Target:

staging.credit_risk_clean.default_flag
    → mart.fact_loan_snapshot.default_flag

---

## Technical Metadata Lineage

source_system
    → identifies the source platform

load_timestamp
    → identifies when the record entered the target

batch_id
    → identifies the ingestion run

These fields move from the raw layer through staging into the fact table.