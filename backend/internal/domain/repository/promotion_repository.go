package repository

import (
	"context"

	"backend/internal/domain/entity"
)

type PromotionRepository interface {
	GetByID(ctx context.Context, id string) (*entity.Promotion, error)
}
