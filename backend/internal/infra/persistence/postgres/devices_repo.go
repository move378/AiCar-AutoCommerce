// internal/infra/persistence/postgres/devices_repo.go
package postgres

import (
	"context"
	"errors"
	"fmt"

	"github.com/google/uuid"
	"gorm.io/gorm"

	"backend/internal/domain/entity"
	"backend/internal/domain/repository"
	"backend/internal/shared/errs"
)

type devicesRepo struct {
	db *DB
}

func NewDeviceRepo(db *DB) repository.DeviceRepository {
	return &devicesRepo{db: db}
}

func (r *devicesRepo) FindByDeviceUID(ctx context.Context, deviceUID string) (*entity.Device, error) {
	var device entity.Device
	err := r.db.WithContext(ctx).Where("device_uid = ?", deviceUID).First(&device).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errs.ErrNotFound
		}
		return nil, fmt.Errorf("디바이스 조회 실패: %w", err)
	}
	return &device, nil
}

func (r *devicesRepo) Create(ctx context.Context, device *entity.Device) error {
	if err := r.db.WithContext(ctx).Create(device).Error; err != nil {
		return fmt.Errorf("디바이스 생성 실패: %w", err)
	}
	return nil
}

func (r *devicesRepo) Delete(ctx context.Context, id uuid.UUID) error {
	result := r.db.WithContext(ctx).Delete(&entity.Device{}, "id = ?", id)
	if result.Error != nil {
		return fmt.Errorf("디바이스 삭제 실패: %w", result.Error)
	}
	if result.RowsAffected == 0 {
		return errs.ErrNotFound
	}
	return nil
}
