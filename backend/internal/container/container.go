package container

import (
	"backend/internal/infra/persistence/postgres"
	usecase "backend/internal/usecase/auth"
)

type Container struct {
	AuthUsecase usecase.AuthUsecase
}

func NewContainer(db *postgres.DB) *Container {
	// repo 생성
	userRepo := postgres.NewUserRepo(db)
	deviceRepo := postgres.NewDeviceRepo(db)
	tokenRepo := postgres.NewTokenRepo(db)

	// usecase 생성 후 container에 담아서 반환
	return &Container{
		AuthUsecase: usecase.NewAuthUsecase(userRepo, deviceRepo, tokenRepo),
	}
}
