include .env.local
export

ENVIRONMENT ?= local

# OS 감지
ifeq ($(OS),Windows_NT)
    SET_ENV = set APP_ENV=$(ENVIRONMENT) &&
	OS = windows
else
    SET_ENV = APP_ENV=$(ENVIRONMENT)
	OS = mac
endif

run:
	$(SET_ENV) go run cmd/api/main.go

dev:
	$(SET_ENV) air -c .air.$(OS).toml

ngrok:
	ngrok http --url=glaucescent-babette-untolled.ngrok-free.dev 8080

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

migrate-reset:
	goose -dir migrations postgres "postgres://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable" reset

swagger:
	swag init -g cmd/api/main.go --parseDependency --parseInternal