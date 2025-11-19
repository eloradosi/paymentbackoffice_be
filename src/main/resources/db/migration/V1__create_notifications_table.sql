CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    receiver VARCHAR(255) NOT NULL,
    time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) NOT NULL,
    channel VARCHAR(100),
    message TEXT
);
