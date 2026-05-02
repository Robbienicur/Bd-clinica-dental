# Fase 6. Álgebra Relacional y Cálculo Relacional

Esta sección contiene cuatro consultas en álgebra relacional y cuatro en cálculo relacional de tuplas, todas sobre el modelo de la clínica dental.

## Notación usada

**Álgebra relacional**

| Símbolo | Operador |
|---|---|
| π | Proyección (selecciona columnas) |
| σ | Selección (filtra renglones) |
| ⋈ | Reunión natural (join) |
| ∪ | Unión |
| ∩ | Intersección |
| − | Diferencia |

**Cálculo relacional de tuplas**

Las consultas tienen la forma `{t | P(t)}`, donde `t` es una variable de tupla y `P(t)` es un predicado lógico. Operadores:

| Símbolo | Significado |
|---|---|
| ∧ | y |
| ∨ | o |
| ¬ | no |
| ∃ | existe |
| ∀ | para todo |
| = | igualdad |

---

## Álgebra Relacional

### Consulta 1

**Enunciado en lenguaje natural:**
Listar a los pacientes que tienen citas programadas.

**Álgebra relacional:**

π<sub>nombre, apellidos</sub>( Paciente ⋈ σ<sub>estado='Programada'</sub>(Cita) )

**Explicación:**
Primero se filtran las citas cuyo estado es 'Programada'. El resultado se une con `Paciente` por `id_paciente` y se proyectan únicamente el nombre y los apellidos del paciente.

---

### Consulta 2

**Enunciado en lenguaje natural:**
Mostrar los tratamientos aplicados en una cita determinada (cita con `id_cita = 1`).

**Álgebra relacional:**

π<sub>nombre, descripcion, costo_aplicado</sub>( σ<sub>id_cita=1</sub>(Cita_Tratamiento) ⋈ Tratamiento )

**Explicación:**
Se filtran los renglones de `Cita_Tratamiento` cuya cita es la 1, se unen con `Tratamiento` por `id_tratamiento` y se proyecta el nombre del tratamiento, su descripción y el costo aplicado.

---

### Consulta 3

**Enunciado en lenguaje natural:**
Mostrar a los dentistas que tienen la especialidad de 'Endodoncia'.

**Álgebra relacional:**

π<sub>Dentista.nombre, Dentista.apellidos</sub>( Dentista ⋈ Dentista_Especialidad ⋈ σ<sub>nombre='Endodoncia'</sub>(Especialidad) )

**Explicación:**
Se filtra `Especialidad` para quedarse solo con la endodoncia, se une con `Dentista_Especialidad` y luego con `Dentista`, y se proyecta el nombre y apellidos del dentista.

---

### Consulta 4

**Enunciado en lenguaje natural:**
Obtener las citas en las que se aplicó un tratamiento de costo superior a 1000 pesos.

**Álgebra relacional:**

π<sub>Cita.id_cita, Cita.fecha, Cita.hora</sub>( Cita ⋈ σ<sub>costo_aplicado>1000</sub>(Cita_Tratamiento) )

**Explicación:**
Se filtran los registros de `Cita_Tratamiento` con costo aplicado mayor a 1000, se unen con `Cita` y se proyectan los datos relevantes de la cita.

---

## Cálculo Relacional de Tuplas

### Consulta 5

**Enunciado en lenguaje natural:**
Obtener todas las citas atendidas por un dentista específico (`id_dentista = 2`).

**Cálculo relacional:**

{ c | Cita(c) ∧ c.id_dentista = 2 ∧ (c.estado = 'Completada' ∨ c.estado = 'Liquidada') }

**Explicación:**
Devuelve todas las tuplas `c` de la relación `Cita` cuyo dentista sea el 2 y cuyo estado indique que ya fue atendida (Completada o Liquidada).

---

### Consulta 6

**Enunciado en lenguaje natural:**
Mostrar a los pacientes que han realizado al menos un pago.

**Cálculo relacional:**

{ p | Paciente(p) ∧ ∃c ∃pg ( Cita(c) ∧ Pago(pg) ∧ c.id_paciente = p.id_paciente ∧ pg.id_cita = c.id_cita ) }

**Explicación:**
Un paciente `p` aparece en el resultado si existe al menos una cita `c` que sea suya y al menos un pago `pg` asociado a esa cita.

---

### Consulta 7

**Enunciado en lenguaje natural:**
Obtener los consultorios que no han sido utilizados en una fecha dada (2026-04-04).

**Cálculo relacional:**

{ co | Consultorio(co) ∧ ¬∃c ( Cita(c) ∧ c.id_consultorio = co.id_consultorio ∧ c.fecha = '2026-04-04' ) }

**Explicación:**
Un consultorio `co` aparece en el resultado si no existe ninguna cita `c` agendada para ese consultorio en la fecha indicada. Es la negación de la existencia.

---

### Consulta 8

**Enunciado en lenguaje natural:**
Obtener a los pacientes con saldo pendiente, entendido como pacientes que tienen al menos una cita con tratamientos aplicados que aún no está liquidada ni cancelada.

**Cálculo relacional:**

{ p | Paciente(p) ∧ ∃c ∃ct ( Cita(c) ∧ Cita_Tratamiento(ct) ∧ c.id_paciente = p.id_paciente ∧ ct.id_cita = c.id_cita ∧ c.estado ≠ 'Liquidada' ∧ c.estado ≠ 'Cancelada' ) }

**Explicación:**
Un paciente `p` queda en el resultado si existe una cita suya con al menos un tratamiento asociado y cuyo estado no es 'Liquidada' ni 'Cancelada'. El cálculo del saldo numérico exacto requiere agregación (SUM), que está fuera del cálculo relacional puro; esta expresión captura la condición lógica equivalente: existe trabajo cobrable que aún no se ha cerrado.
