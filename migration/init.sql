-- Customer Orders Table
CREATE TABLE customer_orders (
    order_id INT PRIMARY KEY,
    user_id INT,
    order_date DATE,
    total_amount DECIMAL(10, 2),
    status VARCHAR(20)
);

-- Product Stock Table
CREATE TABLE product_stock (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    available_quantity INT,
    price DECIMAL(8, 2)
);