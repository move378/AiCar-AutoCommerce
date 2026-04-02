package repository

import (
	"context"

	"backend/internal/domain/entity"
)

type EstimateRepository interface {
	Create(ctx context.Context, estimate *entity.Estimate) error
	GetByID(ctx context.Context, id string, userID string) (*entity.Estimate, error)
	GetByUserID(ctx context.Context, userID string) ([]entity.Estimate, error)
}
