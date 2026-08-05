# Expected Results

After running `install.sql`, the following invariants are expected:

| Check | Expected result |
|---|---:|
| Categories | 7 |
| Customers | 100 |
| Locations | 8 |
| Stores | 8 |
| Products | 16 |
| Orders | 374 |
| Fact rows | 374 |
| Orphan orders | 0 |
| Duplicate order identifiers | 0 |
| Source/fact revenue difference | 0.00 |
| Source/fact cost difference | 0.00 |
| Last ETL status | `SUCESSO` |
| Result after two consecutive ETL runs | Unchanged totals and 374 unique orders |

Business-query values should be treated as derived results. They are
intentionally calculated by SQL rather than duplicated as static numbers in
the documentation. This avoids stale documentation when the dataset changes.
