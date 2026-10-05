# Metricas

## Metrica de negocio
**Tasa de pedidos completados**

- Definicion: pedidos en estado ENTREGADO / pedidos creados.
- Objetivo: mayor a 90%.
- Fuente: tabla `pedidos`.
- Accion: si baja, investigar causas (pago, stock, cancelaciones).

## Metrica de negocio (secundaria)
**Valor promedio del pedido (ticket promedio)**

- Definicion: SUM(total) / COUNT(pedidos pagados).
- Objetivo: depende del negocio; monitorear tendencia.
- Fuente: tabla `pedidos`.
- Accion: si baja, revisar catalogo, precios, promociones.

## Metrica tecnica
**Tasa de reservas expiradas**

- Definicion: pedidos cancelados por expiracion de reserva / total de pedidos.
- Objetivo: menor a 5%.
- Fuente: tabla `pedidos` filtrando por motivo_cancelacion = 'Reserva de inventario expirada'.
- Accion: si supera, la pasarela de pago es lenta o hay problemas en el consumer.

## Metrica tecnica (secundaria)
**Latencia p95 de POST /api/v1/pedidos**

- Definicion: percentil 95 del tiempo de respuesta del endpoint de creacion.
- Objetivo: menor a 800 ms (incluye reserva de stock transaccional).
- Fuente: logs + middleware de timing.
- Accion: si supera, revisar indices en productos y pedidos.
