# Credit Risk Pipeline Runbook

## Pipeline Name

Credit Risk Data Mart Modernization Pipeline

## Purpose

The pipeline moves customer, loan, loan-snapshot, payment, and
credit-score data from the legacy source into the Credit Risk Data Mart.

---

## Execution Order

1. Validate source files and source tables
2. Load source data into the raw schema
3. Build the staging credit-risk dataset
4. Load data-mart dimensions
5. Load the loan-snapshot fact table
6. Execute reconciliation checks
7. Refresh the Power BI semantic model
8. Confirm successful dashboard refresh

---

## Expected Row Counts

customers:
100

loans:
100

loan_snapshots:
100

payments:
100

credit_scores:
100

fact_loan_snapshot:
100

---

## Success Criteria

The pipeline is successful when:

- All expected source records are loaded
- The staging table contains 100 records
- The fact table contains 100 records
- No duplicate loan snapshots exist
- No critical fields are null
- Source and target balances match
- Source and target risk categories match
- Row-level mismatch query returns zero records

---

## Common Failure Scenarios

### Foreign-key failure

Cause:
A loan refers to a customer that does not exist.

Resolution:
Load customers before loans and validate customer IDs.

### Duplicate fact record

Cause:
The same loan and snapshot date were loaded more than once.

Resolution:
Check the batch ID and rerun after clearing the incorrect batch.

### Row-count mismatch

Cause:
Records were lost during extraction, joining, or filtering.

Resolution:
Compare counts across public, raw, staging, and mart layers.

### Balance mismatch

Cause:
A join created duplicates or a transformation changed the amount.

Resolution:
Run the row-level mismatch query and trace the affected loan ID.

### Missing credit score

Cause:
No credit-score record exists for the customer and snapshot date.

Resolution:
Confirm whether the missing score is valid or requires a source correction.

---

## Recovery Procedure

1. Identify the failed batch ID
2. Stop downstream processing
3. Review the raw-layer records
4. Correct the source or transformation issue
5. Truncate or delete affected target records
6. Rerun the failed stage
7. Execute reconciliation
8. Resume downstream reporting

---

## Support Information

Primary technical owner:
Data Engineering Team

Business owner:
Credit Risk Analytics Team

Consumers:
Risk Analysts
BI Developers
Finance Teams
Leadership