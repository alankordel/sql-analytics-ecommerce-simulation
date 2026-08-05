-- =====================================================
-- AUTOMATED DATA QUALITY VALIDATION
-- Fails with SQLSTATE 45000 when an invariant is broken.
-- =====================================================

USE ecommerce_analytics;

DROP PROCEDURE IF EXISTS sp_validar_projeto;

DELIMITER $$

CREATE PROCEDURE sp_validar_projeto()
BEGIN
    DECLARE v_total INT;
    DECLARE v_diferenca DECIMAL(14,2);
    DECLARE v_fato_linhas_antes INT;
    DECLARE v_fato_linhas_depois INT;
    DECLARE v_fato_receita_antes DECIMAL(14,2);
    DECLARE v_fato_receita_depois DECIMAL(14,2);
    DECLARE v_fato_custo_antes DECIMAL(14,2);
    DECLARE v_fato_custo_depois DECIMAL(14,2);

    SELECT COUNT(*) INTO v_total FROM categorias;
    IF v_total <> 7 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Falha: categorias deve conter 7 linhas';
    END IF;

    SELECT COUNT(*) INTO v_total FROM clientes;
    IF v_total <> 100 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Falha: clientes deve conter 100 linhas';
    END IF;

    SELECT COUNT(*) INTO v_total FROM locais;
    IF v_total <> 8 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Falha: locais deve conter 8 linhas';
    END IF;

    SELECT COUNT(*) INTO v_total FROM lojas;
    IF v_total <> 8 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Falha: lojas deve conter 8 linhas';
    END IF;

    SELECT COUNT(*) INTO v_total FROM produtos;
    IF v_total <> 16 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Falha: produtos deve conter 16 linhas';
    END IF;

    SELECT COUNT(*) INTO v_total FROM pedidos;
    IF v_total <> 374 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Falha: pedidos deve conter 374 linhas';
    END IF;

    SELECT COUNT(*) INTO v_total
    FROM pedidos p
    LEFT JOIN clientes c ON p.ID_Cliente = c.ID_Cliente
    LEFT JOIN produtos pr ON p.ID_Produto = pr.ID_Produto
    LEFT JOIN lojas l ON p.ID_Loja = l.ID_Loja
    WHERE c.ID_Cliente IS NULL
       OR pr.ID_Produto IS NULL
       OR l.ID_Loja IS NULL;
    IF v_total <> 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Falha: pedidos órfãos encontrados';
    END IF;

    SELECT COUNT(*) - COUNT(DISTINCT ID_Pedido) INTO v_total
    FROM pedidos;
    IF v_total <> 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Falha: IDs de pedidos duplicados';
    END IF;

    SELECT COUNT(*) INTO v_total
    FROM pedidos
    WHERE Receita_Venda <> Preco_Unit * Qtd_Vendida;
    IF v_total <> 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Falha: receita divergente de preço x quantidade';
    END IF;

    SELECT COUNT(*) INTO v_total
    FROM pedidos
    WHERE Custo_Venda <> Custo_Unit * Qtd_Vendida;
    IF v_total <> 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Falha: custo divergente de custo unitário x quantidade';
    END IF;

    SELECT COUNT(*) INTO v_total
    FROM pedidos
    WHERE Receita_Venda < 0 OR Custo_Venda < 0 OR Qtd_Vendida <= 0;
    IF v_total <> 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Falha: medidas de venda fora dos limites válidos';
    END IF;

    SELECT COUNT(*) INTO v_total
    FROM pedidos
    WHERE Data_Venda < '2019-01-01' OR Data_Venda > '2019-12-31';
    IF v_total <> 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Falha: data de venda fora do ano de 2019';
    END IF;

    SELECT
        (SELECT COUNT(*) - COUNT(DISTINCT Data_Completa) FROM dim_data) +
        (SELECT COUNT(*) - COUNT(DISTINCT ID_Cliente) FROM dim_cliente) +
        (SELECT COUNT(*) - COUNT(DISTINCT ID_Produto) FROM dim_produto) +
        (SELECT COUNT(*) - COUNT(DISTINCT ID_Loja) FROM dim_loja)
    INTO v_total;
    IF v_total <> 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Falha: chave natural duplicada em dimensão';
    END IF;

    SELECT COUNT(*) INTO v_total FROM fato_vendas;
    IF v_total <> 374 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Falha: fato_vendas deve conter 374 linhas';
    END IF;

    SELECT COUNT(*) INTO v_total
    FROM fato_vendas f
    LEFT JOIN dim_data d ON f.Data_Key = d.Data_Key
    LEFT JOIN dim_cliente c ON f.Cliente_Key = c.Cliente_Key
    LEFT JOIN dim_produto p ON f.Produto_Key = p.Produto_Key
    LEFT JOIN dim_loja l ON f.Loja_Key = l.Loja_Key
    WHERE d.Data_Key IS NULL
       OR c.Cliente_Key IS NULL
       OR p.Produto_Key IS NULL
       OR l.Loja_Key IS NULL;
    IF v_total <> 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Falha: chave da fato sem correspondência em dimensão';
    END IF;

    SELECT COUNT(*) - COUNT(DISTINCT ID_Pedido) INTO v_total
    FROM fato_vendas;
    IF v_total <> 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Falha: pedidos duplicados na tabela fato';
    END IF;

    SELECT ABS(
        (SELECT SUM(Receita_Venda) FROM pedidos) -
        (SELECT SUM(Receita) FROM fato_vendas)
    ) INTO v_diferenca;
    IF v_diferenca <> 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Falha: receita não reconciliada';
    END IF;

    SELECT ABS(
        (SELECT SUM(Custo_Venda) FROM pedidos) -
        (SELECT SUM(Custo) FROM fato_vendas)
    ) INTO v_diferenca;
    IF v_diferenca <> 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Falha: custo não reconciliado';
    END IF;

    -- Primeira execução controlada para estabelecer a referência do teste.
    CALL sp_carregar_data_warehouse();

    SELECT COUNT(*), SUM(Receita), SUM(Custo)
    INTO v_fato_linhas_antes, v_fato_receita_antes, v_fato_custo_antes
    FROM fato_vendas;

    -- A segunda execução deve manter o mesmo estado lógico da tabela fato.
    CALL sp_carregar_data_warehouse();

    SELECT COUNT(*), SUM(Receita), SUM(Custo)
    INTO v_fato_linhas_depois, v_fato_receita_depois, v_fato_custo_depois
    FROM fato_vendas;

    IF v_fato_linhas_antes <> v_fato_linhas_depois
       OR v_fato_receita_antes <> v_fato_receita_depois
       OR v_fato_custo_antes <> v_fato_custo_depois THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Falha: ETL não é idempotente';
    END IF;

    SELECT COUNT(*) - COUNT(DISTINCT ID_Pedido) INTO v_total
    FROM fato_vendas;
    IF v_total <> 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Falha: ETL duplicou pedidos na tabela fato';
    END IF;

    SELECT COUNT(*) INTO v_total
    FROM (
        SELECT Status
        FROM etl_execucoes
        ORDER BY Execucao_ID DESC
        LIMIT 1
    ) ultima_execucao
    WHERE Status = 'SUCESSO';
    IF v_total <> 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Falha: última execução do ETL sem sucesso';
    END IF;

    SELECT
        'SUCESSO' AS Status,
        'Todas as validações foram concluídas' AS Mensagem;
END$$

DELIMITER ;

CALL sp_validar_projeto();
DROP PROCEDURE sp_validar_projeto;
