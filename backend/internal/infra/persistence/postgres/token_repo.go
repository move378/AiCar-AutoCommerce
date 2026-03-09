package postgres

import (
	"context"
	"fmt"

	"github.com/google/uuid"

	"backend/internal/domain/entity"
	"backend/internal/domain/repository"
	"backend/internal/infra/persistence/redis"
	"backend/internal/shared/errs"

	goredis "github.com/redis/go-redis/v9"
)

type tokenRepo struct {
	rdb *redis.Redis
}

func NewTokenRepo(rdb *redis.Redis) repository.TokenRepository {
	return &tokenRepo{rdb: rdb}
}

func (r *tokenRepo) FindByToken(ctx context.Context, token string) (*entity.RefreshToken, error) {
	val, err := r.rdb.Get(ctx, "refresh_token:"+token).Result()
	if err == goredis.Nil {
		return nil, errs.ErrNotFound
	}
	if err != nil {
		return nil, fmt.Errorf("토큰 조회 실패: %w", err)
	}
	userID, _ := uuid.Parse(val)
	return &entity.RefreshToken{UserID: userID, Token: token}, nil
}

func (r *tokenRepo) Create(ctx context.Context, token *entity.RefreshToken) error {
	key := "refresh_token:" + token.Token
	err := r.rdb.Set(ctx, key, token.UserID.String(), 7*24*60*60).Err() // 7일	return nil

	if err != nil {
		return fmt.Errorf("토큰 저장 실패: %w", err)
	}
	return r.rdb.Set(ctx, key, token.UserID.String(), 7*24*60*60).Err() // 7일
}

func (r *tokenRepo) Update(ctx context.Context, token *entity.RefreshToken) error {
	// result := r.db.WithContext(ctx).Save(token)
	// if result.Error != nil {
	// 	return fmt.Errorf("토큰 수정 실패: %w", result.Error)
	// }
	// if result.RowsAffected == 0 {
	// 	return errs.ErrNotFound
	// }
	return nil
}

func (r *tokenRepo) DeleteByToken(ctx context.Context, token string) error {
	// result := r.db.WithContext(ctx).Delete(&entity.RefreshToken{}, "token = ?", token)
	// if result.Error != nil {
	// 	return fmt.Errorf("토큰	 삭제 실패: %w", result.Error)
	// }
	// if result.RowsAffected == 0 {
	// 	return errs.ErrNotFound
	// }
	return nil
}

func (r *tokenRepo) DeleteByUserID(ctx context.Context, id uuid.UUID) error {
	// result := r.db.WithContext(ctx).Delete(&entity.RefreshToken{}, "user_id = ?", id)
	// if result.Error != nil {
	// 	return fmt.Errorf("토큰 삭제 실패: %w", result.Error)
	// }
	// if result.RowsAffected == 0 {
	// 	return errs.ErrNotFound
	// }
	return nil
}
