# Credit Risk Data Mart Modernization

An end-to-end data engineering and business intelligence project that simulates the modernization of a legacy credit-risk reporting platform.

The project moves customer, loan, payment, credit-score, and daily loan-position data through a layered architecture, builds a dimensional Credit Risk Data Mart, validates the migrated results, and exposes trusted credit-risk KPIs through Power BI.

> This is a local implementation built with PostgreSQL to simulate a SQL Server-to-Snowflake modernization architecture. The repository demonstrates the migration design, transformation logic, dimensional modeling, reconciliation framework, lineage, and BI consumption layer.

---

## Business Problem

A financial institution currently maintains credit-risk reporting processes using legacy relational tables and ETL workflows.

The organization wants to modernize the platform while ensuring that:

- No loan records are lost during migration
- Financial balances remain unchanged
- Credit-risk classifications remain consistent
- Default and delinquency calculations are accurate
- Downstream BI reports continue to produce trusted results
- Data can be traced from the original source to the dashboard

The key principle of the project is:

> The technology may change, but the business numbers must remain accurate.

---

## Modernization Scenario

The project represents the following enterprise modernization path:

| Legacy Environment | Modernized Environment |
|---|---|
| SQL Server source tables | Snowflake-style layered data platform |
| SSIS ETL packages | Azure Data Factory-style orchestration |
| SQL Server reporting tables | Credit Risk Data Mart |
| SSAS analytical model | Power BI semantic model |
| Manual validation | Automated source-to-target reconciliation |

The local implementation uses PostgreSQL schemas to represent the target Snowflake layers.

---

## End-to-End Architecture

```text
Synthetic Banking Data
        ↓
Legacy Source Tables
        ↓
Raw Ingestion Layer
        ↓
Staging and Transformation Layer
        ↓
Credit Risk Data Mart
        ↓
Source-to-Target Reconciliation
        ↓
Power BI Semantic Model
        ↓
Credit Risk Dashboard
```

### Local project mapping

```text
Python-generated CSV files
        ↓
PostgreSQL public schema
        ↓
PostgreSQL raw schema
        ↓
PostgreSQL staging schema
        ↓
PostgreSQL mart schema
        ↓
Power BI
```

### Enterprise equivalent

```text
Banking Source Systems
        ↓
SQL Server / Files / APIs
        ↓
Azure Data Factory
        ↓
Snowflake Raw Layer
        ↓
Snowflake Curated Layer
        ↓
Credit Risk Data Mart
        ↓
Power BI Semantic Model
```

---

## Source Data

Python is used to generate linked credit-risk datasets containing 100 records per source file.

### Customer data

Grain:

> One row per customer.

Contains:

- Customer identifier
- Customer name
- State
- Annual income
- Customer relationship start date

### Loan data

Grain:

> One row per loan.

Contains:

- Loan identifier
- Customer identifier
- Loan product
- Original loan amount
- Interest rate
- Start date
- Loan term

### Loan snapshot data

Grain:

> One row per loan per snapshot date.

Contains:

- Snapshot date
- Loan identifier
- Outstanding balance
- Days past due

### Payment data

Grain:

> One row per payment transaction.

Contains:

- Payment identifier
- Loan identifier
- Payment date
- Payment amount
- Payment status

### Credit-score data

Grain:

> One row per customer per score date.

Contains:

- Customer identifier
- Score date
- Credit score

---

## Layered Data Architecture

### 1. Legacy source layer

The `public` schema represents the legacy relational source environment.

Source objects include:

- `public.customers`
- `public.loans`
- `public.loan_snapshots`
- `public.payments`
- `public.credit_scores`
- `public.vw_credit_risk_source`

The source view joins the operational data and applies the original credit-risk rules used for migration comparison.

---

### 2. Raw layer

The `raw` schema represents the landing layer of the modernized platform.

Raw tables preserve source-aligned data and add ingestion metadata:

- `source_system`
- `load_timestamp`
- `batch_id`

Raw tables include:

- `raw.customers`
- `raw.loans`
- `raw.loan_snapshots`
- `raw.payments`
- `raw.credit_scores`

Primary keys are intentionally not enforced in the raw layer so that all received records, including duplicates or invalid records, can be retained for audit and troubleshooting.

---

### 3. Staging layer

The staging layer combines and prepares source data for the Credit Risk Data Mart.

Main object:

- `staging.credit_risk_clean`

Transformations include:

- Joining customer, loan, snapshot, and credit-score data
- Trimming text values
- Standardizing state codes
- Applying credit-risk classifications
- Creating the default indicator
- Preserving ingestion metadata
- Validating the expected fact-table grain

---

### 4. Credit Risk Data Mart

The `mart` schema contains the final BI-ready star schema.

#### Dimension tables

- `mart.dim_customer`
- `mart.dim_loan`
- `mart.dim_date`
- `mart.dim_risk_category`

#### Fact table

- `mart.fact_loan_snapshot`

Fact-table grain:

> One row per loan per snapshot date.

The fact table stores:

- Outstanding balance
- Days past due
- Credit score
- Default flag
- Date key
- Customer key
- Loan key
- Risk-category key
- Source-system metadata
- Batch identifier
- Load timestamp

---

## Star Schema

```text
                    dim_date
                       |
                       |
dim_customer — fact_loan_snapshot — dim_loan
                       |
                       |
              dim_risk_category
```

Surrogate keys are used in the dimensions to support stable warehouse relationships and separate the analytical model from source-system identifiers.

---

## Credit-Risk Business Rules

