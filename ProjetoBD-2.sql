DROP DATABASE IF EXISTS trabalhoBd;
CREATE DATABASE trabalhoBd;
SET SQL_SAFE_UPDATES = 0;
SET GLOBAL log_bin_trust_function_creators = 1;

USE trabalhoBd;

CREATE TABLE Cliente (
	id INT NOT NULL AUTO_INCREMENT,
    nome varchar(45),
    telefone varchar(20),
    endereco varchar(45),
    email varchar(45),
    cpf varchar(14),
    primary key (id)
);

CREATE TABLE Animal (
	id INT NOT NULL AUTO_INCREMENT,
    nome varchar(45),
    especie varchar(45),
    raca varchar(45),
	idCliente INT,
    primary key (id),
    foreign key (idCliente) REFERENCES Cliente(id) ON DELETE CASCADE
);

CREATE TABLE Veterinario (
	id INT NOT NULL AUTO_INCREMENT,
    nome varchar(45),
    especialidade varchar(45),
    crmv varchar(45),
    primary key (id)
);

CREATE TABLE Consulta (
	id INT NOT NULL AUTO_INCREMENT,
    dia datetime,
    motivo varchar(45),
    comentarios varchar(300),
	idAnimal INT,
    idVeterinario INT,
	primary key (id),
	foreign key (idAnimal) REFERENCES Animal(id) ON DELETE CASCADE,
    foreign key (idVeterinario) REFERENCES Veterinario(id) ON DELETE CASCADE
);

CREATE TABLE Servico (
	id INT NOT NULL AUTO_INCREMENT,
    preco decimal,
    nomeServico varchar(45),
	primary key (id)
);

CREATE TABLE Consulta_has_Servico(
	idConsulta INT,
    idServico INT ,
    PRIMARY KEY (idConsulta, idServico),
    FOREIGN KEY (idConsulta) REFERENCES Consulta(id) ON DELETE CASCADE,
    FOREIGN KEY (idServico) REFERENCES Servico(id) ON DELETE CASCADE
);


INSERT INTO Cliente (nome, telefone, endereco, email, cpf) VALUES
('Jhoncy',  '(24) 992233860', 'Centro, 211','joao@gmail.com','123.456.789-01'),
('Rodriguin',   '(35) 998496043', 'Inatel, 229','rodriguin@yahoo.com.br','234.567.890-12'),
('Joaozin',  '(24) 981320774', 'Rua Azul, 789', 'joaozingameplay@hotmail.com','345.678.901-23');

INSERT INTO Animal (nome, especie, raca, idCliente) VALUES
('Luna',   'Canina', 'Buldog', 1),
('Mingau', 'Felina', 'Chow Chow',1),
('Thor',   'Canina', 'Pug', 3),
('Nina',   'Felina', 'Husky',1),
('Princesa', 'Canina', 'Bit', 2),
('Principe', 'Canina', 'Frances', 2);

INSERT INTO Veterinario (nome, especialidade, crmv) VALUES
('Dra. Ana Souza',  'Clínica Geral', 'CRMV-SP12345'),
('Dr. Bruno Lima',  'Dermatologia',  'CRMV-SP67890'),
('Dra. Carla Melo', 'Cardiologia',   'CRMV-SP54321');

INSERT INTO Servico (preco, nomeServico) VALUES
(120.00, 'Consulta Clínica'),
(80.00,  'Vacinação'),
(200.00, 'Exames Laboratoriais'),
(150.00, 'Ultrassonografia'),
(55.00, 'Tosa'),
(60.00, 'Banho');

INSERT INTO Consulta (dia, motivo, comentarios, idAnimal, idVeterinario) VALUES
('2025-9-10 15:30:00', 'Vacinação', 'Aplicada, animal bem.', 1, 1),
('2025-11-15 09:00:00', 'Coceira',   'Suspeita de alergia; banho medicamentoso.', 2, 2),
('2025-10-09 11:15:00', 'Check-up',  'Sopro leve; solicitar ecocardiograma.', 3, 3),
('2025-9-22 14:00:00', 'Retorno',   'Melhora após medicação.', 2, 2),
('2025-11-24 18:30:00', 'Banho', 'Cheirozin, banho tomado', 4, 2),
('2025-12-12 22:30:00', 'Banho', 'Cheirozin, banho tomado', 5, 2),
('2025-11-22 21:30:00', 'Tosa', 'Tosado, alisa meu pelo', 6, 1);

INSERT INTO Consulta_has_Servico (idConsulta, idServico) VALUES
(1, 2),
(2, 1), 
(2, 3),  
(3, 1),  
(3, 4), 
(4, 1),
(5,6),
(6,6),
(7,5);

UPDATE Animal SET nome = 'Bob' WHERE id = 1;
UPDATE Animal SET especie = 'Canino' WHERE id = 1;
DELETE FROM Consulta Where id = 3;
DELETE FROM Animal Where id = 2;

ALTER TABLE Cliente ADD COLUMN tipoSanguinio VARCHAR(20);
UPDATE Cliente SET tipoSanguinio = 'A++' WHERE id = 1;
ALTER TABLE Cliente DROP COLUMN tipoSanguinio;

DROP USER IF EXISTS 'joao@gmail.com';
DROP USER IF EXISTS 'rodriguin@yahoo.com.br';
CREATE USER 'joao@gmail.com' IDENTIFIED BY '1';
CREATE USER 'rodriguin@yahoo.com.br' IDENTIFIED BY '2';
GRANT ALL PRIVILEGES ON trabalhoBd.* TO 'joao@gmail.com';
GRANT ALL PRIVILEGES ON trabalhoBd.* TO 'rodriguin@yahoo.com.br';


CREATE TRIGGER calcular_desconto  BEFORE INSERT 
ON Servico
FOR EACH ROW SET NEW.preco = 
    CASE 
        WHEN (SELECT COUNT(*) FROM Servico) = 9 THEN NEW.preco * 0.9 
        ELSE NEW.preco 
    END;
    
    
DELIMITER $$
CREATE FUNCTION total_consultas_vet(idVet INT) returns int
deterministic
BEGIN
  RETURN ( SELECT COUNT(*) FROM Consulta WHERE idVeterinario = idVet
);
END$$
DELIMITER ;

CREATE VIEW vw_consultas_detalhadas AS
SELECT 
    c.id AS idConsulta,
    c.dia,
    c.motivo,
    c.comentarios,
    a.nome AS nomeAnimal,
    cli.nome AS nomeCliente,
    v.nome AS nomeVeterinario
FROM Consulta c
LEFT JOIN Animal a ON c.idAnimal = a.id
LEFT JOIN Cliente cli ON a.idCliente = cli.id
LEFT JOIN Veterinario v ON c.idVeterinario = v.id;

SELECT total_consultas_vet(2) AS consultas_vet1;
SELECT * FROM vw_consultas_detalhadas;


