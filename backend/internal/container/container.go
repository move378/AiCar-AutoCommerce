package container

import (
	"backend/internal/infra/persistence/postgres"
	usecase "backend/internal/usecase/auth"
)

type Container struct {
	AuthUsecase       usecase.AuthUsecase
	AuthSocialUsecase usecase.AuthSocialUsecase
	KakaoUsecase      usecase.KakaoUsecase
}

func NewContainer(db *postgres.DB) *Container {
	// repo 생성
	userRepo := postgres.NewUserRepo(db)
	deviceRepo := postgres.NewDeviceRepo(db)
	tokenRepo := postgres.NewTokenRepo(db)
	socialRepo := postgres.NewAuthSocialRepo(db)

	socialUsecase := usecase.NewSocialUsecase(userRepo, socialRepo, tokenRepo)

	// usecase 생성 후 container에 담아서 반환
	return &Container{
		AuthUsecase:  usecase.NewAuthUsecase(userRepo, deviceRepo, tokenRepo),
		KakaoUsecase: usecase.NewKakaoUsecase(socialUsecase),
	}
}
