-- Fase 5 - Procedimientos, funciones y triggers

USE clinica_dental;


-- Funciones

-- Suma el costo aplicado de los tratamientos de una cita
DELIMITER //
CREATE FUNCTION fn_TotalCita(p_id_cita INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(10,2);
    SELECT IFNULL(SUM(costo_aplicado), 0) INTO v_total
    FROM Cita_Tratamiento
    WHERE id_cita = p_id_cita;
    RETURN v_total;
END //
DELIMITER ;

-- Total de la cita menos lo ya pagado
DELIMITER //
CREATE FUNCTION fn_SaldoPendiente(p_id_cita INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(10,2);
    DECLARE v_pagado DECIMAL(10,2);
    SET v_total = fn_TotalCita(p_id_cita);
    SELECT IFNULL(SUM(monto), 0) INTO v_pagado
    FROM Pago
    WHERE id_cita = p_id_cita;
    RETURN v_total - v_pagado;
END //
DELIMITER ;

-- Cuenta las citas activas de un dentista en una fecha
DELIMITER //
CREATE FUNCTION fn_CitasActivasDentista(p_id_dentista INT, p_fecha DATE)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total INT;
    SELECT COUNT(*) INTO v_total
    FROM Cita
    WHERE id_dentista = p_id_dentista
      AND fecha = p_fecha
      AND estado IN ('Programada', 'Completada', 'Liquidada');
    RETURN v_total;
END //
DELIMITER ;

-- Edad del paciente en anios cumplidos
DELIMITER //
CREATE FUNCTION fn_EdadPaciente(p_id_paciente INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_nacimiento DATE;
    SELECT fecha_nacimiento INTO v_nacimiento
    FROM Paciente
    WHERE id_paciente = p_id_paciente;
    RETURN TIMESTAMPDIFF(YEAR, v_nacimiento, CURRENT_DATE);
END //
DELIMITER ;


-- Triggers

-- La hora de la cita debe estar entre 08:00 y 19:00
DELIMITER //
CREATE TRIGGER tg_ValidarHorarioCita
BEFORE INSERT ON Cita
FOR EACH ROW
BEGIN
    IF NEW.hora < '08:00:00' OR NEW.hora > '19:00:00' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La hora de la cita debe estar entre 08:00 y 19:00.';
    END IF;
END //
DELIMITER ;

-- Si no se especifica costo, toma el costo base del tratamiento
DELIMITER //
CREATE TRIGGER tg_ActualizarSubtotalTratamiento
BEFORE INSERT ON Cita_Tratamiento
FOR EACH ROW
BEGIN
    IF NEW.costo_aplicado IS NULL OR NEW.costo_aplicado = 0 THEN
        SET NEW.costo_aplicado = (SELECT costo_base FROM Tratamiento WHERE id_tratamiento = NEW.id_tratamiento);
    END IF;
END //
DELIMITER ;

-- No permite pagos mayores al saldo pendiente
DELIMITER //
CREATE TRIGGER tg_EvitarPagoMayorAdeudo
BEFORE INSERT ON Pago
FOR EACH ROW
BEGIN
    DECLARE v_saldo DECIMAL(10,2);
    SET v_saldo = fn_SaldoPendiente(NEW.id_cita);
    IF NEW.monto > v_saldo THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El monto del pago excede el saldo pendiente de la cita.';
    END IF;
END //
DELIMITER ;

-- Si el saldo llega a cero, marca la cita como Liquidada
DELIMITER //
CREATE TRIGGER tg_LiquidarCitaAlPagar
AFTER INSERT ON Pago
FOR EACH ROW
BEGIN
    IF fn_SaldoPendiente(NEW.id_cita) = 0 THEN
        UPDATE Cita
        SET estado = 'Liquidada'
        WHERE id_cita = NEW.id_cita;
    END IF;
END //
DELIMITER ;


-- Procedimientos

-- Registra una cita nueva en estado Programada
DELIMITER //
CREATE PROCEDURE sp_RegistrarCita(
    IN p_fecha DATE,
    IN p_hora TIME,
    IN p_motivo VARCHAR(255),
    IN p_id_paciente INT,
    IN p_id_dentista INT,
    IN p_id_consultorio INT
)
BEGIN
    INSERT INTO Cita (fecha, hora, motivo, estado, id_paciente, id_dentista, id_consultorio)
    VALUES (p_fecha, p_hora, p_motivo, 'Programada', p_id_paciente, p_id_dentista, p_id_consultorio);
END //
DELIMITER ;

-- Registra un pago de una cita
DELIMITER //
CREATE PROCEDURE sp_RegistrarPago(
    IN p_id_cita INT,
    IN p_monto DECIMAL(10,2),
    IN p_metodo VARCHAR(50)
)
BEGIN
    INSERT INTO Pago (id_cita, fecha_pago, monto, metodo_pago)
    VALUES (p_id_cita, CURRENT_DATE, p_monto, p_metodo);
END //
DELIMITER ;

-- Cancela una cita si no esta liquidada o cancelada ya
DELIMITER //
CREATE PROCEDURE sp_CancelarCita(IN p_id_cita INT)
BEGIN
    DECLARE v_estado VARCHAR(20);
    SELECT estado INTO v_estado FROM Cita WHERE id_cita = p_id_cita;

    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cita no existe.';
    ELSEIF v_estado = 'Liquidada' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede cancelar una cita liquidada.';
    ELSEIF v_estado = 'Cancelada' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cita ya esta cancelada.';
    ELSE
        UPDATE Cita SET estado = 'Cancelada' WHERE id_cita = p_id_cita;
    END IF;
END //
DELIMITER ;

-- Agrega un tratamiento a una cita
DELIMITER //
CREATE PROCEDURE sp_AgregarTratamiento(
    IN p_id_cita INT,
    IN p_id_tratamiento INT,
    IN p_observaciones VARCHAR(255),
    IN p_costo DECIMAL(10,2)
)
BEGIN
    INSERT INTO Cita_Tratamiento (id_cita, id_tratamiento, observaciones, costo_aplicado)
    VALUES (p_id_cita, p_id_tratamiento, p_observaciones, IFNULL(p_costo, 0));
END //
DELIMITER ;


-- Pruebas

SELECT fn_TotalCita(1) AS total_cita_1;
SELECT fn_SaldoPendiente(1) AS saldo_cita_1;
SELECT fn_CitasActivasDentista(2, '2026-04-04') AS citas_miguel_4abr;
SELECT fn_EdadPaciente(1) AS edad_ana;

CALL sp_RegistrarCita('2026-05-10', '11:00:00', 'Limpieza anual', 4, 3, 2);
CALL sp_AgregarTratamiento(LAST_INSERT_ID(), 1, 'Limpieza programada', NULL);
CALL sp_RegistrarPago(1, 1000.00, 'Efectivo');
CALL sp_CancelarCita(7);
