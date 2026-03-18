package router

import (
	"backend/internal/adapter/handler/app"
	"backend/internal/adapter/handler/app/auth"
	brandhandler "backend/internal/adapter/handler/brand"
	carhandler "backend/internal/adapter/handler/car"
	mycarhandler "backend/internal/adapter/handler/mycar"
	"backend/internal/adapter/middleware"
	"backend/internal/container"

	_ "backend/docs"

	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

func SetupRouter(c *container.Container) *gin.Engine {
	r := gin.Default()

	authHandler := auth.NewAuthHandler(c.AuthUsecase, c.UserUsecase, c.KakaoUsecase, c.GoogleUsecase, c.AppleUsecase)
	marketingConsentHandler := app.NewMarketingConsentHandler(c.MarketingConsentUsecase)
	carHandler := carhandler.NewHandler(c.CarUsecase)
	brandHandler := brandhandler.NewHandler(c.BrandUsecase)
	myCarHandler := mycarhandler.NewHandler(c.MyCarUsecase)

	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	//애플 테스트 html
	r.StaticFile("/apple-test", "./apple-test.html")

	v1 := r.Group("/api/v1")

	public := v1.Group("/")
	private := v1.Group("/")
	private.Use(middleware.AuthMiddleware(c.TokenCache))
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
		// Public Routes
		publicAuth := public.Group("/auth")
		{
			publicAuth.POST("/onboard", authHandler.Onboarding)
			publicAuth.POST("/onboard/refresh", authHandler.OnboardingRefresh)
			publicAuth.POST("/refresh", authHandler.Refresh)
		}

		// Private Routes
		privateAuth := private.Group("/auth")
		privateUser := private.Group("/user")
		{
			privateAuth.POST("/kakao-login", authHandler.KakaoLogin)
			privateAuth.POST("/google-login", authHandler.GoogleLogin)
			privateAuth.POST("/apple-login", authHandler.AppleLogin)

		}

		{
			privateUser.POST("/logout", authHandler.Logout)
			privateUser.GET("/me", authHandler.GetProfile)
			privateUser.DELETE("/me", authHandler.DeleteAccount)
		}

		// Private Cars (나중에)
		// privateCars := private.Group("/cars")
		// [차량 관련 경로 - 나중에 추가할 곳]
		// carGroup := v1.Group("/cars")
		// {
		//     carGroup.GET("/recommend", api.GetRecommendCars)
		// }
	}

	return r
}
