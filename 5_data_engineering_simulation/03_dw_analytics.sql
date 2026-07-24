-- =====================================================
-- ANALYTICS OVER THE STAR SCHEMA
-- =====================================================

USE ecommerce_analytics;

-- Revenue and profit by month and region
SELECT
    d.Ano,
    d.Mes,
    d.Nome_Mes,
    l.Regiao,
    ROUND(SUM(f.Receita), 2) AS Receita,
    ROUND(SUM(f.Lucro), 2) AS Lucro
FROM fato_vendas f
INNER JOIN dim_data d ON f.Data_Key = d.Data_Key
INNER JOIN dim_loja l ON f.Loja_Key = l.Loja_Key
GROUP BY d.Ano, d.Mes, d.Nome_Mes, l.Regiao
ORDER BY d.Ano, d.Mes, Receita DESC;

-- Customer profile contribution
SELECT
    c.Faixa_Renda,
    c.Escolaridade,
    COUNT(DISTINCT f.Cliente_Key) AS Clientes_Ativos,
    ROUND(SUM(f.Receita), 2) AS Receita,
    ROUND(AVG(f.Receita), 2) AS Ticket_Medio
FROM fato_vendas f
INNER JOIN dim_cliente c ON f.Cliente_Key = c.Cliente_Key
GROUP BY c.Faixa_Renda, c.Escolaridade
ORDER BY Receita DESC;
-- Product participation in total revenue
SELECT
    p.Categoria,
    p.Nome_Produto,
    ROUND(SUM(f.Receita), 2) AS Receita,
    ROUND(
        100 * SUM(f.Receita) / SUM(SUM(f.Receita)) OVER (),
        2
    ) AS Participacao_Receita_Percentual
FROM fato_vendas f
INNER JOIN dim_produto p ON f.Produto_Key = p.Produto_Key
GROUP BY p.Categoria, p.Nome_Produto
ORDER BY Receita DESC;
