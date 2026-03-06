package router

import (
	"backend/internal/adapter/handler/app"
	"backend/internal/container"

	_ "backend/docs" // swag generate로 생성되는 폴더

	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

func SetupRouter(c *container.Container) *gin.Engine {
	r := gin.Default()

	authHandler := app.NewAuthHandler(c.AuthUsecase)

	// 미들웨어 설정 (필요시 CORS, 인증 등 추가 가능)
	// r.Use(CORSMiddleware())

	// Swagger UI 설정
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	v1 := r.Group("/api/v1")
	{

		userGroup := v1.Group("/auth")
		{
			userGroup.POST("/onboard", authHandler.Onboarding) // 초기 진입
			// userGroup.POST("/refresh", authApi.RefreshToken) // 토큰 재발급
		}

		// [차량 관련 경로 - 나중에 추가할 곳]
		// carGroup := v1.Group("/cars")
		// {
		//     carGroup.GET("/recommend", api.GetRecommendCars)
		// }
	}

	return r
}
