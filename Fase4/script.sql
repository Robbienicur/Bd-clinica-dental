-- Proyecto Final - Sistema de gestion para una clinica dental

DROP DATABASE IF EXISTS clinica_dental;
CREATE DATABASE clinica_dental;
USE clinica_dental;


-- Tablas

CREATE TABLE Paciente (
    id_paciente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(150) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    telefono VARCHAR(20),
    correo VARCHAR(100) UNIQUE,
    direccion VARCHAR(255),
    CONSTRAINT chk_paciente_nacimiento CHECK (fecha_nacimiento <= CURRENT_DATE)
);

CREATE TABLE Dentista (
    id_dentista INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(150) NOT NULL,
    cedula VARCHAR(20) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    correo VARCHAR(100) UNIQUE
);

CREATE TABLE Especialidad (
    id_especialidad INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(255)
);

-- Puente N:M dentista-especialidad
CREATE TABLE Dentista_Especialidad (
    id_dentista INT NOT NULL,
    id_especialidad INT NOT NULL,
    PRIMARY KEY (id_dentista, id_especialidad),
    FOREIGN KEY (id_dentista) REFERENCES Dentista(id_dentista),
    FOREIGN KEY (id_especialidad) REFERENCES Especialidad(id_especialidad)
);

CREATE TABLE Consultorio (
    id_consultorio INT AUTO_INCREMENT PRIMARY KEY,
    numero INT NOT NULL,
    piso INT NOT NULL,
    UNIQUE (numero, piso)
);

CREATE TABLE Tratamiento (
    id_tratamiento INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255),
    costo_base DECIMAL(10,2) NOT NULL,
    CONSTRAINT chk_trat_costo CHECK (costo_base >= 0)
);

CREATE TABLE Cita (
    id_cita INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    motivo VARCHAR(255),
    estado VARCHAR(20) NOT NULL DEFAULT 'Programada',
    id_paciente INT NOT NULL,
    id_dentista INT NOT NULL,
    id_consultorio INT NOT NULL,
    FOREIGN KEY (id_paciente) REFERENCES Paciente(id_paciente),
    FOREIGN KEY (id_dentista) REFERENCES Dentista(id_dentista),
    FOREIGN KEY (id_consultorio) REFERENCES Consultorio(id_consultorio),
    UNIQUE (fecha, hora, id_dentista),
    UNIQUE (fecha, hora, id_consultorio),
    CONSTRAINT chk_cita_estado CHECK (estado IN ('Programada','Completada','Cancelada','Liquidada'))
);

-- Puente N:M cita-tratamiento con costo aplicado
CREATE TABLE Cita_Tratamiento (
    id_cita INT NOT NULL,
    id_tratamiento INT NOT NULL,
    observaciones VARCHAR(255),
    costo_aplicado DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_cita, id_tratamiento),
    FOREIGN KEY (id_cita) REFERENCES Cita(id_cita),
    FOREIGN KEY (id_tratamiento) REFERENCES Tratamiento(id_tratamiento),
    CONSTRAINT chk_ct_costo CHECK (costo_aplicado >= 0)
);

CREATE TABLE Pago (
    id_pago INT AUTO_INCREMENT PRIMARY KEY,
    id_cita INT NOT NULL,
    fecha_pago DATE NOT NULL DEFAULT (CURRENT_DATE),
    monto DECIMAL(10,2) NOT NULL,
    metodo_pago VARCHAR(50) NOT NULL,
    FOREIGN KEY (id_cita) REFERENCES Cita(id_cita),
    CONSTRAINT chk_pago_monto CHECK (monto > 0),
    CONSTRAINT chk_pago_metodo CHECK (metodo_pago IN ('Efectivo','Tarjeta','Transferencia'))
);


-- Datos de prueba

INSERT INTO Paciente (nombre, apellidos, fecha_nacimiento, telefono, correo, direccion) VALUES
('Ana', 'Lopez Garcia', '2002-03-14', '2223456789', 'ana.lopez@correo.com', 'Cholula, Puebla'),
('Carlos', 'Martinez Ruiz', '2001-08-22', '2224567890', 'carlos.martinez@correo.com', 'Puebla, Puebla'),
('Diana', 'Hernandez Soto', '2003-01-10', '2225678901', 'diana.hernandez@correo.com', 'San Andres Cholula, Puebla'),
('Jose', 'Ramirez Torres', '2000-11-05', '2226789012', 'jose.ramirez@correo.com', 'Atlixco, Puebla'),
('Mariana', 'Perez Castillo', '2002-06-30', '2227890123', 'mariana.perez@correo.com', 'San Pedro Cholula, Puebla');

INSERT INTO Dentista (nombre, apellidos, cedula, telefono, correo) VALUES
('Laura', 'Sanchez', 'CED12345', '2221112233', 'laura.sanchez@clinica.com'),
('Miguel', 'Torres', 'CED12346', '2221113344', 'miguel.torres@clinica.com'),
('Fernanda', 'Gomez', 'CED12347', '2221114455', 'fernanda.gomez@clinica.com');

