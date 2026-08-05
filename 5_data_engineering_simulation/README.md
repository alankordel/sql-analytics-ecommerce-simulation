# Data Engineering Simulation

This stage transforms the normalized e-commerce model into a star schema.

## Model

- `fato_vendas`: one row per order or transaction, with quantity, revenue,
  cost and profit. `ID_Pedido` is unique in the source data.
- `dim_data`: calendar attributes.
- `dim_cliente`: customer profile and transformed income range.
- `dim_produto`: product, brand and category attributes.
- `dim_loja`: store, location and region attributes.
- `etl_execucoes`: ETL execution audit.

`02_etl_load.sql` creates an idempotent stored procedure: dimensions are
updated through their natural keys and the fact table is fully reloaded inside
a transaction. Failures are rolled back and recorded in the audit table. The
current implementation does not perform incremental loads.

The schema and initial load are executed automatically by `install.sql`.
