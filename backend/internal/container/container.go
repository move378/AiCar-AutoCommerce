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
	chatusecase "backend/internal/usecase/chat"
	estimateusecase "backend/internal/usecase/estimate"
	mycarusecase "backend/internal/usecase/mycar"
	vehicleusecase "backend/internal/usecase/vehicle"
)

type Container struct {
	AuthUsecase             usecase.AuthUsecase
	UserUsecase             usecase.UserUsecase
	KakaoUsecase            usecase.KakaoUsecase
	GoogleUsecase           usecase.GoogleUsecase
	AppleUsecase            usecase.AppleUsecase
	TokenCache              repository.TokenCacheRepository
	CarUsecase              carusecase.CarUsecase
	BrandUsecase            brandusecase.BrandUsecase
	MarketingConsentUsecase usecase.MarketingConsentUsecase
	MyCarUsecase            mycarusecase.Usecase
	VehicleUsecase          vehicleusecase.Usecase
	ChatUsecase             chatusecase.Usecase
	EstimateUsecase         estimateusecase.Usecase
	PurgeUsecase            usecase.PurgeUsecase
}

func NewContainer(db *postgres.DB, rdb *redis.Redis) *Container {
	// repo 생성
	userRepo := postgres.NewUserRepo(db)
	deviceRepo := postgres.NewDeviceRepo(db)
	tokenCache := redis.NewTokenCache(rdb)
	socialRepo := postgres.NewSocialRepo(db)

	carRepo := postgres.NewCarRepo(db)
	brandRepo := postgres.NewBrandRepo(db)
	vehicleRepo := postgres.NewVehicleRepo(db)
	chatRepo := postgres.NewChatRepo(db)
	estimateRepo := postgres.NewEstimateRepo(db)
	promotionRepo := postgres.NewPromotionRepo(db)
	marketingConsentRepo := postgres.NewMarketingConsentRepo(db)
	myCarRepo := postgres.NewMyCarRepo(db)
	txManager := db

	userUsecase := usecase.NewUserUsecase(deviceRepo, userRepo, socialRepo, tokenCache, txManager)
	socialCache := redis.NewSocialCache(rdb)
	carUC := carusecase.NewCarUsecase(carRepo)
	brandUC := brandusecase.NewBrandUsecase(brandRepo)
	marketingConsentUC := usecase.NewMarketingConsentUsecase(marketingConsentRepo)

	mockCarProvider := mycarexternal.NewMockCarInfoProvider()
	myCarUC := mycarusecase.NewUsecase(myCarRepo, mockCarProvider)
	vehicleUC := vehicleusecase.NewUsecase(vehicleRepo)
	chatUC := chatusecase.NewUsecase(chatRepo)

	// config 로드
	cfg := config.LoadConfig()

	return &Container{

		AuthUsecase:             usecase.NewAuthUsecase(userRepo, deviceRepo, tokenCache, txManager),
		UserUsecase:             userUsecase,
		KakaoUsecase:            usecase.NewKakaoUsecase(userUsecase, socialCache),
		GoogleUsecase:           usecase.NewGoogleUsecase(userUsecase, socialCache),
		AppleUsecase:            usecase.NewAppleUsecase(userUsecase, socialCache, cfg.Auth.AppleClientID),
		TokenCache:              tokenCache,
		MarketingConsentUsecase: marketingConsentUC,
		CarUsecase:              carUC,
		BrandUsecase:            brandUC,
		MyCarUsecase:            myCarUC,
		VehicleUsecase:          vehicleUC,
		ChatUsecase:             chatUC,
		EstimateUsecase:         estimateusecase.NewUsecase(estimateRepo, promotionRepo, vehicleRepo),
		PurgeUsecase:            usecase.NewPurgeUsecase(userRepo, chatRepo, myCarRepo, estimateRepo, txManager),
	}
}