INSERT INTO Especialidad (nombre, descripcion) VALUES
('Ortodoncia', 'Correccion de la posicion dental y maxilar'),
('Endodoncia', 'Tratamiento de conductos y nervios dentales'),
('Odontologia general', 'Atencion preventiva y restaurativa basica'),
('Periodoncia', 'Tratamiento de encias y soporte dental'),
('Cirugia oral', 'Extracciones complejas y procedimientos quirurgicos');

INSERT INTO Dentista_Especialidad (id_dentista, id_especialidad) VALUES
(1, 1), (1, 3),
(2, 2), (2, 5),
(3, 3), (3, 4);

INSERT INTO Consultorio (numero, piso) VALUES
(101, 1),
(102, 1),
(201, 2);

INSERT INTO Tratamiento (nombre, descripcion, costo_base) VALUES
('Limpieza dental', 'Eliminacion de sarro y placa', 500.00),
('Resina', 'Restauracion dental con material resina', 850.00),
('Extraccion', 'Remocion de una pieza dental', 1200.00),
('Endodoncia', 'Tratamiento de conducto', 2500.00),
('Evaluacion ortodoncica', 'Revision y diagnostico de ortodoncia', 700.00),
('Blanqueamiento', 'Blanqueamiento dental en consultorio', 2000.00);

INSERT INTO Cita (fecha, hora, motivo, estado, id_paciente, id_dentista, id_consultorio) VALUES
('2026-04-02', '09:00:00', 'Dolor molar', 'Completada', 1, 2, 1),
('2026-04-02', '10:00:00', 'Limpieza general', 'Liquidada', 2, 3, 2),
('2026-04-03', '11:30:00', 'Revision de brackets', 'Liquidada', 3, 1, 3),
('2026-04-03', '13:00:00', 'Caries en premolar', 'Completada', 4, 3, 1),
('2026-04-04', '09:30:00', 'Extraccion dental', 'Completada', 5, 2, 2),
('2026-04-04', '12:00:00', 'Dolor e infeccion', 'Completada', 2, 2, 1),
('2026-05-05', '10:30:00', 'Valoracion general', 'Programada', 1, 3, 3),
('2026-05-05', '12:30:00', 'Ajuste de ortodoncia', 'Programada', 3, 1, 3);

INSERT INTO Cita_Tratamiento (id_cita, id_tratamiento, observaciones, costo_aplicado) VALUES
(1, 4, 'Tratamiento de conducto en molar inferior', 2500.00),
(2, 1, 'Limpieza completa sin complicaciones', 500.00),
(3, 5, 'Evaluacion y ajuste inicial', 700.00),
(4, 2, 'Aplicacion de resina en premolar', 850.00),
(5, 3, 'Extraccion de tercer molar', 1200.00),
(6, 4, 'Endodoncia por infeccion avanzada', 2500.00),
(7, 1, 'Limpieza sugerida en valoracion', 500.00),
(8, 5, 'Revision y ajuste de ortodoncia', 700.00);

INSERT INTO Pago (id_cita, fecha_pago, monto, metodo_pago) VALUES
(1, '2026-04-02', 1500.00, 'Tarjeta'),
(2, '2026-04-02', 500.00, 'Efectivo'),
(3, '2026-04-03', 700.00, 'Tarjeta'),
(4, '2026-04-03', 850.00, 'Transferencia'),
(5, '2026-04-04', 600.00, 'Efectivo'),
(6, '2026-04-04', 2500.00, 'Tarjeta');


-- Consultas de validacion

SELECT id_paciente, nombre, apellidos, correo FROM Paciente;

SELECT d.nombre AS dentista, e.nombre AS especialidad
FROM Dentista d
JOIN Dentista_Especialidad de ON d.id_dentista = de.id_dentista
JOIN Especialidad e ON de.id_especialidad = e.id_especialidad
ORDER BY d.nombre;

SELECT c.id_cita, c.fecha, c.hora, c.estado,
       p.nombre AS paciente,
       d.nombre AS dentista,
       co.numero AS consultorio
FROM Cita c
JOIN Paciente p ON c.id_paciente = p.id_paciente
JOIN Dentista d ON c.id_dentista = d.id_dentista
JOIN Consultorio co ON c.id_consultorio = co.id_consultorio
ORDER BY c.fecha, c.hora;

SELECT ct.id_cita, t.nombre, ct.costo_aplicado, ct.observaciones
FROM Cita_Tratamiento ct
JOIN Tratamiento t ON ct.id_tratamiento = t.id_tratamiento
ORDER BY ct.id_cita;

SELECT id_cita, SUM(monto) AS total_pagado FROM Pago GROUP BY id_cita;

SELECT metodo_pago, SUM(monto) AS total FROM Pago GROUP BY metodo_pago;

SELECT estado, COUNT(*) AS total FROM Cita GROUP BY estado;
