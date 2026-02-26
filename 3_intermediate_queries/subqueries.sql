-- =====================================================
-- SUBQUERIES
-- Practicing nested queries
-- =====================================================

-- Clientes que gastaram acima da média geral
SELECT 
    c.Nome,
    SUM(p.Receita_Venda) AS Total_Gasto
FROM pedidos p
INNER JOIN clientes c 
    ON p.ID_Cliente = c.ID_Cliente
GROUP BY c.Nome
HAVING SUM(p.Receita_Venda) >
    (
        SELECT AVG(Receita_Venda)
        FROM pedidos
    );

-- Produtos com preço acima da média
SELECT Nome_Produto, Preco_Unit
FROM produtos
WHERE Preco_Unit >
    (
        SELECT AVG(Preco_Unit)
        FROM produtos
    );
