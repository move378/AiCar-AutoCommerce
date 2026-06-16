package main

import (
	"context"
	"log"
	"time"

	"backend/internal/config"
	"backend/internal/infra/persistence/postgres"
	"backend/internal/infra/persistence/redis"
	usecase "backend/internal/usecase/auth"

	postgresrepo "backend/internal/infra/persistence/postgres"
)

func main() {
	cfg := config.LoadConfig()

	db, err := postgres.NewDB(cfg)
	if err != nil {
		log.Fatalf("DB 연결 실패: %v", err)
	}
	rdb, err := redis.NewRedis(cfg)
	if err != nil {
		log.Fatalf("Redis 연결 실패: %v", err)
	}

	purgeUC := usecase.NewPurgeUsecase(
		postgresrepo.NewUserRepo(db),
		postgresrepo.NewChatRepo(db),
		postgresrepo.NewMyCarRepo(db),
		postgresrepo.NewEstimateRepo(db),
		db,
	)
	_ = rdb

	log.Println("[worker] 탈퇴 유저 데이터 purge 워커 시작")

	runPurge(purgeUC)

	ticker := time.NewTicker(24 * time.Hour)
	defer ticker.Stop()

	for range ticker.C {
		runPurge(purgeUC)
	}
}

func runPurge(uc usecase.PurgeUsecase) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Minute)
	defer cancel()

	log.Println("[worker] purge 시작")
	if err := uc.PurgeDeletedUsers(ctx); err != nil {
		log.Printf("[worker] purge 실패: %v", err)
		return
	}
	log.Println("[worker] purge 완료")
}
