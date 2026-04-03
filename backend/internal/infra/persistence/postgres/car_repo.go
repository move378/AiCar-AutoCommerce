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

func (r *carRepo) buildFilterQuery(ctx context.Context, cond repository.CarListCondition) *gorm.DB {
	query := r.db.WithContext(ctx).
		Model(&entity.Car{}).
		Joins("JOIN vehicles_models ON vehicles_models.id = vehicles_trims.model_id").
		Joins("JOIN vehicles_brands ON vehicles_brands.id = vehicles_models.brand_id")

	if cond.BrandID != nil && *cond.BrandID != "" {
		query = query.Where("vehicles_models.brand_id = ?", *cond.BrandID)
	}

	if cond.FuelType != nil && *cond.FuelType != "" {
		query = query.Where("vehicles_trims.fuel_type = ?", *cond.FuelType)
	}

	if cond.MinPrice != nil {
		query = query.Where("vehicles_trims.base_price >= ?", *cond.MinPrice)
	}

	if cond.MaxPrice != nil {
		query = query.Where("vehicles_trims.base_price <= ?", *cond.MaxPrice)
	}

	if cond.Keyword != nil && *cond.Keyword != "" {
		kw := "%" + *cond.Keyword + "%"
		query = query.Where(
			"vehicles_brands.name ILIKE ? OR vehicles_models.model_name ILIKE ? OR vehicles_trims.trim_name ILIKE ?",
			kw, kw, kw,
		)
	}

	return query
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

	orderBy := "vehicles_trims.id ASC"
	switch cond.Sort {
	case "price_asc":
		orderBy = "vehicles_trims.base_price ASC NULLS LAST"
	case "price_desc":
		orderBy = "vehicles_trims.base_price DESC NULLS LAST"
	case "year_asc":
		orderBy = "vehicles_trims.year ASC NULLS LAST"
	case "year_desc":
		orderBy = "vehicles_trims.year DESC NULLS LAST"
	case "name_asc":
		orderBy = "vehicles_trims.trim_name ASC"
	case "name_desc":
		orderBy = "vehicles_trims.trim_name DESC"
	default:
		orderBy = "vehicles_trims.id ASC"
	}

	err := r.buildFilterQuery(ctx, cond).
		Preload("Model").
		Preload("Model.Brand").
		Order(orderBy).
		Limit(cond.Size).
		Offset(offset).
		Find(&cars).Error
	if err != nil {
		return nil, fmt.Errorf("차량 목록 조회 실패: %w", err)
	}

	return cars, nil
}

func (r *carRepo) Count(ctx context.Context, cond repository.CarListCondition) (int64, error) {
	var total int64
	err := r.buildFilterQuery(ctx, cond).
		Count(&total).Error
	if err != nil {
		return 0, fmt.Errorf("차량 개수 조회 실패: %w", err)
	}
	return total, nil
}

func (r *carRepo) GetByID(ctx context.Context, id string) (*entity.Car, error) {
	var car entity.Car

	err := r.db.WithContext(ctx).
		Preload("Model").
		Preload("Model.Brand").
		Where("vehicles_trims.id = ?", id).
		First(&car).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errs.ErrNotFound
		}
		return nil, fmt.Errorf("차량 상세 조회 실패: %w", err)
	}

	// 필요하면 나중에 vehicles_ice_specs 조인해서 EngineDisplacement/FuelEfficiency 채우기
	return &car, nil
}

func (r *carRepo) GetImagesByCarID(ctx context.Context, carID string) ([]entity.CarImage, error) {
	var images []entity.CarImage

	err := r.db.WithContext(ctx).
		Where("trim_id = ?", carID).
		Order("id ASC").
		Find(&images).Error
	if err != nil {
		return nil, fmt.Errorf("차량 이미지 조회 실패: %w", err)
	}

	return images, nil
}
