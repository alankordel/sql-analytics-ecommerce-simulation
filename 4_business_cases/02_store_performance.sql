-- =====================================================
-- BUSINESS CASE 2 - STORE PERFORMANCE
-- Question: Which stores and regions perform best?
-- =====================================================

USE ecommerce_analytics;

SELECT
    l.ID_Loja,
    l.Loja,
    loc.Estado,
    loc.`Região`,
    COUNT(DISTINCT p.ID_Pedido) AS Total_Pedidos,
    SUM(p.Qtd_Vendida) AS Itens_Vendidos,
    ROUND(SUM(p.Receita_Venda), 2) AS Receita,
    ROUND(SUM(p.Receita_Venda - p.Custo_Venda), 2) AS Lucro,
    ROUND(AVG(p.Receita_Venda), 2) AS Ticket_Medio,
    ROUND(SUM(p.Receita_Venda) / l.Num_Funcionarios, 2)
        AS Receita_Por_Funcionario,
    DENSE_RANK() OVER (ORDER BY SUM(p.Receita_Venda) DESC)
        AS Ranking_Receita
FROM pedidos p
INNER JOIN lojas l
    ON p.ID_Loja = l.ID_Loja
INNER JOIN locais loc
    ON l.Loja = loc.Cidade
GROUP BY
    l.ID_Loja, l.Loja, loc.Estado, loc.`Região`, l.Num_Funcionarios
ORDER BY Ranking_Receita;
