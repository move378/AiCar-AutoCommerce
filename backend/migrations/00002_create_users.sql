-- public.users definition

-- Drop table

-- DROP TABLE public.users;

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
    deleted_at timestamptz NULL;
	CONSTRAINT users_email_key UNIQUE (email),
	CONSTRAINT users_pkey PRIMARY KEY (id)
);

-- Table Triggers

create trigger update_users_modtime before
update
    on
    public.users for each row execute function update_timestamp();

CREATE INDEX IF NOT EXISTS idx_users_deleted_at ON public.users(deleted_at);