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

type socialRepo struct {
	db *DB
}

func NewSocialRepo(db *DB) repository.SocialRepository {
	return &socialRepo{db: db}
}

func (r *socialRepo) Create(ctx context.Context, authProvider *entity.SocialProvider) error {
	if err := r.db.WithContext(ctx).Create(authProvider).Error; err != nil {
		return fmt.Errorf("소셜 계정 생성 실패: %w", err)
	}
	return nil
}

func (r *socialRepo) FindByProviderID(ctx context.Context, provider string, providerID string) (*entity.SocialProvider, error) {
	var authProvider entity.SocialProvider
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

func (r *socialRepo) DeleteByUserID(ctx context.Context, userID uuid.UUID) error {
	if err := GetTx(ctx, r.db).WithContext(ctx).Delete(&entity.SocialProvider{}, "user_id = ?", userID).Error; err != nil {
		return fmt.Errorf("소셜 유저 데이터 삭제 실패 %w", err)
	}

	return nil
}
