package postgres

import (
	"context"
	"errors"

	"backend/internal/domain/entity"
	"backend/internal/domain/repository"
	"backend/internal/shared/errs"

	"gorm.io/gorm"
)

type promotionRepo struct {
	db *DB
}

func NewPromotionRepo(db *DB) repository.PromotionRepository {
	return &promotionRepo{db: db}
}

func (r *promotionRepo) GetByID(ctx context.Context, id string) (*entity.Promotion, error) {
	var promotion entity.Promotion
	err := r.db.WithContext(ctx).First(&promotion, "id = ?", id).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errs.ErrNotFound
		}
		return nil, err
	}
	return &promotion, nil
}
