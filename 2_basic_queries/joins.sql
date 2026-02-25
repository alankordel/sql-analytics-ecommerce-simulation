-- =====================================================
-- JOIN PRACTICE
-- Working with table relationships
-- =====================================================

SELECT *FROM pedidos;
SELECT *FROM lojas;

-- Total de receita (total pedidos) por ID da LOJA
SELECT 
    l.Loja,
    SUM(p.Receita_Venda) AS 'Receita Total'
FROM pedidos p
INNER JOIN lojas l 
    ON p.ID_Loja = l.ID_Loja
GROUP BY l.Loja;

-- Receita e quantidade por produto
SELECT 
    pr.Nome_Produto,
    SUM(p.Qtd_Vendida) AS Total_Quantidade,
    SUM(p.Receita_Venda) AS Receita_Total
FROM pedidos p
INNER JOIN produtos pr 
    ON p.ID_Produto = pr.ID_Produto
GROUP BY pr.Nome_Produto;

-- Receita e pedidos por cliente
SELECT 
    c.Nome,
    COUNT(p.ID_Pedido) AS Total_Pedidos,
    SUM(p.Receita_Venda) AS Receita_Total
FROM pedidos p
INNER JOIN clientes c 
    ON p.ID_Cliente = c.ID_Cliente
GROUP BY c.Nome;



