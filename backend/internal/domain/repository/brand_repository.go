package repository

import (
	"context"

	"backend/internal/domain/entity"
)

type BrandRepository interface {
	List(ctx context.Context) ([]entity.Brand, error)
}
