-- =====================================================
-- CTE (Common Table Expressions)
-- Organizing complex queries
-- =====================================================

-- Receita total por loja usando CTE
WITH Receita_Loja AS (
    SELECT 
        l.Loja,
        SUM(p.Receita_Venda) AS Receita_Total
    FROM pedidos p
    INNER JOIN lojas l
        ON p.ID_Loja = l.ID_Loja
    GROUP BY l.Loja
)

SELECT *
FROM Receita_Loja
ORDER BY Receita_Total DESC;
