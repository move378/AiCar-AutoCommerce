package container

import (
	"backend/internal/infra/persistence/postgres"
	"backend/internal/infra/persistence/redis"
	usecase "backend/internal/usecase/auth"
)

type Container struct {
	AuthUsecase       usecase.AuthUsecase
	AuthSocialUsecase usecase.AuthSocialUsecase
	KakaoUsecase      usecase.KakaoUsecase
	GoogleUsecase     usecase.GoogleUsecase
}

func NewContainer(db *postgres.DB, rdb *redis.Redis) *Container {
	// repo 생성
	userRepo := postgres.NewUserRepo(db)
	deviceRepo := postgres.NewDeviceRepo(db)
	tokenRepo := postgres.NewTokenRepo(rdb)
	socialRepo := postgres.NewAuthSocialRepo(db)
	txManager := db

	socialUsecase := usecase.NewSocialUsecase(userRepo, socialRepo, tokenRepo)

	// usecase 생성 후 container에 담아서 반환
	return &Container{
		AuthUsecase:   usecase.NewAuthUsecase(userRepo, deviceRepo, tokenRepo, txManager),
		KakaoUsecase:  usecase.NewKakaoUsecase(socialUsecase),
		GoogleUsecase: usecase.NewGoogleUsecase(socialUsecase),
	}
}
