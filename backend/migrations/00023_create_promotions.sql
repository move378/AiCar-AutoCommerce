-- +goose Up
CREATE TABLE promotions (
    id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    trim_id          UUID        NOT NULL REFERENCES vehicles_trims(id) ON DELETE CASCADE,
    purchase_method  VARCHAR(20) NOT NULL CHECK (purchase_method IN ('CASH', 'FINANCE')),
    discount_amount  BIGINT      NOT NULL,
    start_date       DATE        NOT NULL,
    end_date         DATE        NOT NULL,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_promotions_date_range CHECK (end_date >= start_date)
);

CREATE INDEX idx_promotions_trim_id ON promotions(trim_id);

-- +goose Down
DROP TABLE promotions;
