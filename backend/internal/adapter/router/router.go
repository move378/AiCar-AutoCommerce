package router

import (
	"backend/internal/adapter/handler/app"
	"backend/internal/adapter/handler/app/auth"
	brandhandler "backend/internal/adapter/handler/brand"
	carhandler "backend/internal/adapter/handler/car"
	chathandler "backend/internal/adapter/handler/chat"
	mycarhandler "backend/internal/adapter/handler/mycar"
	vehiclehandler "backend/internal/adapter/handler/vehicle"
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
	vehicleHandler := vehiclehandler.NewHandler(c.VehicleUsecase)
	chatHandler := chathandler.NewHandler(c.ChatUsecase)
	estimateHandler := app.NewEstimateHandler(c.EstimateUsecase)

	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	//애플 테스트 html
	r.StaticFile("/apple-test", "./apple-test.html")

	v1 := r.Group("/api/v1")

	public := v1.Group("/")
	private := v1.Group("/")
	private.Use(middleware.AuthMiddleware(c.TokenCache))
	{
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

		vehicleGroup := v1.Group("/vehicles")
		{
			vehicleGroup.GET("", vehicleHandler.Search)
			vehicleGroup.GET("/brands", vehicleHandler.ListBrands)
			vehicleGroup.GET("/:id", vehicleHandler.GetDetail)
		}

		// Public Routes
		publicAuth := public.Group("/auth")
		{
			publicAuth.POST("/onboard", authHandler.Onboarding)
			publicAuth.POST("/onboard/refresh", authHandler.OnboardingRefresh)
			publicAuth.POST("/refresh", authHandler.Refresh)
			publicAuth.POST("/agreed", marketingConsentHandler.SaveMarketingConsent)
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

		// Private Estimates
		privateEstimate := private.Group("/estimates")
		{
			privateEstimate.POST("", estimateHandler.Create)
			privateEstimate.GET("", estimateHandler.List)
			privateEstimate.GET("/:id", estimateHandler.GetByID)
		}

		// Private Chat
		privateChat := private.Group("/chat")
		{
			privateChat.POST("/sessions", chatHandler.CreateSession)
			privateChat.GET("/sessions", chatHandler.GetSessions)
			privateChat.DELETE("/sessions/:id", chatHandler.DeleteSession)
			privateChat.POST("/sessions/:id/messages", chatHandler.CreateMessage)
			privateChat.GET("/sessions/:id/messages", chatHandler.GetMessages)
			privateChat.PATCH("/messages/:id/feedback", chatHandler.UpdateFeedback)
		}
	}

	return r
}
