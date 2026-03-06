package config

import (
	"log"
	"os"

	"github.com/joho/godotenv"
)

type Config struct {
	DB  DBConfig
	JWT JWTConfig
	// Redis RedisConfig // 나중에 추가될 것들
}

type DBConfig struct {
	Host     string
	User     string
	Password string
	Name     string
	Port     string
}

type JWTConfig struct {
	Secret     string
	ExpireHour int
}

func LoadConfig() *Config {
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

	return &Config{
		DB: DBConfig{
			Host:     os.Getenv("DB_HOST"),
			User:     os.Getenv("DB_USER"),
			Password: os.Getenv("DB_PASSWORD"),
			Name:     os.Getenv("DB_NAME"),
			Port:     os.Getenv("DB_PORT"),
		},
		JWT: JWTConfig{
			Secret: os.Getenv("JWT_SECRET"),
		},
	}
}
