# Data Models

## Operational relational model

The source model represents the e-commerce operation. `pedidos` is the central
transaction table and references customer, product and store master data.

```mermaid
erDiagram
    CATEGORIAS ||--o{ PRODUTOS : classifica
    PRODUTOS ||--o{ PEDIDOS : vendido_em
    CLIENTES ||--o{ PEDIDOS : realiza
    LOJAS ||--o{ PEDIDOS : registra
    LOCAIS ||--|| LOJAS : localiza

    CATEGORIAS {
        int ID_Categoria PK
        varchar Categoria UK
    }
    PRODUTOS {
        int ID_Produto PK
        int ID_Categoria FK
        varchar Nome_Produto
        decimal Preco_Unit
        decimal Custo_Unit
    }
    CLIENTES {
        int ID_Cliente PK
        varchar Nome
        date Data_Nascimento
        decimal Renda_Anual
    }
    LOCAIS {
        varchar Cidade PK
        char Estado
        varchar Regiao
    }
    LOJAS {
        int ID_Loja PK
        varchar Loja FK
        varchar Gerente
    }
    PEDIDOS {
        int ID_Pedido PK
        date Data_Venda
        int ID_Loja FK
        int ID_Produto FK
        int ID_Cliente FK
        int Qtd_Vendida
        decimal Receita_Venda
        decimal Custo_Venda
    }
```
## Analytical star schema

The fact grain is one order row. Surrogate dimension keys decouple analytics
from operational identifiers. Profit is calculated as a generated measure.

```mermaid
erDiagram
    DIM_DATA ||--o{ FATO_VENDAS : quando
    DIM_CLIENTE ||--o{ FATO_VENDAS : quem
    DIM_PRODUTO ||--o{ FATO_VENDAS : o_que
    DIM_LOJA ||--o{ FATO_VENDAS : onde

    FATO_VENDAS {
        bigint Venda_Key PK
        int ID_Pedido UK
        int Data_Key FK
        int Cliente_Key FK
        int Produto_Key FK
        int Loja_Key FK
        int Quantidade
        decimal Receita
        decimal Custo
        decimal Lucro
    }
    DIM_DATA {
        int Data_Key PK
        date Data_Completa UK
        int Mes
        int Trimestre
        int Ano
    }
    DIM_CLIENTE {
        int Cliente_Key PK
        int ID_Cliente UK
        varchar Nome_Completo
        varchar Faixa_Renda
    }
    DIM_PRODUTO {
        int Produto_Key PK
        int ID_Produto UK
        varchar Categoria
        varchar Marca
    }
    DIM_LOJA {
        int Loja_Key PK
        int ID_Loja UK
        varchar Estado
        varchar Regiao
    }
```
