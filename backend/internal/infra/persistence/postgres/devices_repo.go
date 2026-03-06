// internal/infra/persistence/postgres/user_repo.go
package postgres

import (
	"context"
	"fmt"

	"backend/internal/domain/entity"
	"backend/internal/domain/repository"
	"backend/internal/shared/errs"
)

type devicesRepo struct {
	db *DB
}

func NewDevices(db *DB) repository.DeviceRepository {
	return &devicesRepo{db: db}
}

func (r *devicesRepo) Create(ctx context.Context, device_id string) (user *entity.Device) {
	var device entity.Device

	err := r.db.WithContext(ctx).Create(&device, id).Error

}

func (r *userRepo) Create(ctx context.Context, user *entity.User) error {
	if err := r.db.WithContext(ctx).Create(user).Error; err != nil {
		return fmt.Errorf("유저 생성 실패: %w", err)
	}
	return nil
}

func (r *userRepo) Update(ctx context.Context, user *entity.User) error {
	result := r.db.WithContext(ctx).Save(user)
	if result.Error != nil {
		return fmt.Errorf("유저 수정 실패: %w", result.Error)
	}
	if result.RowsAffected == 0 {
		return errs.ErrNotFound
	}
	return nil
}

func (r *userRepo) Delete(ctx context.Context, id uint) error {
	result := r.db.WithContext(ctx).Delete(&entity.User{}, id)
	if result.Error != nil {
		return fmt.Errorf("유저 삭제 실패: %w", result.Error)
	}
	if result.RowsAffected == 0 {
		return errs.ErrNotFound
	}
	return nil
}
