package main

import (
	"backend/internal/adapter/router"
	"backend/internal/config"
	"backend/internal/container"
	"backend/internal/infra/persistence/postgres"
	usecase "backend/internal/usecase/auth"
	"fmt"
	"log"
	"os"
)

type CaseContainer struct {
	AuthUsecase usecase.AuthUsecase
}

// @title           AICar API
// @version         1.0
// @description     AICar AutoCommerce API
// @host            localhost:8080
// @BasePath        /api/v1
func main() {
	cfg := config.LoadConfig()

	db, dbErr := postgres.NewDB(cfg)

	if dbErr != nil {
		log.Fatalf("❌ DB 연결 실패: %v", dbErr)
	}

	container := container.NewContainer(db)

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
