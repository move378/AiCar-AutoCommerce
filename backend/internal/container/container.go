package container

import (
	"backend/internal/domain/repository"
	"backend/internal/infra/persistence/postgres"
	"backend/internal/infra/persistence/redis"
	usecase "backend/internal/usecase/auth"
)

type Container struct {
	AuthUsecase       usecase.AuthUsecase
	AuthSocialUsecase usecase.AuthSocialUsecase
	KakaoUsecase      usecase.KakaoUsecase
	GoogleUsecase     usecase.GoogleUsecase
	TokenCache        repository.TokenCacheRepository
}

func NewContainer(db *postgres.DB, rdb *redis.Redis) *Container {
	// repo 생성
	userRepo := postgres.NewUserRepo(db)
	deviceRepo := postgres.NewDeviceRepo(db)
	tokenCache := redis.NewTokenCache(rdb)
	socialRepo := postgres.NewAuthSocialRepo(db)
	txManager := db

	socialUsecase := usecase.NewSocialUsecase(userRepo, socialRepo, tokenCache)
	socialCache := redis.NewSocialCache(rdb)

	// usecase 생성 후 container에 담아서 반환
	return &Container{
		AuthUsecase:   usecase.NewAuthUsecase(userRepo, deviceRepo, tokenCache, txManager),
		KakaoUsecase:  usecase.NewKakaoUsecase(socialUsecase, socialCache),
		GoogleUsecase: usecase.NewGoogleUsecase(socialUsecase, socialCache),
		TokenCache:    tokenCache,
	}
}
