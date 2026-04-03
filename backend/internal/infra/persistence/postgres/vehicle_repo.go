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

type vehicleRepo struct {
	db *DB
}

func NewVehicleRepo(db *DB) repository.VehicleRepository {
	return &vehicleRepo{db: db}
}

func (r *vehicleRepo) buildFilterQuery(ctx context.Context, cond repository.VehicleSearchCondition) *gorm.DB {
	query := r.db.WithContext(ctx).
		Joins("JOIN vehicles_models ON vehicles_models.id = vehicles_trims.model_id").
		Joins("JOIN vehicles_brands ON vehicles_brands.id = vehicles_models.brand_id")

	if cond.Keyword != nil && *cond.Keyword != "" {
		kw := "%" + *cond.Keyword + "%"
		query = query.Where(
			"vehicles_brands.name ILIKE ? OR vehicles_models.model_name ILIKE ? OR vehicles_trims.trim_name ILIKE ?",
			kw, kw, kw,
		)
	}

	return query
}

func (r *vehicleRepo) Search(ctx context.Context, cond repository.VehicleSearchCondition) ([]entity.VehicleTrim, error) {
	if cond.Page <= 0 {
		cond.Page = 1
	}
	if cond.Size <= 0 {
		cond.Size = 10
	}
	offset := (cond.Page - 1) * cond.Size

	var trims []entity.VehicleTrim
	err := r.buildFilterQuery(ctx, cond).
		Preload("Model").
		Preload("Model.Brand").
		Preload("IceSpec").
		Preload("EvSpec").
		Order("vehicles_trims.id ASC").
		Limit(cond.Size).
		Offset(offset).
		Find(&trims).Error
	if err != nil {
		return nil, fmt.Errorf("차량 검색 실패: %w", err)
	}

	return trims, nil
}

func (r *vehicleRepo) Count(ctx context.Context, cond repository.VehicleSearchCondition) (int64, error) {
	var total int64
	err := r.buildFilterQuery(ctx, cond).
		Model(&entity.VehicleTrim{}).
		Count(&total).Error
	if err != nil {
		return 0, fmt.Errorf("차량 개수 조회 실패: %w", err)
	}
	return total, nil
}

func (r *vehicleRepo) GetByID(ctx context.Context, id string) (*entity.VehicleTrim, error) {
	var trim entity.VehicleTrim
	err := r.db.WithContext(ctx).
		Preload("Model").
		Preload("Model.Brand").
		Preload("IceSpec").
		Preload("EvSpec").
		Preload("Images").
		Where("vehicles_trims.id = ?", id).
		First(&trim).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errs.ErrNotFound
		}
		return nil, fmt.Errorf("차량 상세 조회 실패: %w", err)
	}
	return &trim, nil
}

func (r *vehicleRepo) ListBrands(ctx context.Context) ([]entity.VehicleBrand, error) {
	var brands []entity.VehicleBrand
	err := r.db.WithContext(ctx).
		Order("name ASC").
		Find(&brands).Error
	if err != nil {
		return nil, fmt.Errorf("브랜드 목록 조회 실패: %w", err)
	}
	return brands, nil
}
