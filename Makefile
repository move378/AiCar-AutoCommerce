BACKOFFICE_DIR = ./backoffice
BACKEND_DIR = ./backend
APP_DIR = ./app

run-web:
	cd  $(BACKOFFICE_DIR) && npm run dev
	
run-backend:
	cd $(BACKEND_DIR) && APP_ENV=local go run cmd/api/main.go

setup-backend:
	cd $(BACKEND_DIR) && go mod tidy
	cd $(BACKEND_DIR) && go get github.com/joho/godotenv
	cd $(BACKEND_DIR) && go get github.com/gin-gonic/gin
	cd $(BACKEND_DIR) && go get github.com/golang-jwt/jwt/v5
	cd $(BACKEND_DIR) && go get gorm.io/gorm
	cd $(BACKEND_DIR) && go get gorm.io/driver/postgres
	cd $(BACKEND_DIR) && go get github.com/google/uuid