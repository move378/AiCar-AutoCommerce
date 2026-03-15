package router

import (
	"backend/internal/adapter/handler/app"
	brandhandler "backend/internal/adapter/handler/brand"
	carhandler "backend/internal/adapter/handler/car"
	mycarhandler "backend/internal/adapter/handler/mycar"
	"backend/internal/container"

	_ "backend/docs"

	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

func SetupRouter(c *container.Container) *gin.Engine {
	r := gin.Default()

	authHandler := app.NewAuthHandler(c.AuthUsecase, c.KakaoUsecase)
	marketingConsentHandler := app.NewMarketingConsentHandler(c.MarketingConsentUsecase)
	carHandler := carhandler.NewHandler(c.CarUsecase)
	brandHandler := brandhandler.NewHandler(c.BrandUsecase)
	myCarHandler := mycarhandler.NewHandler(c.MyCarUsecase)

	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	v1 := r.Group("/api/v1")
	{
		userGroup := v1.Group("/auth")
		{
			userGroup.POST("/onboard", authHandler.Onboarding)
			userGroup.POST("/kakao-login", authHandler.KakaoLogin)
			userGroup.POST("/agreed", marketingConsentHandler.SaveMarketingConsent)
		}

		carGroup := v1.Group("/cars")
		{
			carGroup.GET("", carHandler.List)

			carGroup.POST("/register", myCarHandler.RegisterMyCar)
			carGroup.GET("/register/:user_id", myCarHandler.GetMyCars)

			carGroup.GET("/:id", carHandler.GetDetail)
			carGroup.GET("/:id/images", carHandler.GetImages)
		}

		brandGroup := v1.Group("/brands")
		{
			brandGroup.GET("", brandHandler.List)
		}
	}

	return r
}
