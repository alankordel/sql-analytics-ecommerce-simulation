-- =====================================================
-- BUSINESS CASE 1 - EXECUTIVE SALES KPIs
-- Questions: How much did the business sell and earn?
-- =====================================================

USE ecommerce_analytics;

-- Overall commercial performance
SELECT
    COUNT(DISTINCT ID_Pedido) AS Total_Pedidos,
    SUM(Qtd_Vendida) AS Itens_Vendidos,
    ROUND(SUM(Receita_Venda), 2) AS Receita_Total,
    ROUND(SUM(Custo_Venda), 2) AS Custo_Total,
    ROUND(SUM(Receita_Venda - Custo_Venda), 2) AS Lucro_Bruto,
    ROUND(
        100 * SUM(Receita_Venda - Custo_Venda) /
        NULLIF(SUM(Receita_Venda), 0),
        2
    ) AS Margem_Bruta_Percentual,
    ROUND(AVG(Receita_Venda), 2) AS Ticket_Medio
FROM pedidos;

-- Monthly evolution and month-over-month growth
WITH vendas_mensais AS (
    SELECT
        DATE_FORMAT(Data_Venda, '%Y-%m-01') AS Mes,
        SUM(Receita_Venda) AS Receita
    FROM pedidos
    GROUP BY DATE_FORMAT(Data_Venda, '%Y-%m-01')
),
comparacao AS (
    SELECT
        Mes,
        Receita,
        LAG(Receita) OVER (ORDER BY Mes) AS Receita_Mes_Anterior
    FROM vendas_mensais
)
SELECT
    Mes,
    ROUND(Receita, 2) AS Receita,
    ROUND(
        100 * (Receita - Receita_Mes_Anterior) /
        NULLIF(Receita_Mes_Anterior, 0),
        2
    ) AS Crescimento_Mensal_Percentual
FROM comparacao
ORDER BY Mes;
