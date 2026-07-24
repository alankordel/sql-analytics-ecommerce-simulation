-- =====================================================
-- BUSINESS CASE 4 - CUSTOMER ANALYSIS
-- Questions: Who are the most valuable customers?
-- =====================================================

USE ecommerce_analytics;

WITH perfil_cliente AS (
    SELECT
        c.ID_Cliente,
        CONCAT(c.Nome, ' ', c.Sobrenome) AS Cliente,
        c.Sexo,
        c.Escolaridade,
        c.Renda_Anual,
        COUNT(DISTINCT p.ID_Pedido) AS Frequencia,
        SUM(p.Receita_Venda) AS Valor_Monetario,
        MAX(p.Data_Venda) AS Ultima_Compra
    FROM clientes c
    LEFT JOIN pedidos p
        ON c.ID_Cliente = p.ID_Cliente
    GROUP BY
        c.ID_Cliente, c.Nome, c.Sobrenome, c.Sexo,
        c.Escolaridade, c.Renda_Anual
),
segmentacao AS (
    SELECT
        *,
        CASE
            WHEN Frequencia = 0 THEN 'Sem compras'
            WHEN Frequencia >= 5 AND Valor_Monetario >= 3000 THEN 'VIP'
            WHEN Frequencia >= 3 THEN 'Recorrente'
            ELSE 'Ocasional'
        END AS Segmento
    FROM perfil_cliente
)
SELECT
    ID_Cliente,
    Cliente,
    Segmento,
    Frequencia,
    ROUND(COALESCE(Valor_Monetario, 0), 2) AS Valor_Monetario,
    Ultima_Compra,
    Sexo,
    Escolaridade,
    Renda_Anual
FROM segmentacao
ORDER BY COALESCE(Valor_Monetario, 0) DESC;

-- Summary by customer segment
WITH totais AS (
    SELECT
        c.ID_Cliente,
        COUNT(p.ID_Pedido) AS Frequencia,
        COALESCE(SUM(p.Receita_Venda), 0) AS Valor_Monetario
    FROM clientes c
    LEFT JOIN pedidos p ON c.ID_Cliente = p.ID_Cliente
    GROUP BY c.ID_Cliente
),
segmentos AS (
    SELECT
        CASE
            WHEN Frequencia = 0 THEN 'Sem compras'
            WHEN Frequencia >= 5 AND Valor_Monetario >= 3000 THEN 'VIP'
            WHEN Frequencia >= 3 THEN 'Recorrente'
            ELSE 'Ocasional'
        END AS Segmento,
        Valor_Monetario
    FROM totais
)
SELECT
    Segmento,
    COUNT(*) AS Clientes,
    ROUND(SUM(Valor_Monetario), 2) AS Receita
FROM segmentos
GROUP BY Segmento
ORDER BY Receita DESC;
