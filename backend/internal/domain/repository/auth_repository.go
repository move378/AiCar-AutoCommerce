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

type UserAuthProviderRepository interface {
	FindByProviderID(ctx context.Context, provider string, providerID string) (*entity.UserAuthProvider, error)
	Create(ctx context.Context, authProvider *entity.UserAuthProvider) error
}

type DeviceRepository interface {
	Create(ctx context.Context, device *entity.Device) error
	FindByDeviceUID(ctx context.Context, deviceUID string) (*entity.Device, error)
}

type TokenRepository interface {
	FindByToken(ctx context.Context, token string) (*entity.RefreshToken, error)
	Create(ctx context.Context, token *entity.RefreshToken) error
	DeleteByToken(ctx context.Context, token string) error      // 찾아서 바로 삭제
	DeleteByUserID(ctx context.Context, userID uuid.UUID) error // 로그아웃용
}
