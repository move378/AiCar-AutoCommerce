package repository

import (
	"context"

	"backend/internal/domain/entity"
)

type MyCarRepository interface {
	Create(ctx context.Context, car *entity.MyCar) error
	FindByUserID(ctx context.Context, userID string) ([]entity.MyCar, error)
	FindByUserIDAndPlate(ctx context.Context, userID, licensePlate string) (*entity.MyCar, error)
	DeleteByUserID(ctx context.Context, userID string) error
}
