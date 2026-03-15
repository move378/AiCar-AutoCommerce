package container

import (
	mycarexternal "backend/internal/adapter/external"
	"backend/internal/config"
	"backend/internal/domain/repository"
	"backend/internal/infra/persistence/postgres"
	"backend/internal/infra/persistence/redis"
	usecase "backend/internal/usecase/auth"
	brandusecase "backend/internal/usecase/brand"
	carusecase "backend/internal/usecase/car"
	mycarusecase "backend/internal/usecase/mycar"
)

type Container struct {

	AuthUsecase   usecase.AuthUsecase
  AuthSocialUsecase       usecase.AuthSocialUsecase
	UserUsecase   usecase.UserUsecase
	SocialUsecase usecase.SocialUsecase
	KakaoUsecase  usecase.KakaoUsecase
	GoogleUsecase usecase.GoogleUsecase
	AppleUsecase  usecase.AppleUsecase
	TokenCache    repository.TokenCacheRepository
  CarUsecase              carusecase.CarUsecase
	BrandUsecase            brandusecase.BrandUsecase
	MarketingConsentUsecase usecase.MarketingConsentUsecase
	MyCarUsecase            mycarusecase.Usecase

}

func NewContainer(db *postgres.DB, rdb *redis.Redis) *Container {
	// repo 생성
	userRepo := postgres.NewUserRepo(db)
	deviceRepo := postgres.NewDeviceRepo(db)
	tokenCache := redis.NewTokenCache(rdb)
	socialRepo := postgres.NewAuthSocialRepo(db)

  carRepo := postgres.NewCarRepo(db)
	brandRepo := postgres.NewBrandRepo(db)
	marketingConsentRepo := postgres.NewMarketingConsentRepo(db)
	myCarRepo := postgres.NewMyCarRepo(db)
	txManager := db

	socialUsecase := usecase.NewSocialUsecase(userRepo, socialRepo, tokenCache)
	socialCache := redis.NewSocialCache(rdb)
  carUC := carusecase.NewCarUsecase(carRepo)
	brandUC := brandusecase.NewBrandUsecase(brandRepo)
	marketingConsentUC := usecase.NewMarketingConsentUsecase(marketingConsentRepo)

	mockCarProvider := mycarexternal.NewMockCarInfoProvider()
	myCarUC := mycarusecase.NewUsecase(myCarRepo, mockCarProvider)

	// config 로드
	cfg := config.LoadConfig()


	return &Container{

		AuthUsecase:   usecase.NewAuthUsecase(userRepo, deviceRepo, tokenCache, txManager),
		UserUsecase:   usecase.NewUserUsecase(userRepo),
		KakaoUsecase:  usecase.NewKakaoUsecase(socialUsecase, socialCache),
		GoogleUsecase: usecase.NewGoogleUsecase(socialUsecase, socialCache),
		AppleUsecase:  usecase.NewAppleUsecase(socialUsecase, socialCache, cfg.Auth.AppleClientID),
		TokenCache:    tokenCache,
    MarketingConsentUsecase: marketingConsentUC,
		CarUsecase:              carUC,
		BrandUsecase:            brandUC,
		MyCarUsecase:            myCarUC,

	}
}
