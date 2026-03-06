package main

import (
	"backend/internal/adapter/router"
	"backend/internal/config"
	"fmt"
	"os"
)

func main() {
	config.LoadConfig()

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080" // 기본 포트 설정
	}

	r := router.SetupRouter()
	r.Run(":" + port)

	fmt.Printf("🚀 AICar 서버 시작! [포트: %s]\n", port)
	if err := r.Run(":" + port); err != nil {
		fmt.Printf("서버 시작 중 오류 발생: %v\n", err)
	}
}
