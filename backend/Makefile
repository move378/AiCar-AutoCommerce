include .env.local
export

ENVIRONMENT ?= local

# OS 감지
ifeq ($(OS),Windows_NT)
    SET_ENV = set APP_ENV=$(ENVIRONMENT) &&
else
    SET_ENV = APP_ENV=$(ENVIRONMENT)
endif

run:
	$(SET_ENV) go run cmd/api/main.go

dev:
	set APP_ENV=local && air

setup:
	go mod tidy
	go get github.com/joho/godotenv
	go get github.com/gin-gonic/gin
	go get github.com/golang-jwt/jwt/v5
	go get gorm.io/gorm
	go get gorm.io/driver/postgres
	go get github.com/google/uuid
	go install github.com/pressly/goose/v3/cmd/goose@latest
	go install github.com/swaggo/swag/cmd/swag@latest
	go get github.com/swaggo/swag@latest
	go get github.com/swaggo/gin-swagger@latest
	go get github.com/swaggo/files@latest

migrate-up:
	goose -dir migrations postgres "postgres://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable" up

migrate-down:
	goose -dir migrations postgres "postgres://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable" down

swagger:
	swag init -g cmd/api/main.go