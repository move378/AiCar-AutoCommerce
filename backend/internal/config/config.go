package config

import (
	"log"
	"os"

	"github.com/joho/godotenv"
)

func LoadConfig() {
	env := os.Getenv("APP_ENV")

	if env == "" {
		env = "local"
	}

	envFile := ".env." + env

	err := godotenv.Load(envFile)

	if err != nil {
		log.Printf("⚠️ %s 파일을 찾을 수 없어 시스템 환경 변수를 사용합니다.", envFile)
	} else {
		log.Printf("✅ %s 설정 파일을 로드했습니다.", envFile)
	}
}
