# Fase 3. Normalización

El diseño llega hasta Tercera Forma Normal (3FN). A continuación se justifica que cada tabla cumple con 1FN, 2FN y 3FN.

## 1FN. Atomicidad y ausencia de grupos repetidos

Una tabla está en 1FN si todos sus atributos contienen un solo valor por celda y no hay grupos repetidos.

- En `Paciente`, `Dentista`, `Consultorio`, `Tratamiento` y `Especialidad` cada atributo guarda un único valor. Por ejemplo, no se almacena una lista de teléfonos en una sola celda; se reserva un campo `telefono` con un solo número.
- Como un dentista puede tener varias especialidades y eso rompería 1FN si se guardara como lista en `Dentista`, se modela con la tabla puente `Dentista_Especialidad`.
- De la misma forma, los tratamientos aplicados en una cita no se guardan como una lista dentro de `Cita`, sino que cada tratamiento aplicado es un renglón en `Cita_Tratamiento`.
- Los pagos parciales tampoco se concentran en `Cita`. Cada pago es un renglón nuevo en `Pago`.

## 2FN. Sin dependencias parciales sobre claves compuestas

Una tabla está en 2FN si está en 1FN y todo atributo no primo depende funcionalmente de la clave primaria completa, no solo de una parte. Esto solo aplica cuando la clave es compuesta.

- Las tablas con clave simple (`Paciente`, `Dentista`, `Especialidad`, `Consultorio`, `Cita`, `Tratamiento`, `Pago`) cumplen 2FN automáticamente porque no tienen claves compuestas.
- `Dentista_Especialidad` tiene clave compuesta `(id_dentista, id_especialidad)` pero no contiene atributos no primos. No hay nada que pueda depender parcialmente de la clave.
- `Cita_Tratamiento` tiene clave compuesta `(id_cita, id_tratamiento)`. Sus atributos no primos son `observaciones` y `costo_aplicado`, y ambos dependen de la combinación específica de cita y tratamiento, no de uno solo. El mismo tratamiento aplicado en otra cita puede tener observaciones distintas y costo aplicado distinto.

## 3FN. Sin dependencias transitivas entre atributos no primos

Una tabla está en 3FN si está en 2FN y ningún atributo no primo depende de otro atributo no primo.

- En `Paciente`, los atributos `nombre`, `apellidos`, `fecha_nacimiento`, `telefono`, `correo` y `direccion` dependen directamente de `id_paciente` y no entre sí.
- En `Dentista`, lo mismo: `nombre`, `apellidos`, `cedula`, `telefono` y `correo` dependen de `id_dentista` y no se determinan unos a otros.
- La especialidad del dentista no se guarda como atributo dentro de `Dentista`. Si así fuera, `nombre_especialidad` dependería de `id_especialidad` y `id_especialidad` dependería de `id_dentista`, generando una dependencia transitiva. Al separar `Especialidad` y enlazar con `Dentista_Especialidad`, esa cadena se rompe.
- En `Cita`, los atributos `fecha`, `hora`, `motivo` y `estado` dependen del `id_cita`. Las llaves foráneas (`id_paciente`, `id_dentista`, `id_consultorio`) sí dependen del `id_cita` pero apuntan a sus respectivas tablas para obtener el resto de los datos. No se duplica el nombre del paciente ni el del dentista en `Cita`.
- En `Pago`, los atributos `fecha_pago`, `monto` y `metodo_pago` dependen de `id_pago`. La cita asociada se obtiene siguiendo `id_cita` hasta `Cita`, no se vuelve a almacenar el monto total ni el saldo en `Pago`.
- `Tratamiento` guarda `costo_base` como un valor base del catálogo. Cuando un tratamiento se aplica en una cita, su costo final se guarda como `costo_aplicado` en `Cita_Tratamiento`, no en `Tratamiento`. Esto permite ajustar el precio por cita sin modificar el catálogo.

## Atributos calculados que no se almacenan

Un punto importante para mantener el diseño en 3FN: el saldo pendiente de una cita no se guarda en `Cita`. Almacenarlo crearía redundancia (depende de los pagos y de los tratamientos asociados, que son atributos de otras tablas). En la Fase 5 se implementa una función `fn_SaldoPendiente(id_cita)` que lo calcula sobre la marcha.

## Resumen

| Tabla | 1FN | 2FN | 3FN |
|---|---|---|---|
| Paciente | Cumple | Cumple (clave simple) | Cumple |
| Dentista | Cumple | Cumple (clave simple) | Cumple |
| Especialidad | Cumple | Cumple (clave simple) | Cumple |
| Dentista_Especialidad | Cumple | Cumple (sin no primos) | Cumple |
| Consultorio | Cumple | Cumple (clave simple) | Cumple |
| Cita | Cumple | Cumple (clave simple) | Cumple |
| Tratamiento | Cumple | Cumple (clave simple) | Cumple |
| Cita_Tratamiento | Cumple | Cumple (no primos dependen de la clave completa) | Cumple |
| Pago | Cumple | Cumple (clave simple) | Cumple |

El diseño está en 3FN.
