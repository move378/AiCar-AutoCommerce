-- public.tokens definition

-- Drop table

-- DROP TABLE public.tokens;

CREATE TABLE public.tokens (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	user_id uuid NOT NULL,
	"token" text NOT NULL,
	expires_at timestamptz NOT NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id)
);


-- public.tokens foreign keys

ALTER TABLE public.tokens ADD CONSTRAINT fk_user_tokens FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;