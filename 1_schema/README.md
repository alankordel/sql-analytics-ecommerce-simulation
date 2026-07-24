# Database Modeling

This folder converts the original MySQL dumps into a relational analytical
database. The installation creates `ecommerce_analytics`, imports the sample
data and then adds data types, primary keys, foreign keys, validation
constraints and analytical indexes.

Execute the complete setup from the repository root:

```bash
mysql -u root -p < install.sql
```

The original files in `database/` remain unchanged and act as the raw data
source.
