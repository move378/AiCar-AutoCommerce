package postgres

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"

	"backend/internal/domain/entity"
	"backend/internal/domain/repository"
	"backend/internal/shared/errs"
)

type userRepo struct {
	db *DB
}

func NewUserRepo(db *DB) repository.UserRepository {
	return &userRepo{db: db}
}

func (r *userRepo) FindByID(ctx context.Context, id uuid.UUID) (*entity.User, error) {
	var user entity.User
	err := r.db.WithContext(ctx).First(&user, "id = ?", id).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errs.ErrNotFound
		}
		return nil, fmt.Errorf("유저 조회 실패: %w", err)
	}
	return &user, nil
}

func (r *userRepo) FindByEmail(ctx context.Context, email string) (*entity.User, error) {
	var user entity.User
	err := r.db.WithContext(ctx).Where("email = ?", email).First(&user).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errs.ErrNotFound
		}
		return nil, fmt.Errorf("유저 조회 실패: %w", err)
	}
	return &user, nil
}

func (r *userRepo) Create(ctx context.Context, user *entity.User) (*entity.User, error) {
	if err := GetTx(ctx, r.db).WithContext(ctx).Create(user).Error; err != nil {
		return nil, fmt.Errorf("유저 생성 실패: %w", err)
	}
	return user, nil
}

func (r *userRepo) Update(ctx context.Context, user *entity.User) error {
	result := r.db.WithContext(ctx).Save(user)

	fmt.Printf("유저 업데이트 시도: ID=%s, 결과: %v, 에러: %v\n", user.ID, result, result.Error)
	if result.Error != nil {
		return fmt.Errorf("유저 수정 실패: %w", result.Error)
	}
	if result.RowsAffected == 0 {
		return errs.ErrNotFound
	}
	return nil
}

func (r *userRepo) Delete(ctx context.Context, id uuid.UUID) error {
	result := GetTx(ctx, r.db).WithContext(ctx).Delete(&entity.User{}, "id = ?", id)
	if result.Error != nil {
		return fmt.Errorf("유저 삭제 실패: %w", result.Error)
	}
	if result.RowsAffected == 0 {
		return errs.ErrNotFound
	}
	return nil
}

func (r *userRepo) SoftDelete(ctx context.Context, id uuid.UUID) error {
	now := time.Now()
	result := GetTx(ctx, r.db).WithContext(ctx).
		Model(&entity.User{}).
		Where("id = ? AND deleted_at IS NULL", id).
		Updates(map[string]any{
			"status":     entity.UserStatusDeleted,
			"deleted_at": now,
		})
	if result.Error != nil {
		return fmt.Errorf("유저 소프트 삭제 실패: %w", result.Error)
	}
	if result.RowsAffected == 0 {
		return errs.ErrNotFound
	}
	return nil
}

func (r *userRepo) FindDeletedBefore(ctx context.Context, before time.Time) ([]entity.User, error) {
	var users []entity.User
	err := r.db.WithContext(ctx).
		Where("status = ? AND deleted_at IS NOT NULL AND deleted_at < ?", entity.UserStatusDeleted, before).
		Find(&users).Error
	if err != nil {
		return nil, fmt.Errorf("탈퇴 유저 조회 실패: %w", err)
	}
	return users, nil
}

func (r *userRepo) HardDelete(ctx context.Context, id uuid.UUID) error {
	result := GetTx(ctx, r.db).WithContext(ctx).
		Unscoped().
		Delete(&entity.User{}, "id = ?", id)
	if result.Error != nil {
		return fmt.Errorf("유저 영구 삭제 실패: %w", result.Error)
	}
	if result.RowsAffected == 0 {
		return errs.ErrNotFound
	}
	return nil
}
