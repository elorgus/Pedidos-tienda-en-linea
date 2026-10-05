# App 4 — Pedidos tienda online

Sistema para una tienda que vende por web y redes sociales. Controla el pedido desde que se confirma hasta que se despacha, con reserva de inventario y pago asincrónico.

## 📑 Entregable

| Sección | Enlace |
|---|---|
| Objetivo, actores y alcance | [§1](#1-objetivo-actores-y-alcance) |
| Requisitos funcionales y de calidad | [§2](#2-requisitos) |
| Diagrama C4 contexto | [docs/c4-contexto.mmd](docs/c4-contexto.mmd) |
| Diagrama C4 contenedores | [docs/c4-contenedores.mmd](docs/c4-contenedores.mmd) |
| Flujo de operación crítica | [docs/flujo-critico.mmd](docs/flujo-critico.mmd) |
| Stack con justificación | [§3](#3-stack-propuesto) |
| ADRs | [ADR-001](docs/adr-001-arquitectonico.md), [ADR-002](docs/adr-002-tecnologico.md) |
| Riesgos | [docs/riesgos.md](docs/riesgos.md) |
| Métricas | [docs/metricas.md](docs/metricas.md) |

---

## 1. Objetivo, actores y alcance

### Objetivo
Gestionar el ciclo completo de un pedido: desde que el cliente confirma la compra hasta que se despacha, incluyendo reserva de inventario, pago y notificaciones.

### Actores
- **Cliente** — compra desde web y redes sociales.
- **Operador de tienda** — prepara y despacha pedidos.
- **Pasarela de pago** (externa) — autoriza tarjetas.
- **Proveedor de envío** (externo) — entrega a domicilio.
- **Proveedor de notificaciones** — informa al cliente.

### Alcance
**Dentro:**
- Carrito de compras con cálculo de total.
- Reserva de inventario con TTL.
- Pago asincrónico.
- Cancelación y compensación.
- Estados del pedido.

**Fuera:**
- Facturación electrónica.
- Logística de última milla.
- Recomendaciones con ML.

---

## 2. Requisitos

### Funcionales
| ID | Requisito |
|---|---|
| RF-01 | Listar productos con stock disponible |
| RF-02 | Crear pedido con `Idempotency-Key` |
| RF-03 | Reservar stock de forma atómica (todas las líneas o ninguna) |
| RF-04 | TTL de 15 min en la reserva |
| RF-05 | Publicar evento `pedido.creado` a RabbitMQ |
| RF-06 | Consumer procesa pago y confirma stock |
| RF-07 | Si el pago falla, liberar reserva y cancelar pedido |
| RF-08 | Job cada 1 min libera reservas expiradas |
| RF-09 | Endpoints para cancelar pedido |

### De calidad
| ID | Requisito |
|---|---|
| RNF-01 | Health check `/actuator/health` |
| RNF-02 | Latencia p95 de `POST /pedidos` menor a 800 ms |
| RNF-03 | Frontend responsive con catálogo y carrito |
| RNF-04 | Docker Compose multi-servicio reproducible |
| RNF-05 | Constraints en BD que previenen sobreventa |

---

## 3. Stack propuesto

| Capa | Tecnología | Justificación |
|---|---|---|
| Backend | Node.js 20 + Express | Rápido, mismo lenguaje que frontend |
| BD | PostgreSQL 16 | Transaccional, CHECK constraints |
| Driver BD | `pg` (node-postgres) | Oficial, pool, transacciones explícitas |
| Mensajería | RabbitMQ 3.13 | Colas durables, DLQ |
| Cliente AMQP | `amqplib` | Estándar, soporte de DLQ |
| Job | `setInterval` | Cada 1 min libera reservas |
| Frontend | HTML/CSS/JS vanilla | Demo funcional |
| Contenedores | Docker + Compose | Multi-servicio reproducible |

Detalle completo en [ADR-002](docs/adr-002-tecnologico.md).

---

## 4. Ejecución rápida

```bash
docker compose up -d --build
# http://localhost:3000
