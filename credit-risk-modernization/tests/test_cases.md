# Credit Risk Migration Test Cases

| Test ID | Test Description | Expected Result |
|---|---|---|
| TC001 | Compare source and target row counts | Difference equals zero |
| TC002 | Compare total outstanding balance | Difference equals zero |
| TC003 | Compare default-loan count | Difference equals zero |
| TC004 | Compare average credit score | Difference equals zero |
| TC005 | Check duplicate loan snapshots | Zero duplicate records |
| TC006 | Check missing critical fields | Zero invalid records |
| TC007 | Validate risk-category mapping | All loans correctly classified |
| TC008 | Compare risk-category totals | All category differences equal zero |
| TC009 | Perform row-level comparison | Zero mismatched loans |
| TC010 | Validate fact-table grain | One row per loan per snapshot date |