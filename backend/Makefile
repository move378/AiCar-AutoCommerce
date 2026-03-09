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
	set APP_ENV=local && air -c .air.windows.toml

setup:
	@echo "Installing libraries..."
	go mod tidy
	
	@echo "Installing dev tools..."
	go install github.com/air-verse/air@latest
	go install github.com/pressly/goose/v3/cmd/goose@latest
	go install github.com/swaggo/swag/cmd/swag@latest
	@echo "All set! Restart Now Your Code"

migrate-up:
	goose -dir migrations postgres "postgres://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable" up

migrate-down:
	goose -dir migrations postgres "postgres://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable" down

swagger:
	swag init -g cmd/api/main.go