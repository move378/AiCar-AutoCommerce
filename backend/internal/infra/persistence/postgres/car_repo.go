package postgres

import (
	"context"
	"errors"
	"fmt"

	"backend/internal/domain/entity"
	"backend/internal/domain/repository"
	"backend/internal/shared/errs"

	"gorm.io/gorm"
)

type carRepo struct {
	db *DB
}

func NewCarRepo(db *DB) repository.CarRepository {
	return &carRepo{db: db}
}

func (r *carRepo) List(ctx context.Context, cond repository.CarListCondition) ([]entity.Car, error) {
	var cars []entity.Car

	if cond.Page <= 0 {
		cond.Page = 1
	}
	if cond.Size <= 0 {
		cond.Size = 10
	}

	offset := (cond.Page - 1) * cond.Size

	orderBy := "created_at DESC"
	switch cond.Sort {
	case "price_asc":
		orderBy = "price ASC"
	case "price_desc":
		orderBy = "price DESC"
	case "year_asc":
		orderBy = "year ASC"
	case "year_desc":
		orderBy = "year DESC"
	case "created_at_asc":
		orderBy = "created_at ASC"
	case "created_at_desc", "":
		orderBy = "created_at DESC"
	default:
		orderBy = "created_at DESC"
	}

	query := r.db.WithContext(ctx).
		Preload("Model").
		Preload("Model.Brand").
		Where("deleted_at IS NULL")

	if cond.BrandID != nil && *cond.BrandID != "" {
		query = query.Joins("JOIN car_models ON car_models.id = cars.model_id").
			Where("car_models.brand_id = ?", *cond.BrandID)
	}

	if cond.FuelType != nil && *cond.FuelType != "" {
		query = query.Where("fuel_type = ?", *cond.FuelType)
	}

	if cond.MinPrice != nil {
		query = query.Where("price >= ?", *cond.MinPrice)
	}

	if cond.MaxPrice != nil {
		query = query.Where("price <= ?", *cond.MaxPrice)
	}

	err := query.
		Order(orderBy).
		Limit(cond.Size).
		Offset(offset).
		Find(&cars).Error
	if err != nil {
		return nil, fmt.Errorf("차량 목록 조회 실패: %w", err)
	}

	return cars, nil
}

func (r *carRepo) GetByID(ctx context.Context, id string) (*entity.Car, error) {
	var car entity.Car

	err := r.db.WithContext(ctx).
		Preload("Model").
		Preload("Model.Brand").
		Where("id = ? AND deleted_at IS NULL", id).
		First(&car).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errs.ErrNotFound
		}
		return nil, fmt.Errorf("차량 상세 조회 실패: %w", err)
	}

	return &car, nil
}

func (r *carRepo) GetImagesByCarID(ctx context.Context, carID string) ([]entity.CarImage, error) {
	var images []entity.CarImage

	err := r.db.WithContext(ctx).
		Where("car_id = ?", carID).
		Order("sort_order ASC").
		Find(&images).Error
	if err != nil {
		return nil, fmt.Errorf("차량 이미지 조회 실패: %w", err)
	}

	return images, nil
}
