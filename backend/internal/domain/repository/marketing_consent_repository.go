package repository

import (
	"backend/internal/domain/entity"
	"context"
)

type MarketingConsentRepository interface {
	FindByDeviceID(ctx context.Context, deviceID string) (*entity.MarketingConsent, error)
	Create(ctx context.Context, consent *entity.MarketingConsent) error
	Update(ctx context.Context, consent *entity.MarketingConsent) error
}
