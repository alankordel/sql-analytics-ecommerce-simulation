-- =====================================================
-- RELATIONAL MODEL
-- Adds appropriate types, keys, constraints and indexes
-- after the original sample data has been imported.
-- =====================================================

USE ecommerce_analytics;

-- Dates must be stored as dates, not text.
ALTER TABLE clientes
    MODIFY Data_Nascimento DATE NOT NULL,
    MODIFY ID_Cliente INT NOT NULL,
    MODIFY Nome VARCHAR(100) NOT NULL,
    MODIFY Sobrenome VARCHAR(100) NOT NULL,
    MODIFY Estado_Civil CHAR(1) NOT NULL,
    MODIFY Sexo CHAR(1) NOT NULL,
    MODIFY Email VARCHAR(255) NOT NULL,
    MODIFY Telefone VARCHAR(30) NULL,
    MODIFY Renda_Anual DECIMAL(12,2) NOT NULL,
    MODIFY Qtd_Filhos SMALLINT UNSIGNED NOT NULL,
    MODIFY Escolaridade VARCHAR(50) NOT NULL,
    ADD CONSTRAINT pk_clientes PRIMARY KEY (ID_Cliente),
    ADD CONSTRAINT uq_clientes_email UNIQUE (Email),
    ADD CONSTRAINT chk_clientes_estado_civil CHECK (Estado_Civil IN ('C', 'S')),
    ADD CONSTRAINT chk_clientes_sexo CHECK (Sexo IN ('F', 'M')),
    ADD CONSTRAINT chk_clientes_renda CHECK (Renda_Anual >= 0);

ALTER TABLE categorias
    MODIFY ID_Categoria INT NOT NULL,
    MODIFY Categoria VARCHAR(100) NOT NULL,
    ADD CONSTRAINT pk_categorias PRIMARY KEY (ID_Categoria),
    ADD CONSTRAINT uq_categorias_nome UNIQUE (Categoria);

ALTER TABLE locais
    MODIFY Cidade VARCHAR(100) NOT NULL,
    MODIFY Estado CHAR(2) NOT NULL,
    MODIFY `Região` VARCHAR(30) NOT NULL,
    ADD CONSTRAINT pk_locais PRIMARY KEY (Cidade),
    ADD CONSTRAINT chk_locais_estado CHECK (CHAR_LENGTH(Estado) = 2);

ALTER TABLE lojas
    MODIFY ID_Loja INT NOT NULL,
    MODIFY Loja VARCHAR(100) NOT NULL,
    MODIFY Gerente VARCHAR(150) NOT NULL,
    MODIFY Endereco VARCHAR(255) NOT NULL,
    MODIFY Num_Funcionarios SMALLINT UNSIGNED NOT NULL,
    MODIFY Telefone VARCHAR(30) NULL,
    ADD CONSTRAINT pk_lojas PRIMARY KEY (ID_Loja),
    ADD CONSTRAINT uq_lojas_nome UNIQUE (Loja),
    ADD CONSTRAINT fk_lojas_locais
        FOREIGN KEY (Loja) REFERENCES locais (Cidade),
    ADD CONSTRAINT chk_lojas_funcionarios CHECK (Num_Funcionarios > 0);

ALTER TABLE produtos
    MODIFY ID_Produto INT NOT NULL,
    MODIFY Nome_Produto VARCHAR(200) NOT NULL,
    MODIFY ID_Categoria INT NOT NULL,
    MODIFY Marca_Produto VARCHAR(100) NOT NULL,
    MODIFY Num_Serie VARCHAR(50) NOT NULL,
    MODIFY Preco_Unit DECIMAL(12,2) NOT NULL,
    MODIFY Custo_Unit DECIMAL(12,2) NOT NULL,
    ADD CONSTRAINT pk_produtos PRIMARY KEY (ID_Produto),
    ADD CONSTRAINT uq_produtos_num_serie UNIQUE (Num_Serie),
    ADD CONSTRAINT fk_produtos_categorias
        FOREIGN KEY (ID_Categoria) REFERENCES categorias (ID_Categoria),
    ADD CONSTRAINT chk_produtos_preco CHECK (Preco_Unit >= 0),
    ADD CONSTRAINT chk_produtos_custo CHECK (Custo_Unit >= 0);

ALTER TABLE pedidos
    MODIFY ID_Pedido INT NOT NULL,
    MODIFY Data_Venda DATE NOT NULL,
    MODIFY ID_Loja INT NOT NULL,
    MODIFY ID_Produto INT NOT NULL,
    MODIFY ID_Cliente INT NOT NULL,
    MODIFY Qtd_Vendida INT UNSIGNED NOT NULL,
    MODIFY Receita_Venda DECIMAL(12,2) NOT NULL,
    MODIFY Custo_Venda DECIMAL(12,2) NOT NULL,
    MODIFY Custo_Unit DECIMAL(12,2) NOT NULL,
    MODIFY Preco_Unit DECIMAL(12,2) NOT NULL,
    ADD CONSTRAINT pk_pedidos PRIMARY KEY (ID_Pedido),
    ADD CONSTRAINT fk_pedidos_lojas
        FOREIGN KEY (ID_Loja) REFERENCES lojas (ID_Loja),
    ADD CONSTRAINT fk_pedidos_produtos
        FOREIGN KEY (ID_Produto) REFERENCES produtos (ID_Produto),
    ADD CONSTRAINT fk_pedidos_clientes
        FOREIGN KEY (ID_Cliente) REFERENCES clientes (ID_Cliente),
    ADD CONSTRAINT chk_pedidos_quantidade CHECK (Qtd_Vendida > 0),
    ADD CONSTRAINT chk_pedidos_receita CHECK (Receita_Venda >= 0),
    ADD CONSTRAINT chk_pedidos_custo CHECK (Custo_Venda >= 0);

CREATE INDEX idx_pedidos_data ON pedidos (Data_Venda);
CREATE INDEX idx_pedidos_loja_data ON pedidos (ID_Loja, Data_Venda);
CREATE INDEX idx_pedidos_produto ON pedidos (ID_Produto);
CREATE INDEX idx_pedidos_cliente ON pedidos (ID_Cliente);
CREATE INDEX idx_produtos_categoria ON produtos (ID_Categoria);
