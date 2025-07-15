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

CREATE TABLE shop.orders (
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

CREATE TABLE IF NOT EXISTS shop.order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES shop.orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES shop.products(id),
    quantity INT NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL
);

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
