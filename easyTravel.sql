-- =========================
-- ROLES & USERS
-- =========================

CREATE TABLE role (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE "user" (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role_id INT NOT NULL,
    CONSTRAINT fk_user_role
        FOREIGN KEY (role_id) REFERENCES role(role_id)
);

-- =========================
-- CUSTOMER
-- =========================

CREATE TABLE customer (
    customer_id SERIAL PRIMARY KEY,
    user_id INT UNIQUE NOT NULL,
    loyalty_member BOOLEAN DEFAULT FALSE,
    loyalty_points INT DEFAULT 0,
    preferences TEXT,
    CONSTRAINT fk_customer_user
        FOREIGN KEY (user_id) REFERENCES "user"(user_id)
);

-- =========================
-- CORE BOOKING
-- =========================

CREATE TABLE booking (
    booking_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    booking_date DATE NOT NULL,
    status VARCHAR(30) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_booking_user
        FOREIGN KEY (user_id) REFERENCES "user"(user_id)
);

-- =========================
-- AIRLINE & FLIGHT
-- =========================

CREATE TABLE airline (
    airline_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE flight (
    flight_id SERIAL PRIMARY KEY,
    airline_id INT NOT NULL,
    origin VARCHAR(50),
    destination VARCHAR(50),
    seat_class VARCHAR(20),
    capacity INT,
    price DECIMAL(10,2),
    CONSTRAINT fk_flight_airline
        FOREIGN KEY (airline_id) REFERENCES airline(airline_id)
);

-- =========================
-- ACCOMMODATION
-- =========================

CREATE TABLE accommodation (
    accommodation_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    room_type VARCHAR(50),
    price_per_night DECIMAL(10,2),
    season VARCHAR(30)
);

-- =========================
-- OPTIONAL SERVICES
-- =========================

CREATE TABLE service (
    service_id SERIAL PRIMARY KEY,
    service_name VARCHAR(100),
    price DECIMAL(10,2)
);

-- =========================
-- PAYMENT
-- =========================

CREATE TABLE payment (
    payment_id SERIAL PRIMARY KEY,
    booking_id INT UNIQUE NOT NULL,
    payment_method VARCHAR(50),
    amount DECIMAL(10,2),
    payment_status VARCHAR(30),
    CONSTRAINT fk_payment_booking
        FOREIGN KEY (booking_id) REFERENCES booking(booking_id)
);

-- =========================
-- PROMOTION
-- =========================

CREATE TABLE promotion (
    promo_id SERIAL PRIMARY KEY,
    promo_name VARCHAR(100),
    discount_percent DECIMAL(5,2),
    loyalty_only BOOLEAN
);

-- =========================
-- FEEDBACK
-- =========================

CREATE TABLE feedback (
    feedback_id SERIAL PRIMARY KEY,
    booking_id INT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    CONSTRAINT fk_feedback_booking
        FOREIGN KEY (booking_id) REFERENCES booking(booking_id)
);

-- =========================
-- JUNCTION TABLES
-- =========================

CREATE TABLE booking_flight (
    booking_id INT,
    flight_id INT,
    PRIMARY KEY (booking_id, flight_id),
    FOREIGN KEY (booking_id) REFERENCES booking(booking_id),
    FOREIGN KEY (flight_id) REFERENCES flight(flight_id)
);

CREATE TABLE booking_accommodation (
    booking_id INT,
    accommodation_id INT,
    PRIMARY KEY (booking_id, accommodation_id),
    FOREIGN KEY (booking_id) REFERENCES booking(booking_id),
    FOREIGN KEY (accommodation_id) REFERENCES accommodation(accommodation_id)
);

CREATE TABLE booking_service (
    booking_id INT,
    service_id INT,
    PRIMARY KEY (booking_id, service_id),
    FOREIGN KEY (booking_id) REFERENCES booking(booking_id),
    FOREIGN KEY (service_id) REFERENCES service(service_id)
);





-- =========================
-- ROLES
-- =========================

INSERT INTO role (role_name) VALUES
('ADMIN'),
('TRAVEL_AGENT'),
('CUSTOMER');

-- =========================
-- USERS
-- =========================

INSERT INTO "user" (email, password_hash, role_id) VALUES
('admin@easytravel.com', 'hash1', 1),
('agent1@easytravel.com', 'hash2', 2),
('agent2@easytravel.com', 'hash3', 2),
('customer1@mail.com', 'hash4', 3),
('customer2@mail.com', 'hash5', 3);

-- =========================
-- CUSTOMERS
-- =========================

INSERT INTO customer (user_id, loyalty_member, loyalty_points, preferences) VALUES
(4, true, 500, 'Beach, Business class'),
(5, false, 0, 'City breaks');

-- =========================
-- AIRLINES
-- =========================

INSERT INTO airline (name) VALUES
('Air France'),
('Lufthansa'),
('Emirates');

-- =========================
-- FLIGHTS
-- =========================

INSERT INTO flight (airline_id, origin, destination, seat_class, capacity, price) VALUES
(1, 'Paris', 'Rome', 'Economy', 180, 120),
(1, 'Paris', 'Rome', 'Business', 40, 350),
(2, 'Berlin', 'London', 'Economy', 200, 100),
(3, 'Dubai', 'Tokyo', 'First', 20, 1200);

-- =========================
-- ACCOMMODATIONS
-- =========================

INSERT INTO accommodation (name, room_type, price_per_night, season) VALUES
('Hilton Rome', 'Double', 150, 'Summer'),
('City Hotel London', 'Single', 90, 'All'),
('Mountain Resort', 'Suite', 220, 'Winter');

-- =========================
-- SERVICES
-- =========================

INSERT INTO service (service_name, price) VALUES
('Extra Baggage', 50),
('Airport Taxi', 40),
('Guided Tour', 80);

-- =========================
-- BOOKINGS
-- =========================

INSERT INTO booking (user_id, booking_date, status, total_price) VALUES
(4, CURRENT_DATE, 'CONFIRMED', 520),
(5, CURRENT_DATE, 'CONFIRMED', 230);

-- =========================
-- PAYMENTS
-- =========================

INSERT INTO payment (booking_id, payment_method, amount, payment_status) VALUES
(1, 'CREDIT_CARD', 520, 'PAID'),
(2, 'BANK_TRANSFER', 230, 'PAID');

-- =========================
-- BOOKING DETAILS
-- =========================

INSERT INTO booking_flight VALUES
(1, 1),
(2, 3);

INSERT INTO booking_accommodation VALUES
(1, 1),
(2, 2);

INSERT INTO booking_service VALUES
(1, 1),
(1, 2),
(2, 3);

-- =========================
-- PROMOTIONS
-- =========================

INSERT INTO promotion (promo_name, discount_percent, loyalty_only) VALUES
('Summer Deal', 10, false),
('Loyalty Exclusive', 20, true);

-- =========================
-- FEEDBACK
-- =========================

INSERT INTO feedback (booking_id, rating, comment) VALUES
(1, 5, 'Excellent trip!'),
(2, 4, 'Good experience overall');




-- Create roles
CREATE ROLE admin;
CREATE ROLE agent;
CREATE ROLE customer;

-- Grant all privileges to admin
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin;

-- Grant specific privileges to agent
GRANT SELECT ON ALL TABLES IN SCHEMA public TO agent;
GRANT INSERT, UPDATE ON booking, payment TO agent;
GRANT INSERT ON booking_flight, booking_accommodation, booking_service TO agent;

-- Grant select privileges to customer
GRANT SELECT ON flight, airline, accommodation, service, promotion TO customer;
GRANT SELECT, INSERT ON booking TO customer;
GRANT SELECT ON booking_flight, booking_accommodation, booking_service TO customer;

-- Create users and assign roles
CREATE USER admin_user WITH PASSWORD 'admin_pass';
CREATE USER agent_user WITH PASSWORD 'agent_pass';
CREATE USER customer_user WITH PASSWORD 'customer_pass';

GRANT admin TO admin_user;
GRANT agent TO agent_user;
GRANT customer TO customer_user;



ROLLBACK; -- Run this first just in case!

BEGIN;

WITH inserted_booking AS (
    INSERT INTO booking (user_id, booking_date, status, total_price)
    VALUES (5, CURRENT_DATE, 'CONFIRMED', 270)
    RETURNING booking_id, user_id
),
ins_flight AS (
    INSERT INTO booking_flight (booking_id, flight_id)
    SELECT booking_id, 3 FROM inserted_booking
),
ins_acc AS (
    INSERT INTO booking_accommodation (booking_id, accommodation_id)
    SELECT booking_id, 2 FROM inserted_booking
),
ins_pay AS (
    INSERT INTO payment (booking_id, payment_method, amount, payment_status)
    SELECT booking_id, 'CREDIT_CARD', 270, 'PAID' FROM inserted_booking
)
UPDATE customer 
SET loyalty_points = loyalty_points + 27
WHERE user_id = (SELECT user_id FROM inserted_booking);

COMMIT;


SELECT 
    COUNT(booking_id) AS total_bookings,
    SUM(total_price) AS total_revenue,
    AVG(total_price) AS average_order_value,
    COUNT(DISTINCT user_id) AS active_customers
FROM booking
WHERE status = 'CONFIRMED';


SELECT 
    a.name AS airline_name,
    f.origin,
    f.destination,
    COUNT(bf.booking_id) AS tickets_sold,
    SUM(f.price) AS flight_revenue
FROM airline a
JOIN flight f ON a.airline_id = f.airline_id
JOIN booking_flight bf ON f.flight_id = bf.flight_id
GROUP BY a.name, f.origin, f.destination
ORDER BY tickets_sold DESC;





