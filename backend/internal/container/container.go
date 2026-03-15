package container

import (
	"backend/internal/config"
	"backend/internal/domain/repository"
	"backend/internal/infra/persistence/postgres"
	"backend/internal/infra/persistence/redis"
	usecase "backend/internal/usecase/auth"
)

type Container struct {
	AuthUsecase   usecase.AuthUsecase
	UserUsecase   usecase.UserUsecase
	KakaoUsecase  usecase.KakaoUsecase
	GoogleUsecase usecase.GoogleUsecase
	AppleUsecase  usecase.AppleUsecase
	TokenCache    repository.TokenCacheRepository
}

func NewContainer(db *postgres.DB, rdb *redis.Redis) *Container {
	// repo 생성
	userRepo := postgres.NewUserRepo(db)
	deviceRepo := postgres.NewDeviceRepo(db)
	tokenCache := redis.NewTokenCache(rdb)
	socialRepo := postgres.NewSocialRepo(db)
	txManager := db

	userUsecase := usecase.NewUserUsecase(deviceRepo, userRepo, socialRepo, tokenCache, txManager)
	socialCache := redis.NewSocialCache(rdb)

	// config 로드
	cfg := config.LoadConfig()

	// usecase 생성 후 container에 담아서 반환
	return &Container{
		AuthUsecase:   usecase.NewAuthUsecase(userRepo, deviceRepo, tokenCache, txManager),
		UserUsecase:   userUsecase,
		KakaoUsecase:  usecase.NewKakaoUsecase(userUsecase, socialCache),
		GoogleUsecase: usecase.NewGoogleUsecase(userUsecase, socialCache),
		AppleUsecase:  usecase.NewAppleUsecase(userUsecase, socialCache, cfg.Auth.AppleClientID),
		TokenCache:    tokenCache,
	}
}
