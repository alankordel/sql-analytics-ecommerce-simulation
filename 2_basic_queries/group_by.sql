-- =====================================================
-- GROUP BY & AGGREGATIONS
-- Aggregation functions practice
-- =====================================================

-- Calculando total da receita de venda da tabela pedidos usando SUM
SELECT SUM(Receita_Venda) AS 'Total de Receita' FROM pedidos;

-- Fazendo a contagem quantidade de cliente do sexo masculino na tabela clientes usando COUNT

SELECT count(Nome) AS 'Qtde de clientes M' 
FROM clientes
WHERE Sexo = 'M';

-- Media de salario dos clientes na tabela clientes
SELECT AVG(Renda_Anual) AS ' Media renda anual'
FROM clientes;

-- Menor preço dos produtos
SELECT MIN(Preco_Unit) AS 'Preço minimo' 
from pedidos;
-- Maior preço dos produtos
SELECT MAX(Preco_Unit) AS 'Preço minimo' 
from pedidos;

-- GROUP BY Agrupando por quantidade de produto por marca
SELECT Marca_Produto, count(Marca_Produto) AS 'Qtde. Produtos'
FROM produtos
GROUP BY Marca_Produto;

-- GROUP BY De cliente Agrupando por grau de escolaridade
SELECT Escolaridade, COUNT(Escolaridade) AS 'Quantidade'
FROM clientes
GROUP BY Escolaridade;
