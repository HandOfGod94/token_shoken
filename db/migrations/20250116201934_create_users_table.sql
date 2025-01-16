-- migrate:up
CREATE TABLE users (
	id INTEGER PRIMARY KEY,
	email VARCHAR(255) UNIQUE NOT NULL,
	username VARCHAR(255) UNIQUE,
	name VARCHAR(255),
	password TEXT,
	is_active BOOLEAN DEFAULT FALSE,
	is_verified BOOLEAN DEFAULT FALSE,
	created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at timestamp
);

-- migrate:down
DROP TABLE users;