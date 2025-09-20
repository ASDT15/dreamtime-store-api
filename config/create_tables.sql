-- جدول المنتجات
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    description TEXT,
    main_image_url TEXT, -- رابط الصورة الرئيسية
    type VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    -- لا تضع ALTER TABLE هنا
);

-- تعديل جدول المنتجات لإضافة أعمدة المقاسات (أمر منفصل)
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS size_type VARCHAR(50) DEFAULT 'default',
ADD COLUMN IF NOT EXISTS available_sizes JSONB DEFAULT '[]';

-- جدول الصور الإضافية للمنتجات
CREATE TABLE IF NOT EXISTS product_images (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    is_main BOOLEAN DEFAULT FALSE -- لتحديد الصورة الرئيسية إن لزم
);

-- جدول الفيديوهات للمنتجات
CREATE TABLE IF NOT EXISTS product_videos (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    video_url TEXT NOT NULL
);

-- *** إضافة هذا السطر لحذف الجدول إذا كان موجودًا ***
-- (من الأفضل توخي الحذر مع DROP TABLE في بيئة الإنتاج)
-- DROP TABLE IF EXISTS order_items; -- حذف الجدول المرتبط أولاً
-- DROP TABLE IF EXISTS orders; -- ثم حذف الجدول الرئيسي

-- جدول الطلبات الرئيسي
CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    order_id VARCHAR(50) UNIQUE NOT NULL,
    customer_name VARCHAR(255),
    customer_phone VARCHAR(20),
    -- التأكد من أن العمود موجود --
    payment_method VARCHAR(50),
    -- -------------------------- --
    total_amount DECIMAL(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'pending'
    -- باقي الأعمدة...
);
-- تأكد من أن تعريفات الجداول الأخرى (مثل order_items) تأتي بعدها

-- جدول عناصر الطلب (المنتجات داخل كل طلب)
CREATE TABLE IF NOT EXISTS order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER NOT NULL,
    size VARCHAR(50),
    location VARCHAR(255)
    -- لا تضع ALTER TABLE هنا أيضًا
);

-- تعديل جدول order_items إذا لزم (أمر منفصل)
-- (هذا الخط غير ضروري إلا إذا كنت بحاجة لإضافة أعمدة جديدة له هنا)
-- ALTER TABLE order_items 
-- ADD COLUMN IF NOT EXISTS ... ;