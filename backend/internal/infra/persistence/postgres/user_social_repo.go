package postgres

import (
	"context"
	"errors"
	"fmt"

	"gorm.io/gorm"

	"backend/internal/domain/entity"
	"backend/internal/domain/repository"
	"backend/internal/shared/errs"
)

type authSocialRepo struct {
	db *DB
}

func NewAuthSocialRepo(db *DB) repository.UserAuthProviderRepository {
	return &authSocialRepo{db: db}
}

func (r *authSocialRepo) FindByProviderID(ctx context.Context, provider string, providerID string) (*entity.UserAuthProvider, error) {
	var authProvider entity.UserAuthProvider
	err := r.db.WithContext(ctx).
		Where("provider = ? AND provider_id = ?", provider, providerID).
		First(&authProvider).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errs.ErrNotFound
		}
		return nil, fmt.Errorf("소셜 계정 조회 실패: %w", err)
	}
	return &authProvider, nil
}
func (r *authSocialRepo) Create(ctx context.Context, authProvider *entity.UserAuthProvider) error {
	if err := r.db.WithContext(ctx).Create(authProvider).Error; err != nil {
		return fmt.Errorf("소셜 계정 생성 실패: %w", err)
	}
	return nil
}
