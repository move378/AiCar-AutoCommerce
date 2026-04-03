package repository

import (
	"context"

	"backend/internal/domain/entity"
)

type CarRepository interface {
	List(ctx context.Context, cond CarListCondition) ([]entity.Car, error)
	Count(ctx context.Context, cond CarListCondition) (int64, error)
	GetByID(ctx context.Context, id string) (*entity.Car, error)
	GetImagesByCarID(ctx context.Context, carID string) ([]entity.CarImage, error)
}

type CarListCondition struct {
	Page     int
	Size     int
	BrandID  *string
	FuelType *string
	MinPrice *int
	MaxPrice *int
	MinYear  *int
	MaxYear  *int
	Keyword  *string
	Sort     string
}
