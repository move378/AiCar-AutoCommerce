package main

import (
	"backend/internal/adapter/router"
	"backend/internal/config"
	"backend/internal/container"
	"backend/internal/infra/persistence/postgres"
	"backend/internal/infra/persistence/redis"
	"fmt"
	"log"
	"os"
)

// @title           AICar API
// @version         1.0
// @description     AICar AutoCommerce API
// @host            localhost:8080
// @BasePath        /api/v1
// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
func main() {
	cfg := config.LoadConfig()

	db, dbErr := postgres.NewDB(cfg)
	rdb, rdbErr := redis.NewRedis(cfg)

	if dbErr != nil {
		log.Fatalf("❌ DB 연결 실패: %v", dbErr)
	}
	if rdbErr != nil {
		log.Fatalf("❌ Redis 연결 실패: %v", rdbErr)
	}

	container := container.NewContainer(db, rdb)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080" // 기본 포트 설정
	}

	r := router.SetupRouter(container)

	fmt.Printf("🚀 AICar 서버 시작! [포트: %s]\n", port)
	if err := r.Run(":" + port); err != nil {
		fmt.Printf("서버 시작 중 오류 발생: %v\n", err)
	}
}
