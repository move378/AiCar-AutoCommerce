package container

import (
	mycarexternal "backend/internal/adapter/external"
	"backend/internal/infra/persistence/postgres"
	usecase "backend/internal/usecase/auth"
	brandusecase "backend/internal/usecase/brand"
	carusecase "backend/internal/usecase/car"
	mycarusecase "backend/internal/usecase/mycar"
)

type Container struct {
	AuthUsecase             usecase.AuthUsecase
	AuthSocialUsecase       usecase.AuthSocialUsecase
	KakaoUsecase            usecase.KakaoUsecase
	CarUsecase              carusecase.CarUsecase
	BrandUsecase            brandusecase.BrandUsecase
	MarketingConsentUsecase usecase.MarketingConsentUsecase
	MyCarUsecase            mycarusecase.Usecase
}

func NewContainer(db *postgres.DB) *Container {
	// repo 생성
	userRepo := postgres.NewUserRepo(db)
	deviceRepo := postgres.NewDeviceRepo(db)
	tokenRepo := postgres.NewTokenRepo(db)
	socialRepo := postgres.NewAuthSocialRepo(db)
	carRepo := postgres.NewCarRepo(db)
	brandRepo := postgres.NewBrandRepo(db)
	marketingConsentRepo := postgres.NewMarketingConsentRepo(db)
	myCarRepo := postgres.NewMyCarRepo(db)

	socialUsecase := usecase.NewSocialUsecase(userRepo, socialRepo, tokenRepo)
	carUC := carusecase.NewCarUsecase(carRepo)
	brandUC := brandusecase.NewBrandUsecase(brandRepo)
	marketingConsentUC := usecase.NewMarketingConsentUsecase(marketingConsentRepo)

	mockCarProvider := mycarexternal.NewMockCarInfoProvider()
	myCarUC := mycarusecase.NewUsecase(myCarRepo, mockCarProvider)

	return &Container{
		AuthUsecase:             usecase.NewAuthUsecase(userRepo, deviceRepo, tokenRepo),
		KakaoUsecase:            usecase.NewKakaoUsecase(socialUsecase),
		MarketingConsentUsecase: marketingConsentUC,
		CarUsecase:              carUC,
		BrandUsecase:            brandUC,
		MyCarUsecase:            myCarUC,
	}
}
