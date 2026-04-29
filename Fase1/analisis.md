# Fase 1. Análisis del problema

## 1. Problema

Una clínica dental de tamaño mediano administra su operación con hojas de cálculo y notas en papel. Esto genera varios problemas:

- Citas duplicadas para un mismo dentista o consultorio.
- Dificultad para acceder al historial clínico de un paciente.
- Retrasos en la atención.
- Poca claridad sobre los adeudos de cada paciente.

A partir del enunciado se identifica que la clínica necesita registrar pacientes, dentistas con sus especialidades, consultorios, citas, tratamientos y pagos, y mantener el control del saldo pendiente. Las dos reglas de negocio más importantes son:

1. Un dentista no puede atender dos citas al mismo tiempo.
2. Un consultorio no puede asignarse a dos citas en el mismo horario.

## 2. Entidades

| Entidad | Descripción |
|---|---|
| Paciente | Persona que recibe atención en la clínica. |
| Dentista | Profesional que atiende las citas. |
| Especialidad | Áreas en las que un dentista está certificado (ortodoncia, endodoncia, etc.). |
| Consultorio | Espacio físico donde se atienden las citas. |
| Cita | Atención agendada entre un paciente, un dentista y un consultorio. |
| Tratamiento | Servicio dental ofrecido por la clínica (catálogo). |
| Pago | Cobro registrado a una cita. |

Como un dentista puede tener varias especialidades y en una cita se pueden aplicar varios tratamientos, se necesitan dos tablas puente:

| Tabla puente | Relaciona |
|---|---|
| Dentista_Especialidad | Dentista con Especialidad (N:M). |
| Cita_Tratamiento | Cita con Tratamiento (N:M, también guarda el costo aplicado y observaciones). |

## 3. Atributos, tipos de datos y restricciones por entidad

### Paciente

| Atributo | Tipo de dato | Restricciones |
|---|---|---|
| id_paciente | INT | PRIMARY KEY, AUTO_INCREMENT |
| nombre | VARCHAR(100) | NOT NULL |
| apellidos | VARCHAR(150) | NOT NULL |
| fecha_nacimiento | DATE | NOT NULL, CHECK (fecha_nacimiento <= CURRENT_DATE) |
| telefono | VARCHAR(20) | |
| correo | VARCHAR(100) | UNIQUE |
| direccion | VARCHAR(255) | |

### Dentista

| Atributo | Tipo de dato | Restricciones |
|---|---|---|
| id_dentista | INT | PRIMARY KEY, AUTO_INCREMENT |
| nombre | VARCHAR(100) | NOT NULL |
| apellidos | VARCHAR(150) | NOT NULL |
| cedula | VARCHAR(20) | NOT NULL, UNIQUE |
| telefono | VARCHAR(20) | |
| correo | VARCHAR(100) | UNIQUE |

### Especialidad

| Atributo | Tipo de dato | Restricciones |
|---|---|---|
| id_especialidad | INT | PRIMARY KEY, AUTO_INCREMENT |
| nombre | VARCHAR(100) | NOT NULL, UNIQUE |
| descripcion | VARCHAR(255) | |

### Dentista_Especialidad

| Atributo | Tipo de dato | Restricciones |
|---|---|---|
| id_dentista | INT | PK, FOREIGN KEY -> Dentista(id_dentista) |
| id_especialidad | INT | PK, FOREIGN KEY -> Especialidad(id_especialidad) |

PK compuesta: (id_dentista, id_especialidad).

### Consultorio

| Atributo | Tipo de dato | Restricciones |
|---|---|---|
| id_consultorio | INT | PRIMARY KEY, AUTO_INCREMENT |
| numero | INT | NOT NULL |
| piso | INT | NOT NULL |

UNIQUE (numero, piso) para que no haya dos consultorios con el mismo número en el mismo piso.

### Cita

| Atributo | Tipo de dato | Restricciones |
|---|---|---|
| id_cita | INT | PRIMARY KEY, AUTO_INCREMENT |
| fecha | DATE | NOT NULL |
| hora | TIME | NOT NULL |
| motivo | VARCHAR(255) | |
| estado | VARCHAR(20) | NOT NULL, DEFAULT 'Programada', CHECK (estado IN ('Programada','Completada','Cancelada','Liquidada')) |
| id_paciente | INT | NOT NULL, FOREIGN KEY -> Paciente(id_paciente) |
| id_dentista | INT | NOT NULL, FOREIGN KEY -> Dentista(id_dentista) |
| id_consultorio | INT | NOT NULL, FOREIGN KEY -> Consultorio(id_consultorio) |

Restricciones adicionales a nivel de tabla:

- UNIQUE (fecha, hora, id_dentista): un dentista no puede tener dos citas exactamente al mismo horario.
- UNIQUE (fecha, hora, id_consultorio): un consultorio no puede usarse en dos citas al mismo horario.

