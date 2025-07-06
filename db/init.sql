CREATE TABLE IF NOT EXISTS ping_results (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
    host TEXT NOT NULL,
    rtt_ms REAL,
    packet_loss REAL
);

CREATE TABLE IF NOT EXISTS http_results (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
    host TEXT NOT NULL,
    response_time_ms REAL,
    status_code INT
);
