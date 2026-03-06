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

type tokenRepo struct {
	db *DB
}

func NewTokenRepo(db *DB) repository.TokenRepository {
	return &tokenRepo{db: db}
}

func (r *tokenRepo) FindByToken(ctx context.Context, token string) (*entity.RefreshToken, error) {
	var tk entity.RefreshToken
	err := r.db.WithContext(ctx).First(&tk, "token = ?", token).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errs.ErrNotFound
		}
		return nil, fmt.Errorf("토큰 조회 실패: %w", err)
	}
	return &tk, nil
}

func (r *tokenRepo) Create(ctx context.Context, token *entity.RefreshToken) error {
	if err := r.db.WithContext(ctx).Create(token).Error; err != nil {
		return fmt.Errorf("토큰 생성 실패: %w", err)
	}
	return nil
}

func (r *tokenRepo) Update(ctx context.Context, token *entity.RefreshToken) error {
	result := r.db.WithContext(ctx).Save(token)
	if result.Error != nil {
		return fmt.Errorf("토큰 수정 실패: %w", result.Error)
	}
	if result.RowsAffected == 0 {
		return errs.ErrNotFound
	}
	return nil
}

func (r *tokenRepo) DeleteByToken(ctx context.Context, token string) error {
	result := r.db.WithContext(ctx).Delete(&entity.RefreshToken{}, "token = ?", token)
	if result.Error != nil {
		return fmt.Errorf("토큰	 삭제 실패: %w", result.Error)
	}
	if result.RowsAffected == 0 {
		return errs.ErrNotFound
	}
	return nil
}

func (r *tokenRepo) DeleteByUserID(ctx context.Context, id uuid.UUID) error {
	result := r.db.WithContext(ctx).Delete(&entity.RefreshToken{}, "user_id = ?", id)
	if result.Error != nil {
		return fmt.Errorf("토큰 삭제 실패: %w", result.Error)
	}
	if result.RowsAffected == 0 {
		return errs.ErrNotFound
	}
	return nil
}
