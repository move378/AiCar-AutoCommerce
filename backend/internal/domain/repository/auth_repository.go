// internal/domain/repository/user_repository.go
package repository

import (
	"backend/internal/domain/entity"
	"context"
	"time"

	"github.com/google/uuid"
)

type DeviceRepository interface {
	Create(ctx context.Context, device *entity.Device) error
	FindByDeviceUID(ctx context.Context, deviceUID string) (*entity.Device, error)
}
type UserRepository interface {
	FindByID(ctx context.Context, id uuid.UUID) (*entity.User, error)
	FindByEmail(ctx context.Context, email string) (*entity.User, error)
	Create(ctx context.Context, user *entity.User) error
	Update(ctx context.Context, user *entity.User) error
	Delete(ctx context.Context, id uuid.UUID) error
}

type SocialRepository interface {
	FindByProviderID(ctx context.Context, provider string, providerID string) (*entity.SocialProvider, error)
	Create(ctx context.Context, authProvider *entity.SocialProvider) error
	DeleteByUserID(ctx context.Context, userID uuid.UUID) error
}

type SocialCacheRepository interface {
	Create(ctx context.Context, providerToken string, social *entity.SocialUserInfo) error
	FindByProviderToken(ctx context.Context, providerToken string) (*entity.SocialUserInfo, error)
}
type TokenCacheRepository interface {
	Create(ctx context.Context, token *entity.RefreshToken) error
	FindByUserID(ctx context.Context, userID uuid.UUID) (*entity.RefreshToken, error)
	DeleteByUserID(ctx context.Context, userID uuid.UUID) error // 로그아웃용
	AddToBlacklist(ctx context.Context, token string, expiration time.Duration) error
	IsBlacklisted(ctx context.Context, token string) (bool, error)
}

type TxManager interface {
	Transaction(ctx context.Context, fn func(ctx context.Context) error) error
}
