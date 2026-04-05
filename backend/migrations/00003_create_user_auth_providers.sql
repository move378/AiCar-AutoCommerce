-- +goose Up
-- +goose StatementBegin

-- users 테이블에서 oauth 컬럼 제거
ALTER TABLE public.users
    DROP COLUMN IF EXISTS oauth_type,
    DROP COLUMN IF EXISTS oauth_id;

-- user_auth_providers 테이블 생성
CREATE TABLE public.user_auth_providers (
    id          uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id     uuid NOT NULL,
    provider    varchar(20) NOT NULL,   -- kakao, google, apple, phone
    provider_id varchar(255) NOT NULL,
    created_at  timestamptz DEFAULT CURRENT_TIMESTAMP NULL,

    CONSTRAINT user_auth_providers_pkey PRIMARY KEY (id),
    CONSTRAINT user_auth_providers_user_id_fkey
        FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE,
    CONSTRAINT user_auth_providers_provider_unique
        UNIQUE (provider, provider_id)   -- 같은 SNS 계정 중복 가입 방지
);

CREATE INDEX IF NOT EXISTS idx_auth_providers_user_id
    ON public.user_auth_providers(user_id);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

DROP INDEX IF EXISTS idx_auth_providers_user_id;
DROP TABLE IF EXISTS public.user_auth_providers;

ALTER TABLE public.users
    ADD COLUMN IF NOT EXISTS oauth_type varchar(20) NULL,
    ADD COLUMN IF NOT EXISTS oauth_id   varchar(255) NULL;

-- +goose StatementEnd