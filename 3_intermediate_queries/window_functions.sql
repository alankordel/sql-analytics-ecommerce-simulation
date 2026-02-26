-- =====================================================
-- WINDOW FUNCTIONS
-- Advanced analytical calculations
-- =====================================================

-- Ranking de vendas dentro de cada loja
SELECT
    p.ID_Pedido,
    l.Loja,
    p.Receita_Venda,
    RANK() OVER (
        PARTITION BY l.Loja
        ORDER BY p.Receita_Venda DESC
    ) AS Ranking_Venda
FROM pedidos p
INNER JOIN lojas l 
    ON p.ID_Loja = l.ID_Loja;

-- Média móvel considerando as duas vendas anteriores
SELECT
    ID_Pedido,
    Receita_Venda,
    AVG(Receita_Venda) OVER (
        ORDER BY ID_Pedido
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS Media_Movel
FROM pedidos;
