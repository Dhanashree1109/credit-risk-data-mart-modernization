# Credit Risk Data Mart Modernization

This project demonstrates an end-to-end modernization of a legacy credit-risk data pipeline.

## Project Overview

The project simulates the migration of customer, loan, payment, credit-score, and loan-snapshot data from a legacy relational database into a layered modern data platform.

The solution includes:

- Source data generation using Python
- Legacy source tables in PostgreSQL
- Raw ingestion layer
- Staging transformation layer
- Credit Risk Data Mart
- Source-to-target reconciliation
- Data lineage documentation
- Operational runbook
- Power BI semantic model and dashboard

## Project Flow

CSV Source Data  
→ PostgreSQL Source Tables  
→ Raw Layer  
→ Staging Layer  
→ Credit Risk Data Mart  
→ Validation and Reconciliation  
→ Power BI Semantic Model  
→ Credit Risk Dashboard

## Business Use Case

The Credit Risk Data Mart supports analysis of:

- Total outstanding loan balance
- Total number of loans
- Average credit score
- Default rate
- Delinquency rate
- Outstanding balance by risk category

## Technologies Used

- Python
- PostgreSQL
- SQL
- Power BI
- GitHub

## Data Architecture

The target architecture contains three main layers.

### Raw Layer

The raw layer stores source-aligned data along with technical metadata such as:

- Source system
- Load timestamp
- Batch ID

### Staging Layer

The staging layer:

- Joins customer, loan, snapshot, and credit-score data
- Standardizes values
- Applies credit-risk business rules
- Creates default indicators
- Prepares trusted data for the mart

### Mart Layer

The final Credit Risk Data Mart follows a star-schema design.

Dimension tables:

- `dim_customer`
- `dim_loan`
- `dim_date`
- `dim_risk_category`

Fact table:

- `fact_loan_snapshot`

The grain of the fact table is:

> One row per loan per snapshot date.

## Credit Risk Rules

Loans are classified using days past due:

| Days Past Due | Risk Category |
|---:|---|
| 0 | Current |
| 1–29 | Early Delinquency |
| 30–59 | Delinquent |
| 60–89 | High Risk |
| 90 or more | Default |

A loan is marked as defaulted when:

```text
days_past_due >= 90

