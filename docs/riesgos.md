# Riesgos y mitigaciones

| # | Riesgo | Impacto | Probabilidad | Mitigacion |
|---|---|---|---|---|
| R1 | Sobreventa por reserva no atomica | Critico | Media | UPDATE ... WHERE disponible >= N + CHECK constraints + transaccion BEGIN/COMMIT |
| R2 | Pedido huerfano (pago nunca llega, reserva retenida) | Alto | Media | TTL de 15 min en reserva + job cada 1 min que libera reservas expiradas |
| R3 | Doble procesamiento del evento `pedido.creado` | Alto | Media | Consumer verifica estado del pedido antes de procesar; solo procesa si esta en PENDIENTE |

## Detalle R1 - Sobreventa
**Mitigacion:** Reserva dentro de una transaccion. Se usa `UPDATE productos SET stock_reservado = stock_reservado + N WHERE id = X AND (stock - stock_reservado) >= N`. Si `rowCount === 0`, no hay stock y se hace ROLLBACK. Los CHECK constraints en BD (`stock_reservado <= stock`, `stock >= 0`) previenen corrupcion.

## Detalle R2 - Pedido huerfano
**Mitigacion:** Al crear el pedido se setea `reserva_expira_en = now + 15 min`. Un job `setInterval` cada 1 min busca pedidos PENDIENTE con reserva vencida, libera el stock y los marca CANCELADO. Asi el inventario nunca queda retenido mas de 15 min.

## Detalle R3 - Doble procesamiento
**Mitigacion:** El consumer verifica el estado del pedido antes de llamar a la pasarela. Si `estado !== 'PENDIENTE'`, ignora el evento. Esto cubre reintentos de RabbitMQ y duplicados.
