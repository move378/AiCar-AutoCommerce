// internal/domain/repository/user_repository.go
package repository

import (
	"backend/internal/domain/entity"
	"context"

	"github.com/google/uuid"
)

type UserRepository interface {
	FindByID(ctx context.Context, id uuid.UUID) (*entity.User, error)
	FindByEmail(ctx context.Context, email string) (*entity.User, error)
	Create(ctx context.Context, user *entity.User) error
	Update(ctx context.Context, user *entity.User) error
	Delete(ctx context.Context, id uuid.UUID) error
}

type DeviceRepository interface {
	Create(ctx context.Context, device *entity.Device) error
	FindByDeviceUID(ctx context.Context, deviceUID uuid.UUID)
}

type TokenRepository interface {
	FindByToken(ctx context.Context, token string) (*entity.RefreshToken, error)
	Create(ctx context.Context, token *entity.RefreshToken) error
	Delete(ctx context.Context, id uuid.UUID) error
}
