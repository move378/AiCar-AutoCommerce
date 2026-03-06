-- +goose Up
-- +goose StatementBegin
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- +goose StatementEnd

CREATE TABLE public.users (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	"name" varchar(100) NULL,
	gender varchar(10) NULL,
	birth date NULL,
	"location" text NULL,
	oauth_type varchar(20) NULL,
	oauth_id varchar(255) NULL,
	email varchar(255) NULL,
	profile_url text NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	deleted_at timestamptz NULL,
	CONSTRAINT users_email_key UNIQUE (email),
	CONSTRAINT users_pkey PRIMARY KEY (id)
);

CREATE TRIGGER update_users_modtime
	BEFORE UPDATE ON public.users
	FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE INDEX IF NOT EXISTS idx_users_deleted_at ON public.users(deleted_at);

-- +goose Down
DROP TRIGGER IF EXISTS update_users_modtime ON public.users;
DROP INDEX IF EXISTS idx_users_deleted_at;
DROP TABLE IF EXISTS public.users;
DROP FUNCTION IF EXISTS update_timestamp();