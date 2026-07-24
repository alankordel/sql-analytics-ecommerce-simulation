-- =====================================================
-- SUBQUERIES
-- Practicing nested queries
-- =====================================================

-- Clientes cujo gasto total ficou acima da média de gasto por cliente
SELECT 
    c.ID_Cliente,
    CONCAT(c.Nome, ' ', c.Sobrenome) AS Cliente,
    SUM(p.Receita_Venda) AS Total_Gasto
FROM pedidos p
INNER JOIN clientes c 
    ON p.ID_Cliente = c.ID_Cliente
GROUP BY c.ID_Cliente, c.Nome, c.Sobrenome
HAVING SUM(p.Receita_Venda) >
    (
        SELECT AVG(Total_Cliente)
        FROM (
            SELECT SUM(Receita_Venda) AS Total_Cliente
            FROM pedidos
            GROUP BY ID_Cliente
        ) gastos_por_cliente
    )
ORDER BY Total_Gasto DESC;

-- Produtos com preço acima da média
SELECT Nome_Produto, Preco_Unit
FROM produtos
WHERE Preco_Unit >
    (
        SELECT AVG(Preco_Unit)
        FROM produtos
    );
