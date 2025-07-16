CREATE SCHEMA IF NOT EXISTS shop;

CREATE TABLE IF NOT EXISTS shop.users (
    -- using instead of BIGINT to avoid collisions in the distributed systems
    -- b-tree index
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- unique, b-tree index
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    -- binary JSON representation for better indexing and queries
    settings JSONB DEFAULT '{}' -- user preferences
);

CREATE INDEX IF NOT EXISTS idx_users_settings ON shop.users USING gin (settings);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON shop.users (created_at);

CREATE TABLE IF NOT EXISTS shop.products (
    -- b-tree index
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    category TEXT,
    -- precise number used for finances
    price NUMERIC(10,2) NOT NULL,
    stock_quantity INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_products_price ON shop.products (price);
CREATE INDEX IF NOT EXISTS idx_products_stock_quantity ON shop.products (stock_quantity);
CREATE INDEX IF NOT EXISTS idx_products_is_active ON shop.products (is_active);
CREATE INDEX IF NOT EXISTS idx_products_category ON shop.products (category);
CREATE INDEX IF NOT EXISTS idx_products_created_at ON shop.products (created_at);

CREATE TABLE IF NOT EXISTS shop.orders (
    -- if not specified, the database generates random uuid
    -- uuid type optimised for UUIDs
    -- b-tree index
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES shop.users(id) ON DELETE CASCADE,
    -- text field with validation (alternative to ENUM)
    status TEXT CHECK (status IN ('pending', 'paid', 'shipped', 'cancelled')),
    -- precise data, recommended for money
    total NUMERIC(10,2),
    -- if not specified, the database sets current timestamp
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_orders_user_id ON shop.orders (user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON shop.orders (status);
CREATE INDEX IF NOT EXISTS idx_orders_total ON shop.orders (total);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON shop.orders (created_at);

CREATE TABLE IF NOT EXISTS shop.order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES shop.orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES shop.products(id),
    quantity INT NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON shop.order_items (order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON shop.order_items (product_id);
CREATE INDEX IF NOT EXISTS idx_order_items_quantity ON shop.order_items (quantity);
CREATE INDEX IF NOT EXISTS idx_order_items_unit_price ON shop.order_items (unit_price);

CREATE TABLE IF NOT EXISTS shop.reviews (
    -- b-tree index
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES shop.users(id) ON DELETE CASCADE,
    product_id UUID REFERENCES shop.products(id) ON DELETE CASCADE,
    -- constraint, validation
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    -- constraint and index so that combination of the fields must be unique
    UNIQUE (user_id, product_id)
);

CREATE INDEX IF NOT EXISTS idx_reviews_product_id ON shop.reviews (product_id);
CREATE INDEX IF NOT EXISTS idx_reviews_rating ON shop.reviews (rating);
CREATE INDEX IF NOT EXISTS idx_reviews_created_at ON shop.reviews (created_at);

CREATE TABLE IF NOT EXISTS shop.audit_log (
    -- b-tree index, auto increment primary key, sequence is created
    -- can be shared sequence across  multiple tables
    id SERIAL PRIMARY KEY,
    entity TEXT,
    entity_id UUID,
    action TEXT,
    data JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audit_log_created_at ON shop.audit_log (created_at);
CREATE INDEX IF NOT EXISTS idx_audit_log_entity_id ON shop.audit_log (entity_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_settings ON shop.audit_log USING gin (data);