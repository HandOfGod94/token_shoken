CREATE TABLE IF NOT EXISTS "schema_migrations" (version varchar(128) primary key);
CREATE TABLE users (
	id INTEGER PRIMARY KEY,
	email VARCHAR(255) UNIQUE NOT NULL,
	username VARCHAR(255) UNIQUE,
	name VARCHAR(255),
	password TEXT,
	is_active BOOLEAN DEFAULT FALSE,
	is_verified BOOLEAN DEFAULT FALSE,
	created_at INTEGER NOT NULL DEFAULT (unixepoch()),
	updated_at INTEGER
);
-- Dbmate schema migrations
INSERT INTO "schema_migrations" (version) VALUES
  ('20250116201934');
