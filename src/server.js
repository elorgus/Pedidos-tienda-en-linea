const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = process.env.APP_PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

app.get('/api/v1/info', (req, res) => {
    res.json({
        app: 'pedidos-tienda-online',
        status: 'running',
        message: 'Sistema de pedidos tienda en línea',
        timestamp: new Date().toISOString()
    });
});

app.get('/actuator/health', (req, res) => {
    res.json({ status: 'UP' });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Servidor escuchando en puerto ${PORT}`);
});
