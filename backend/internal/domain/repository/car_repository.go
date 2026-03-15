package repository

import (
	"context"

	"backend/internal/domain/entity"
)

type CarRepository interface {
	List(ctx context.Context, cond CarListCondition) ([]entity.Car, error)
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
	Sort     string
}
