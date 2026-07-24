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

    SELECT COUNT(*) INTO v_total FROM fato_vendas;
    IF v_total <> 374 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Falha: fato_vendas deve conter 374 linhas';
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
