// server.js
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const db = require('./db'); // كائن db مع initializeTables
const WebSocket = require('ws');

const app = express();
const port = process.env.PORT || 10000;

// Middleware
app.use(cors());
app.use(express.json({ limit: '10mb' }));

// مسارات API
app.use('/api/products', require('./routes/products'));
app.use('/api/orders', require('./routes/orders'));

// مسار اختبار
app.get('/', (req, res) => {
    res.send('Dream Time Store Backend API is running...');
});

// إعداد WebSocket
const wss = new WebSocket.Server({ noServer: true });

// دالة لإرسال التحديثات لجميع العملاء
const broadcast = (data) => {
    wss.clients.forEach(client => {
        if (client.readyState === WebSocket.OPEN) {
            client.send(JSON.stringify(data));
        }
    });
};

// تعديل مسارات المنتجات لتدعم WebSocket
// مثال: يمكن تعديل route /api/products POST و DELETE لإرسال إشعارات WebSocket
// لاحقًا يمكن عمل هذا مباشرة داخل ملفات routes/products.js عند إضافة أو حذف منتج

// بدء تشغيل الخادم بعد التأكد من الجداول
const startServer = async () => {
    try {
        // تهيئة الجداول
        await db.initializeTables();

        // بدء الاستماع
        const server = app.listen(port, '0.0.0.0', () => {
            console.log(`✅ الخادم يعمل على المنفذ ${port}`);
            console.log(`      ==> خدمتك متاحة الآن 🎉`);
            console.log(`     ==> متوفر على عنوان URL الأساسي الخاص بك https://dreamtime-store-api.onrender.com`);
            console.log(`     ==> ///////////////////////////////////////////////////////////`);
        });

        // ربط WebSocket بالخادم
        server.on('upgrade', (request, socket, head) => {
            wss.handleUpgrade(request, socket, head, ws => {
                wss.emit('connection', ws, request);
            });
        });

        console.log('✅ WebSocket Server جاهز للاتصالات الفورية');
    } catch (error) {
        console.error("❌ فشل في بدء تشغيل الخادم:", error.message);
        process.exit(1);
    }
};
const { wss } = require('./ws');

server.on('upgrade', (request, socket, head) => {
    wss.handleUpgrade(request, socket, head, ws => {
        wss.emit('connection', ws, request);
    });
});

startServer();

// تصدير broadcast لاستخدامه داخل routes/products.js
module.exports = { broadcast };
