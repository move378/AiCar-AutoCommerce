package repository

import (
	"context"

	"backend/internal/domain/entity"
)

type VehicleRepository interface {
	Search(ctx context.Context, cond VehicleSearchCondition) ([]entity.VehicleTrim, error)
	Count(ctx context.Context, cond VehicleSearchCondition) (int64, error)
	GetByID(ctx context.Context, id string) (*entity.VehicleTrim, error)
	ListBrands(ctx context.Context) ([]entity.VehicleBrand, error)
}

type VehicleSearchCondition struct {
	Page    int
	Size    int
	Keyword *string
}
