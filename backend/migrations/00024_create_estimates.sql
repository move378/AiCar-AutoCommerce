-- +goose Up
-- 의존 순서: 00022_create_chat → 00023_create_promotions → 00024_create_estimates
CREATE TABLE estimates (
    id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id          UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    trim_id          UUID        NOT NULL REFERENCES vehicles_trims(id),
    promotion_id     UUID        REFERENCES promotions(id),
    chat_session_id  UUID        NOT NULL REFERENCES chat_sessions(id),
    base_price       BIGINT      NOT NULL,
    discount_amount  BIGINT      NOT NULL DEFAULT 0,
    final_price      BIGINT      NOT NULL,
    status           VARCHAR(20) NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'confirmed', 'expired')),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_estimates_user_id ON estimates(user_id);
CREATE INDEX idx_estimates_chat_session_id ON estimates(chat_session_id);

-- +goose Down
DROP TABLE estimates;
