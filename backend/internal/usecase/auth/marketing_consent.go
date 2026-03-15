package auth

import (
	"context"
	"errors"
	"time"

	"backend/internal/domain/entity"
	"backend/internal/domain/repository"
)

type MarketingConsentUsecase interface {
	SaveMarketingConsent(ctx context.Context, deviceID string, marketingAgreed bool) error
}

type marketingConsentUsecase struct {
	marketingConsentRepo repository.MarketingConsentRepository
}

func NewMarketingConsentUsecase(
	marketingConsentRepo repository.MarketingConsentRepository,
) MarketingConsentUsecase {
	return &marketingConsentUsecase{
		marketingConsentRepo: marketingConsentRepo,
	}
}

func (u *marketingConsentUsecase) SaveMarketingConsent(
	ctx context.Context,
	deviceID string,
	marketingAgreed bool,
) error {
	if deviceID == "" {
		return errors.New("device_id is required")
	}

	now := time.Now()

	existing, err := u.marketingConsentRepo.FindByDeviceID(ctx, deviceID)
	if err != nil {
		return err
	}

	if existing == nil {
		consent := &entity.MarketingConsent{
			DeviceID:        deviceID,
			MarketingAgreed: marketingAgreed,
			AgreedAt:        now,
			CreatedAt:       now,
			UpdatedAt:       now,
		}

		return u.marketingConsentRepo.Create(ctx, consent)
	}

	existing.MarketingAgreed = marketingAgreed
	existing.AgreedAt = now
	existing.UpdatedAt = now

	return u.marketingConsentRepo.Update(ctx, existing)
}
