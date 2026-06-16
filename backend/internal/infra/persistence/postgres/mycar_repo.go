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

type myCarRepo struct {
	db *DB
}

func NewMyCarRepo(db *DB) repository.MyCarRepository {
	return &myCarRepo{db: db}
}

func (r *myCarRepo) Create(ctx context.Context, car *entity.MyCar) error {
	err := r.db.WithContext(ctx).Create(car).Error
	if err != nil {
		return fmt.Errorf("내 차량 등록 실패: %w", err)
	}

	return nil
}

func (r *myCarRepo) FindByUserID(ctx context.Context, userID string) ([]entity.MyCar, error) {
	var cars []entity.MyCar

	err := r.db.WithContext(ctx).
		Where("user_id = ?", userID).
		Order("created_at DESC").
		Find(&cars).Error
	if err != nil {
		return nil, fmt.Errorf("내 차량 목록 조회 실패: %w", err)
	}

	return cars, nil
}

func (r *myCarRepo) DeleteByUserID(ctx context.Context, userID string) error {
	return r.db.WithContext(ctx).
		Where("user_id = ?", userID).
		Delete(&entity.MyCar{}).Error
}

func (r *myCarRepo) FindByUserIDAndPlate(ctx context.Context, userID, licensePlate string) (*entity.MyCar, error) {
	var car entity.MyCar

	err := r.db.WithContext(ctx).
		Where("user_id = ? AND license_plate = ?", userID, licensePlate).
		First(&car).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errs.ErrNotFound
		}
		return nil, fmt.Errorf("내 차량 단건 조회 실패: %w", err)
	}

	return &car, nil
}
