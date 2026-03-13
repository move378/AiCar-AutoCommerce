package redis

import (
	"backend/internal/domain/entity"
	"backend/internal/domain/repository"
	"backend/internal/shared/errs"
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
	goredis "github.com/redis/go-redis/v9"
)

type tokenCache struct {
	rdb *Redis
}

func NewTokenCache(rdb *Redis) repository.TokenCacheRepository {
	return &tokenCache{rdb: rdb}
}

func (r *tokenCache) Create(ctx context.Context, token *entity.RefreshToken) error {
	key := "rt:" + token.UserID.String()
	err := r.rdb.Set(ctx, key, token.Token, 7*24*time.Hour).Err()
	if err != nil {
		return fmt.Errorf("토큰 저장 실패: %w", err)
	}
	return nil
}

func (r *tokenCache) FindByUserID(ctx context.Context, userID uuid.UUID) (*entity.RefreshToken, error) {
	val, err := r.rdb.Get(ctx, "rt:"+userID.String()).Result()
	if err == goredis.Nil {
		return nil, errs.ErrNotFound
	}
	if err != nil {
		return nil, fmt.Errorf("Redis 서버 오류 토큰 조회 실패: %w", err)
	}
	return &entity.RefreshToken{UserID: userID, Token: val}, nil
}

func (r *tokenCache) DeleteByToken(ctx context.Context, token string) error {
	return nil
}

func (r *tokenCache) DeleteByUserID(ctx context.Context, userID uuid.UUID) error {
	err := r.rdb.Del(ctx, "rt:"+userID.String()).Err()

	fmt.Println("리프레쉬 삭제", err)
	if err != nil {
		return fmt.Errorf("토큰 삭제 실패: %w", err)
	}
	return nil
}

func (r *tokenCache) AddToBlacklist(ctx context.Context, token string, expiration time.Duration) error {
	err := r.rdb.Set(ctx, "bl:"+token, "blacklisted", expiration).Err()

	if err != nil {
		return fmt.Errorf("토큰 블랙리스트 추가 실패: %w", err)
	}

	return nil
}

func (r *tokenCache) IsBlacklisted(ctx context.Context, token string) (bool, error) {
	val, err := r.rdb.Get(ctx, "bl:"+token).Result()
	if err == goredis.Nil {
		return false, nil
	}
	if err != nil {
		return false, fmt.Errorf("Redis 서버 오류 블랙리스트 조회 실패: %w", err)
	}
	return val == "blacklisted", nil
}
