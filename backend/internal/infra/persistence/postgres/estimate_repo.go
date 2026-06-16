package postgres

import (
	"context"
	"errors"

	"backend/internal/domain/entity"
	"backend/internal/domain/repository"
	"backend/internal/shared/errs"

	"gorm.io/gorm"
)

type estimateRepo struct {
	db *DB
}

func NewEstimateRepo(db *DB) repository.EstimateRepository {
	return &estimateRepo{db: db}
}

func (r *estimateRepo) Create(ctx context.Context, estimate *entity.Estimate) error {
	return r.db.WithContext(ctx).Create(estimate).Error
}

func (r *estimateRepo) GetByID(ctx context.Context, id string, userID string) (*entity.Estimate, error) {
	var estimate entity.Estimate
	err := r.db.WithContext(ctx).
		Preload("Trim").
		Preload("Promotion").
		Where("id = ? AND user_id = ?", id, userID).
		First(&estimate).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errs.ErrNotFound
		}
		return nil, err
	}
	return &estimate, nil
}

func (r *estimateRepo) DeleteByUserID(ctx context.Context, userID string) error {
	return r.db.WithContext(ctx).
		Where("user_id = ?", userID).
		Delete(&entity.Estimate{}).Error
}

func (r *estimateRepo) GetByUserID(ctx context.Context, userID string) ([]entity.Estimate, error) {
	var estimates []entity.Estimate
	err := r.db.WithContext(ctx).
		Preload("Trim").
		Preload("Promotion").
		Where("user_id = ?", userID).
		Order("created_at DESC").
		Find(&estimates).Error
	return estimates, err
}
