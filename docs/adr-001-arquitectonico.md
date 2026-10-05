# ADR-001: Monolito modular con eventos y compensacion

## Estado
Aceptada

## Contexto
La tienda vende por web y redes sociales. El pedido pasa por varios estados:
PENDIENTE -> PAGADO -> PREPARANDO -> DESPACHADO -> ENTREGADO (o CANCELADO).
El pago se procesa con una pasarela externa que puede fallar.
El inventario no puede quedar reservado indefinidamente si el pago no se completa.

Preguntas clave del enunciado:
- Cuando se reserva el inventario?
- Que pasa si el pago se aprueba pero falla la reserva?
- Que operaciones son idempotentes?

## Decision
Arquitectura de **monolito modular con eventos y compensacion**:

1. **Reserva de inventario al crear el pedido** (estado PENDIENTE) con TTL de 15 min.
   Se hace en una transaccion atomica: o se reservan todas las lineas, o ninguna.
2. **Pago asincrono** via RabbitMQ. El consumer llama a la pasarela.
3. **Compensacion:** si el pago es rechazado, se libera la reserva y el pedido se marca CANCELADO.
4. **Job de expiracion:** cada 1 min libera reservas expiradas y cancela pedidos huerfanos.
5. **Idempotencia** con `Idempotency-Key` en el POST y constraint UNIQUE en BD.

Modulos internos:
- Clientes
- Productos / inventario
- Pedidos
- Pagos (pasarela)
- Notificaciones

## Consecuencias
**Positivas:**
- Imposible sobreventa: el stock reservado se descuenta del disponible.
- El cliente no espera al pago (recibe 201 inmediato).
- Los pedidos huerfanos se liberan automaticamente.
- Idempotencia garantizada.

**Negativas:**
- Estado intermedio PENDIENTE requiere monitoreo.
- El consumer debe ser idempotente (verificar estado antes de procesar).
- El patron saga esta simplificado (no hay orquestador).

**Mitigaciones:**
- Job de liberacion cada 1 min.
- Check `estado === 'PENDIENTE'` antes de procesar pago.
- Logs estructurados y DLQ.
