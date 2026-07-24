-- =====================================================
-- COMPLETE PROJECT INSTALLATION - MYSQL 8+
-- Execute from the repository root:
-- mysql -u root -p < install.sql
-- =====================================================

SOURCE 1_schema/01_create_database.sql;

SOURCE database/banco_categorias.sql;
SOURCE database/banco_clientes.sql;
SOURCE database/banco_locais.sql;
SOURCE database/banco_lojas.sql;
SOURCE database/banco_produtos.sql;
SOURCE database/banco_pedidos.sql;

SOURCE 1_schema/02_apply_constraints.sql;
SOURCE 5_data_engineering_simulation/01_star_schema.sql;
SOURCE 5_data_engineering_simulation/02_etl_load.sql;
