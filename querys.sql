----------------------------------- VIEW PARA VER PRODUTOS EM FALTA NO ESTOQUE

CREATE VIEW produtos_sem_estoque AS
SELECT * FROM produto
WHERE quantidade = 0;

visualizar : SELECT * FROM produtos_sem_estoque;


----------------------------------- VIEW PARA VER VENDEDORA QU MAIS VENDEU NO MÊS ATUAL

CREATE VIEW atendente_mais_vendas AS
SELECT f.nome, COUNT(*) AS total_vendas
FROM venda AS  v
JOIN funcionario AS f ON v.id_codigofuncionario = f.codigo_funcionario
WHERE MONTH(v.data) = MONTH(CURRENT_DATE)
GROUP BY v.id_codigofuncionario, f.nome
ORDER BY total_vendas DESC
LIMIT 1;


visualizar: SELECT * FROM vendedora_mais_vendas;


-----------------------------------TRIGGERS 

-- ATUALIZA A QUANTIDADE NO ESTOQUE APÓS VENDA


DELIMITER $
CREATE TRIGGER baixa_estoque
AFTER INSERT ON venda_produto
FOR EACH ROW
BEGIN
UPDATE produto
SET produto.quantidade = produto.quantidade - new.quantidade
WHERE produto.id = new.id_produto;
END $


-- ATUALIZA O CAMPO VALOR NA TABELA VENDA, FAZENDO A MULTIPLICAÇÃO DA QUANTIDADE E DO VALOR DOS PRODUTOS VENDIDOS NAQUELA VENDA. COM O RESULTADO, IRÁ COLOCAR AUTOMATICAMENTE O TOTAL NO CAMPO VALOR.

DELIMITER $
CREATE TRIGGER adicionar_valor
AFTER INSERT ON venda_produto
FOR EACH ROW
BEGIN
    UPDATE venda AS v
    SET v.valor = (
        SELECT SUM(p.valor * vp.quantidade)
        FROM produto AS p
        JOIN venda_produto vp ON vp.id_produto = p.id
        WHERE vp.id_venda = v.id
    )
    WHERE v.id = NEW.id_venda;
END $


----------------------------------- FUNÇÃO
    
-- VER A QUANTIDADE EM REAIS QUE O CLIENTE JA GASTOU NA LOJA

DELIMITER $
CREATE FUNCTION valortotal_compras(cliente_id INT) 
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10, 2);

    SELECT SUM(venda.valor) INTO total
    FROM venda 
    WHERE venda.id_cliente = cliente_id;

    RETURN total;
END $

visualizar: SELECT valortotal_compras(2);


-- MÉDIA DE VENDA DO MÊS 

DELIMITER $ 
CREATE FUNCTION mediavendas_mes()
RETURNS DECIMAL(10, 2)
READS SQL DATA
BEGIN
    DECLARE media DECIMAL(10, 2);
    SELECT AVG(total) INTO media
    FROM (
        SELECT MONTH(data) AS mes, SUM(valor) AS total
        FROM venda
        GROUP BY mes
    ) AS vendas_por_mes;

    RETURN media;
END $


 visualizar: SELECT mediavendas_mes();
