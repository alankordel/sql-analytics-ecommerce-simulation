-- =====================================================
-- ETL LOAD
-- Extracts from the normalized operational model,
-- transforms business attributes and loads the star model.
-- The procedure is idempotent: reruns update dimensions
-- and replace facts without duplicating orders.
-- =====================================================

USE ecommerce_analytics;

DROP PROCEDURE IF EXISTS sp_carregar_data_warehouse;

DELIMITER $$

CREATE PROCEDURE sp_carregar_data_warehouse()
BEGIN
    DECLARE v_execucao_id BIGINT;
    DECLARE v_linhas INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        UPDATE etl_execucoes
        SET
            Fim = NOW(),
            Status = 'ERRO',
            Mensagem = 'Carga revertida por erro SQL'
        WHERE Execucao_ID = v_execucao_id;
        RESIGNAL;
    END;

    INSERT INTO etl_execucoes (Inicio, Status)
    VALUES (NOW(), 'EM_EXECUCAO');
    SET v_execucao_id = LAST_INSERT_ID();

    START TRANSACTION;

    INSERT INTO dim_data (
        Data_Key, Data_Completa, Dia, Mes, Nome_Mes,
        Trimestre, Ano, Dia_Semana, Nome_Dia_Semana, Fim_de_Semana
    )
    SELECT DISTINCT
        CAST(DATE_FORMAT(Data_Venda, '%Y%m%d') AS UNSIGNED),
        Data_Venda,
        DAY(Data_Venda),
        MONTH(Data_Venda),
        ELT(
            MONTH(Data_Venda),
            'Janeiro', 'Fevereiro', 'Março', 'Abril',
            'Maio', 'Junho', 'Julho', 'Agosto',
            'Setembro', 'Outubro', 'Novembro', 'Dezembro'
        ),
        QUARTER(Data_Venda),
        YEAR(Data_Venda),
        WEEKDAY(Data_Venda) + 1,
        ELT(
            WEEKDAY(Data_Venda) + 1,
            'Segunda', 'Terça', 'Quarta', 'Quinta',
            'Sexta', 'Sábado', 'Domingo'
        ),
        WEEKDAY(Data_Venda) >= 5
    FROM pedidos
    ON DUPLICATE KEY UPDATE
        Nome_Mes = VALUES(Nome_Mes),
        Nome_Dia_Semana = VALUES(Nome_Dia_Semana);

    INSERT INTO dim_cliente (
        ID_Cliente, Nome_Completo, Data_Nascimento, Sexo,
        Escolaridade, Faixa_Renda, Qtd_Filhos
    )
    SELECT
        ID_Cliente,
        CONCAT(Nome, ' ', Sobrenome),
        Data_Nascimento,
        Sexo,
        Escolaridade,
        CASE
            WHEN Renda_Anual < 40000 THEN 'Até 40 mil'
            WHEN Renda_Anual < 80000 THEN '40 a 80 mil'
            WHEN Renda_Anual < 120000 THEN '80 a 120 mil'
            ELSE 'Acima de 120 mil'
        END,
        Qtd_Filhos
    FROM clientes
    ON DUPLICATE KEY UPDATE
        Nome_Completo = VALUES(Nome_Completo),
        Data_Nascimento = VALUES(Data_Nascimento),
        Sexo = VALUES(Sexo),
        Escolaridade = VALUES(Escolaridade),
        Faixa_Renda = VALUES(Faixa_Renda),
        Qtd_Filhos = VALUES(Qtd_Filhos);

    INSERT INTO dim_produto (
        ID_Produto, Nome_Produto, Categoria, Marca,
        Preco_Unitario, Custo_Unitario
    )
    SELECT
        p.ID_Produto,
        p.Nome_Produto,
        c.Categoria,
        p.Marca_Produto,
        p.Preco_Unit,
        p.Custo_Unit
    FROM produtos p
    INNER JOIN categorias c
        ON p.ID_Categoria = c.ID_Categoria
    ON DUPLICATE KEY UPDATE
        Nome_Produto = VALUES(Nome_Produto),
        Categoria = VALUES(Categoria),
        Marca = VALUES(Marca),
        Preco_Unitario = VALUES(Preco_Unitario),
        Custo_Unitario = VALUES(Custo_Unitario);

    INSERT INTO dim_loja (
        ID_Loja, Loja, Gerente, Cidade, Estado, Regiao, Num_Funcionarios
    )
    SELECT
        l.ID_Loja,
        l.Loja,
        l.Gerente,
        loc.Cidade,
        loc.Estado,
        loc.`Região`,
        l.Num_Funcionarios
    FROM lojas l
    INNER JOIN locais loc
        ON l.Loja = loc.Cidade
    ON DUPLICATE KEY UPDATE
        Loja = VALUES(Loja),
        Gerente = VALUES(Gerente),
        Cidade = VALUES(Cidade),
        Estado = VALUES(Estado),
        Regiao = VALUES(Regiao),
        Num_Funcionarios = VALUES(Num_Funcionarios);

    DELETE FROM fato_vendas;

    INSERT INTO fato_vendas (
        ID_Pedido, Data_Key, Cliente_Key, Produto_Key,
        Loja_Key, Quantidade, Receita, Custo
    )
    SELECT
        p.ID_Pedido,
        CAST(DATE_FORMAT(p.Data_Venda, '%Y%m%d') AS UNSIGNED),
        dc.Cliente_Key,
        dp.Produto_Key,
        dl.Loja_Key,
        p.Qtd_Vendida,
        p.Receita_Venda,
        p.Custo_Venda
    FROM pedidos p
    INNER JOIN dim_cliente dc
        ON p.ID_Cliente = dc.ID_Cliente
    INNER JOIN dim_produto dp
        ON p.ID_Produto = dp.ID_Produto
    INNER JOIN dim_loja dl
        ON p.ID_Loja = dl.ID_Loja;

    SET v_linhas = ROW_COUNT();
    COMMIT;

    UPDATE etl_execucoes
    SET
        Fim = NOW(),
        Status = 'SUCESSO',
        Linhas_Carregadas = v_linhas,
        Mensagem = 'Carga concluída'
    WHERE Execucao_ID = v_execucao_id;
END$$

DELIMITER ;

CALL sp_carregar_data_warehouse();
