-- =====================================================
-- SELECT BASICS
-- Fundamental SQL queries
-- =====================================================

SELECT * FROM clientes;
-- visualização tabela clientes
SELECT * FROM pedidos;
-- visualização de apenas algumas colunas
SELECT
	ID_Cliente AS 'ID Cliente',
    Nome AS 'Nome', 
    Sobrenome AS 'Sobrenome', 
    Data_Nascimento AS 'Data de Nascimento',
    Email AS 'E-mail do cliente'
FROM clientes;

-- Seleção das 5 primeiras linhas da tabela de produtos usando LIMIT
SELECT * FROM produtos
LIMIT 5;

-- Seleção de todas as linhas da tabela produto com orndenação pela coluna Preco_Unit usando ORDER BY
SELECT * FROM produtos
ORDER BY Preco_Unit;

-- Selecionado Nome, Sobrenome, Data_Nascimento, Sexo com apenas pessoas do sexo Feminino usando WHERE, da tabela cliente

SELECT Nome, Sobrenome, Data_Nascimento, Sexo FROM clientes
WHERE Sexo = 'F';

-- Selcionando apenas produtos acima de 2000, usando WHERE
SELECT *FROM produtos
WHERE Preco_Unit>2000;
