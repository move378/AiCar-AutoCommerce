package postgres

import (
	"context"
	"errors"

	"backend/internal/domain/entity"
	domainRepo "backend/internal/domain/repository"

	"gorm.io/gorm"
)

type marketingConsentRepo struct {
	db *DB
}

func NewMarketingConsentRepo(db *DB) domainRepo.MarketingConsentRepository {
	return &marketingConsentRepo{db: db}
}

func (r *marketingConsentRepo) FindByDeviceID(
	ctx context.Context,
	deviceID string,
) (*entity.MarketingConsent, error) {
	var consent entity.MarketingConsent

	err := r.db.WithContext(ctx).
		Where("device_id = ?", deviceID).
		First(&consent).Error

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}

	return &consent, nil
}

func (r *marketingConsentRepo) Create(
	ctx context.Context,
	consent *entity.MarketingConsent,
) error {
	return r.db.WithContext(ctx).
		Create(consent).Error
}

func (r *marketingConsentRepo) Update(
	ctx context.Context,
	consent *entity.MarketingConsent,
) error {
	return r.db.WithContext(ctx).
		Model(&entity.MarketingConsent{}).
		Where("device_id = ?", consent.DeviceID).
		Updates(map[string]interface{}{
			"marketing_agreed": consent.MarketingAgreed,
			"agreed_at":        consent.AgreedAt,
			"updated_at":       consent.UpdatedAt,
		}).Error
}