Loans are classified using `days_past_due`.

| Days Past Due | Risk Category |
|---:|---|
| 0 | Current |
| 1–29 | Early Delinquency |
| 30–59 | Delinquent |
| 60–89 | High Risk |
| 90 or more | Default |

Default logic:

```sql
CASE
    WHEN days_past_due >= 90 THEN 1
    ELSE 0
END
```

These rules are simplified for project purposes. In a production banking environment, the classifications would be approved and governed by credit-risk subject-matter experts.

---

## Migration Validation and Reconciliation

The project validates the migration at both aggregate and individual-record levels.

### Aggregate checks

- Source and target row counts
- Total outstanding balance
- Number of defaulted loans
- Average credit score
- Loan count by risk category
- Outstanding balance by risk category

### Data-quality checks

- Missing customer identifiers
- Missing loan identifiers
- Missing snapshot dates
- Missing outstanding balances
- Duplicate loan snapshots
- Invalid risk categories
- Incorrect default flags

### Row-level reconciliation

Source and target records are compared using:

```text
snapshot_date + loan_id
```

The comparison checks:

- Outstanding balance
- Days past due
- Credit score
- Risk category
- Default flag

Successful migration criteria:

```text
Source value = Target value
Difference = 0
Row-level mismatches = 0
```

---

## Data Lineage

The repository documents how important credit-risk fields move through the platform.

Example:

```text
public.loan_snapshots.days_past_due
        ↓
raw.loan_snapshots.days_past_due
        ↓
staging.credit_risk_clean.days_past_due
        ↓
staging.credit_risk_clean.risk_category
        ↓
mart.dim_risk_category
        ↓
mart.fact_loan_snapshot.risk_key
        ↓
Power BI Credit Risk Dashboard
```

The lineage documentation supports:

- Data tracing
- Impact analysis
- Troubleshooting
- Auditability
- Source-to-report transparency

---

## Power BI Semantic Model

Power BI connects only to the trusted `mart` schema.

Relationships:

```text
dim_customer[customer_key]
        1 → *
fact_loan_snapshot[customer_key]
```

```text
dim_loan[loan_key]
        1 → *
fact_loan_snapshot[loan_key]
```

```text
dim_date[date_key]
        1 → *
fact_loan_snapshot[date_key]
```

```text
dim_risk_category[risk_key]
        1 → *
fact_loan_snapshot[risk_key]
```

The model uses one-to-many relationships with single-direction filtering.

---

## Power BI Measures

The dashboard includes the following DAX measures:

- Total Outstanding Balance
- Total Loans
- Average Credit Score
- Defaulted Loans
- Default Rate
- Delinquent Loans
- Delinquency Rate

Example:

```DAX
Default Rate =
DIVIDE(
    [Defaulted Loans],
    [Total Loans],
    0
)
```

---

## Dashboard Output

The Credit Risk Overview dashboard displays:

- Total Outstanding Balance
- Total Loans
- Average Credit Score
- Default Rate
- Delinquency Rate
- Outstanding Balance by Risk Category

The Power BI values were validated against SQL results from the final mart tables.

---

## Pipeline Execution Order

```text
1. Generate synthetic source data
2. Create legacy source tables
3. Load source CSV files
4. Build the legacy credit-risk source view
5. Create raw, staging, and mart schemas
6. Load source data into raw tables
7. Build the staging credit-risk dataset
8. Load dimension tables
9. Load the loan-snapshot fact table
10. Run source-to-target reconciliation
11. Validate Power BI results
```

---

## Repository Structure

```text
credit-risk-modernization
│
├── data
│   ├── raw
│   └── processed
│
├── python
│   └── generate_data.py
│
├── sql
│   ├── sql_server
│   │   ├── 01_create_source_tables.sql
│   │   └── 02_create_credit_risk_view.sql
│   │
│   ├── snowflake
│   │   ├── 01_create_target_schemas.sql
│   │   ├── 02_create_raw_tables.sql
│   │   ├── 03_load_raw_tables.sql
│   │   ├── 04_create_staging_credit_risk.sql
│   │   ├── 05_create_credit_risk_mart.sql
│   │   ├── 06_load_dimensions.sql
│   │   └── 07_load_fact_loan_snapshot.sql
│   │
│   └── validation
│       └── 01_source_target_reconciliation.sql
│
├── docs
│   ├── data_lineage.md
│   └── runbook.md
│
├── tests
│   └── test_cases.md
│
└── powerbi
    └── credit_risk_modernization_dashboard.pbix
```

---

## Technologies Used

- Python
- PostgreSQL
- SQL
- Power BI
- DAX
- Dimensional modeling
- GitHub

---

## Project Outcomes

This project demonstrates the ability to:

- Translate a financial-services requirement into a data solution
- Design a layered data architecture
- Build source, raw, staging, and mart data structures
- Apply credit-risk transformation rules
- Design fact and dimension tables
- Preserve table grain across transformations
- Build automated migration validation
- Perform aggregate and row-level reconciliation
- Document data lineage and operational procedures
- Build a Power BI semantic model
- Validate dashboard metrics against database results

---

## Future Enhancements

Potential improvements include:

- Deploying the target model in Snowflake
- Rebuilding the orchestration in Azure Data Factory
- Adding incremental loads and watermark processing
- Implementing Slowly Changing Dimension Type 2
- Adding audit and reject tables
- Creating Azure DevOps CI/CD pipelines
- Adding multiple snapshot dates for trend analysis
- Implementing Power BI row-level security
- Adding Apache Iceberg-based storage examples
