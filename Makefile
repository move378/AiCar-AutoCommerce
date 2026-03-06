BACKOFFICE_DIR = ./backoffice
BACKEND_DIR = ./backend
APP_DIR = ./app

run-web:
	cd  $(BACKOFFICE_DIR) && npm run dev
	
run-backend:
	cd $(BACKEND_DIR) && APP_ENV=local go run cmd/api/main.go