-- =====================================================
-- BUSINESS CASE 3 - PRODUCT AND CATEGORY ANALYSIS
-- Question: Which products generate revenue and margin?
-- =====================================================

USE ecommerce_analytics;

SELECT
    c.Categoria,
    pr.ID_Produto,
    pr.Nome_Produto,
    pr.Marca_Produto,
    SUM(p.Qtd_Vendida) AS Quantidade_Vendida,
    ROUND(SUM(p.Receita_Venda), 2) AS Receita,
    ROUND(SUM(p.Receita_Venda - p.Custo_Venda), 2) AS Lucro,
    ROUND(
        100 * SUM(p.Receita_Venda - p.Custo_Venda) /
        NULLIF(SUM(p.Receita_Venda), 0),
        2
    ) AS Margem_Percentual,
    DENSE_RANK() OVER (
        PARTITION BY c.Categoria
        ORDER BY SUM(p.Receita_Venda) DESC
    ) AS Ranking_na_Categoria
FROM pedidos p
INNER JOIN produtos pr
    ON p.ID_Produto = pr.ID_Produto
INNER JOIN categorias c
    ON pr.ID_Categoria = c.ID_Categoria
GROUP BY
    c.Categoria, pr.ID_Produto, pr.Nome_Produto, pr.Marca_Produto
ORDER BY c.Categoria, Ranking_na_Categoria;

-- Categories without sales are also shown
SELECT
    c.ID_Categoria,
    c.Categoria,
    COUNT(DISTINCT p.ID_Pedido) AS Total_Pedidos,
    COALESCE(SUM(p.Receita_Venda), 0) AS Receita
FROM categorias c
LEFT JOIN produtos pr
    ON c.ID_Categoria = pr.ID_Categoria
LEFT JOIN pedidos p
    ON pr.ID_Produto = p.ID_Produto
GROUP BY c.ID_Categoria, c.Categoria
ORDER BY Receita DESC;
