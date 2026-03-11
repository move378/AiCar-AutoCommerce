package router

import (
	"backend/internal/adapter/handler/app"
	"backend/internal/adapter/middleware"
	"backend/internal/container"

	_ "backend/docs" // swag generate로 생성되는 폴더

	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

func SetupRouter(c *container.Container) *gin.Engine {
	r := gin.Default()

	authHandler := app.NewAuthHandler(c.AuthUsecase, c.KakaoUsecase, c.GoogleUsecase)

	// 미들웨어 설정 (필요시 CORS, 인증 등 추가 가능)
	// r.Use(CORSMiddleware())

	// Swagger UI 설정
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	v1 := r.Group("/api/v1")

	public := v1.Group("/")
	private := v1.Group("/")
	private.Use(middleware.AuthMiddleware(c.TokenCache))
	{
		// Public Routes
		publicAuth := public.Group("/auth")
		{
			publicAuth.POST("/onboard", authHandler.Onboarding)
			publicAuth.POST("/onboard/refresh", authHandler.OnboardingRefresh)
			publicAuth.POST("/refresh", authHandler.Refresh)
		}

		// Private Routes
		privateAuth := private.Group("/auth")
		{
			privateAuth.POST("/kakao-login", authHandler.KakaoLogin)
			privateAuth.POST("/google-login", authHandler.GoogleLogin)
			// privateAuth.POST("/apple-login", authHandler.AppleLogin)
			privateAuth.POST("/logout", authHandler.Logout)
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
