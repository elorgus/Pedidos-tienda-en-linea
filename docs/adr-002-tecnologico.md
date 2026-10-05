# ADR-002: Stack Node.js + Express + PostgreSQL + RabbitMQ

## Estado
Aceptada

## Contexto
El enunciado permite Node.js o Spring Boot para esta app. La tienda necesita:
- API REST rapida para carrito y pedidos.
- Persistencia transaccional con constraints.
- Mensajeria con reintentos y DLQ.
- Jobs programados (liberacion de reservas).
- Idempotencia.

## Decision
- **Node.js 20 + Express**: rapido, ideal para APIs REST, JS en frontend y backend.
- **pg (node-postgres)**: driver oficial, conexion pooling.
- **PostgreSQL 16**: constraints UNIQUE, CHECK, transacciones.
- **amqplib**: cliente AMQP con soporte de DLQ.
- **setInterval**: job cada 1 min para liberar reservas expiradas.
- **HTML/JS vanilla**: demo sin build step.
- **Docker Compose**: stack reproducible.

## Consecuencias
**Positivas:**
- Mismo lenguaje (JS) en frontend y backend.
- Arranque rapido, menos huella de memoria que Spring Boot.
- Node permite usar `Promise.all` para concurrencia de forma natural.

**Negativas:**
- Menos tipado fuerte en dominio transaccional (mitigado con constraints en BD).
- Sin Actuator, health check es simple (`{status: 'UP'}`).
- Manejo de transacciones mas manual (BEGIN/COMMIT explicito).

**Alternativas consideradas:**
- Spring Boot: descartado para esta app para demostrar versatilidad del stack.
- NestJS: overkill para la demo.
- TypeORM/Sequelize: descartados por preferir SQL explicito y control fino de locks.
