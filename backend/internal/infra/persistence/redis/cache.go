package redis

import (
	"backend/internal/config"
	"context"
	"log"

	"github.com/redis/go-redis/v9"
)

type Redis struct {
	*redis.Client
}

func NewRedis(cfg *config.Config) (*Redis, error) {
	rdb := redis.NewClient(&redis.Options{
		Addr:     cfg.Redis.Host + ":" + cfg.Redis.Port,
		Password: cfg.Redis.Password,
		DB:       0,
	})

	_, err := rdb.Ping(context.Background()).Result()
	if err != nil {
		return nil, err
	}

	log.Println("✅ Redis 연결 성공!")

	return &Redis{rdb}, nil
}
