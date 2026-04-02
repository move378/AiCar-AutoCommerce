package redis

import (
	"backend/internal/domain/entity"
	"backend/internal/domain/repository"
	"backend/internal/shared/errs"
	"context"
	"encoding/json"
	"fmt"
	"time"

	goredis "github.com/redis/go-redis/v9"
)

type socialCache struct {
	rdb *Redis
}

func NewSocialCache(rdb *Redis) repository.SocialCacheRepository {
	return &socialCache{rdb: rdb}
}

func (r *socialCache) Create(ctx context.Context, providerToken string, social *entity.SocialUserInfo) error {
	val, err := json.Marshal(social)

	if err != nil {
		return fmt.Errorf("직렬화 실패: %w", err)
	}

	err = r.rdb.Set(ctx, "social:"+providerToken, string(val), 24*time.Hour).Err()
	if err != nil {
		return fmt.Errorf("토큰 저장 실패: %w", err)
	}
	return nil
}

func (r *socialCache) FindByProviderToken(ctx context.Context, providerToken string) (*entity.SocialUserInfo, error) {
	var social entity.SocialUserInfo
	val, err := r.rdb.Get(ctx, "social:"+providerToken).Result()
	if err == goredis.Nil {
		return nil, errs.ErrNotFound
	}
	if err != nil {
		return nil, fmt.Errorf("Redis 서버 프로바이더 조회 실패: %w", err)
	}

	err = json.Unmarshal([]byte(val), &social)

	if err != nil {
		return nil, fmt.Errorf("직렬화 실패: %w", err)
	}

	return &social, nil
}

// func (r *socialCache) Delete(ctx context.Context) {}
