package router

import (
	"backend/internal/adapter/handler/app"

	"github.com/gin-gonic/gin"
)

func SetupRouter() *gin.Engine {
	r := gin.Default()

	var authApi app.AuthHandler

	// 미들웨어 설정 (필요시 CORS, 인증 등 추가 가능)
	// r.Use(CORSMiddleware())

	v1 := r.Group("/api/v1")
	{
		userGroup := v1.Group("/users")
		{
			userGroup.POST("/init", authApi.Onboarding) // 초기 진입
			//userGroup.POST("/refresh", api.RefreshToken) // 토큰 재발급
		}

		// [차량 관련 경로 - 나중에 추가할 곳]
		// carGroup := v1.Group("/cars")
		// {
		//     carGroup.GET("/recommend", api.GetRecommendCars)
		// }
	}

	return r
}