Estas dos restricciones cubren el caso del horario idéntico. La validación de traslapes de horario más amplios se hará con un trigger en la Fase 5.

### Tratamiento

| Atributo | Tipo de dato | Restricciones |
|---|---|---|
| id_tratamiento | INT | PRIMARY KEY, AUTO_INCREMENT |
| nombre | VARCHAR(100) | NOT NULL |
| descripcion | VARCHAR(255) | |
| costo_base | DECIMAL(10,2) | NOT NULL, CHECK (costo_base >= 0) |

### Cita_Tratamiento

| Atributo | Tipo de dato | Restricciones |
|---|---|---|
| id_cita | INT | PK, FOREIGN KEY -> Cita(id_cita) |
| id_tratamiento | INT | PK, FOREIGN KEY -> Tratamiento(id_tratamiento) |
| observaciones | VARCHAR(255) | |
| costo_aplicado | DECIMAL(10,2) | NOT NULL, CHECK (costo_aplicado >= 0) |

PK compuesta: (id_cita, id_tratamiento).

### Pago

| Atributo | Tipo de dato | Restricciones |
|---|---|---|
| id_pago | INT | PRIMARY KEY, AUTO_INCREMENT |
| id_cita | INT | NOT NULL, FOREIGN KEY -> Cita(id_cita) |
| fecha_pago | DATE | NOT NULL, DEFAULT CURRENT_DATE |
| monto | DECIMAL(10,2) | NOT NULL, CHECK (monto > 0) |
| metodo_pago | VARCHAR(50) | NOT NULL, CHECK (metodo_pago IN ('Efectivo','Tarjeta','Transferencia')) |

## 4. Llaves primarias y foráneas

| Tabla | Llave primaria | Llaves foráneas |
|---|---|---|
| Paciente | id_paciente | - |
| Dentista | id_dentista | - |
| Especialidad | id_especialidad | - |
| Dentista_Especialidad | (id_dentista, id_especialidad) | id_dentista, id_especialidad |
| Consultorio | id_consultorio | - |
| Cita | id_cita | id_paciente, id_dentista, id_consultorio |
| Tratamiento | id_tratamiento | - |
| Cita_Tratamiento | (id_cita, id_tratamiento) | id_cita, id_tratamiento |
| Pago | id_pago | id_cita |

## 5. Relaciones entre entidades y cardinalidades

| Relación | Cardinalidad | Lectura |
|---|---|---|
| Paciente - Cita | 1:N | Un paciente puede tener varias citas; cada cita pertenece a un solo paciente. |
| Dentista - Cita | 1:N | Un dentista atiende varias citas; cada cita es atendida por un solo dentista. |
| Consultorio - Cita | 1:N | En un consultorio se llevan a cabo varias citas; cada cita ocurre en un solo consultorio. |
| Dentista - Especialidad | N:M | Un dentista puede tener varias especialidades y una especialidad la pueden tener varios dentistas. |
| Cita - Tratamiento | N:M | En una cita se aplican uno o varios tratamientos y un tratamiento puede aplicarse en varias citas. |
| Cita - Pago | 1:N | Una cita puede recibir varios pagos parciales; cada pago corresponde a una sola cita. |

## 6. Resumen de restricciones de integridad

| Tipo | Aplicación |
|---|---|
| PRIMARY KEY | Una llave primaria por tabla. Las tablas puente usan llave compuesta. |
| FOREIGN KEY | Cita referencia a Paciente, Dentista y Consultorio. Pago referencia a Cita. Cita_Tratamiento referencia a Cita y Tratamiento. Dentista_Especialidad referencia a Dentista y Especialidad. |
| NOT NULL | Identificadores, nombres, fechas, horas, montos, estados y llaves foráneas obligatorias. |
| UNIQUE | Correos de paciente y dentista, cédula del dentista, nombre de la especialidad, par (numero, piso) en consultorio, par (fecha, hora, id_dentista) y (fecha, hora, id_consultorio) en cita. |
| CHECK | costo_base >= 0, costo_aplicado >= 0, monto > 0, fecha_nacimiento <= fecha actual, estado dentro del conjunto válido, metodo_pago dentro del conjunto válido. |
| DEFAULT | estado de cita en 'Programada', fecha_pago en la fecha actual. |

## Notas sobre el diseño

- El saldo pendiente de una cita no se almacena como atributo. Se calcula como la suma de los `costo_aplicado` de los tratamientos asociados a la cita menos la suma de los pagos asociados. La función para obtenerlo se implementará en la Fase 5.
- Los conjuntos de valores válidos para `estado` y `metodo_pago` se manejan con CHECK por simplicidad. Una alternativa sería modelarlos como catálogos aparte o usar ENUM.
- Se separa Especialidad como entidad propia para evitar duplicar el nombre de la especialidad en cada dentista y permitir que un mismo dentista pueda tener más de una.
