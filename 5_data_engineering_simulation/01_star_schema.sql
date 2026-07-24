-- =====================================================
-- DATA WAREHOUSE SIMULATION - STAR SCHEMA
-- Grain: one row per order line (pedido)
-- =====================================================

USE ecommerce_analytics;

DROP TABLE IF EXISTS fato_vendas;
DROP TABLE IF EXISTS dim_data;
DROP TABLE IF EXISTS dim_cliente;
DROP TABLE IF EXISTS dim_produto;
DROP TABLE IF EXISTS dim_loja;
DROP TABLE IF EXISTS etl_execucoes;

CREATE TABLE dim_data (
    Data_Key INT NOT NULL,
    Data_Completa DATE NOT NULL,
    Dia TINYINT UNSIGNED NOT NULL,
    Mes TINYINT UNSIGNED NOT NULL,
    Nome_Mes VARCHAR(15) NOT NULL,
    Trimestre TINYINT UNSIGNED NOT NULL,
    Ano SMALLINT UNSIGNED NOT NULL,
    Dia_Semana TINYINT UNSIGNED NOT NULL,
    Nome_Dia_Semana VARCHAR(15) NOT NULL,
    Fim_de_Semana BOOLEAN NOT NULL,
    CONSTRAINT pk_dim_data PRIMARY KEY (Data_Key),
    CONSTRAINT uq_dim_data_data UNIQUE (Data_Completa)
);
CREATE TABLE dim_cliente (
    Cliente_Key INT NOT NULL AUTO_INCREMENT,
    ID_Cliente INT NOT NULL,
    Nome_Completo VARCHAR(201) NOT NULL,
    Data_Nascimento DATE NOT NULL,
    Sexo CHAR(1) NOT NULL,
    Escolaridade VARCHAR(50) NOT NULL,
    Faixa_Renda VARCHAR(30) NOT NULL,
    Qtd_Filhos SMALLINT UNSIGNED NOT NULL,
    CONSTRAINT pk_dim_cliente PRIMARY KEY (Cliente_Key),
    CONSTRAINT uq_dim_cliente_natural UNIQUE (ID_Cliente)
);

CREATE TABLE dim_produto (
    Produto_Key INT NOT NULL AUTO_INCREMENT,
    ID_Produto INT NOT NULL,
    Nome_Produto VARCHAR(200) NOT NULL,
    Categoria VARCHAR(100) NOT NULL,
    Marca VARCHAR(100) NOT NULL,
    Preco_Unitario DECIMAL(12,2) NOT NULL,
    Custo_Unitario DECIMAL(12,2) NOT NULL,
    CONSTRAINT pk_dim_produto PRIMARY KEY (Produto_Key),
    CONSTRAINT uq_dim_produto_natural UNIQUE (ID_Produto)
);

CREATE TABLE dim_loja (
    Loja_Key INT NOT NULL AUTO_INCREMENT,
    ID_Loja INT NOT NULL,
    Loja VARCHAR(100) NOT NULL,
    Gerente VARCHAR(150) NOT NULL,
    Cidade VARCHAR(100) NOT NULL,
    Estado CHAR(2) NOT NULL,
    Regiao VARCHAR(30) NOT NULL,
    Num_Funcionarios SMALLINT UNSIGNED NOT NULL,
    CONSTRAINT pk_dim_loja PRIMARY KEY (Loja_Key),
    CONSTRAINT uq_dim_loja_natural UNIQUE (ID_Loja)
);

CREATE TABLE fato_vendas (
    Venda_Key BIGINT NOT NULL AUTO_INCREMENT,
    ID_Pedido INT NOT NULL,
    Data_Key INT NOT NULL,
    Cliente_Key INT NOT NULL,
    Produto_Key INT NOT NULL,
    Loja_Key INT NOT NULL,
    Quantidade INT UNSIGNED NOT NULL,
    Receita DECIMAL(12,2) NOT NULL,
    Custo DECIMAL(12,2) NOT NULL,
    Lucro DECIMAL(12,2) GENERATED ALWAYS AS (Receita - Custo) STORED,
    CONSTRAINT pk_fato_vendas PRIMARY KEY (Venda_Key),
    CONSTRAINT uq_fato_vendas_pedido UNIQUE (ID_Pedido),
    CONSTRAINT fk_fato_data FOREIGN KEY (Data_Key)
        REFERENCES dim_data (Data_Key),
    CONSTRAINT fk_fato_cliente FOREIGN KEY (Cliente_Key)
        REFERENCES dim_cliente (Cliente_Key),
    CONSTRAINT fk_fato_produto FOREIGN KEY (Produto_Key)
        REFERENCES dim_produto (Produto_Key),
    CONSTRAINT fk_fato_loja FOREIGN KEY (Loja_Key)
        REFERENCES dim_loja (Loja_Key)
);

CREATE INDEX idx_fato_data_loja ON fato_vendas (Data_Key, Loja_Key);
CREATE INDEX idx_fato_produto ON fato_vendas (Produto_Key);
CREATE INDEX idx_fato_cliente ON fato_vendas (Cliente_Key);

CREATE TABLE etl_execucoes (
    Execucao_ID BIGINT NOT NULL AUTO_INCREMENT,
    Inicio DATETIME NOT NULL,
    Fim DATETIME NULL,
    Status VARCHAR(20) NOT NULL,
    Linhas_Carregadas INT NOT NULL DEFAULT 0,
    Mensagem VARCHAR(500) NULL,
    CONSTRAINT pk_etl_execucoes PRIMARY KEY (Execucao_ID)
);
