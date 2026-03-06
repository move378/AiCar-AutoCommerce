package app

import (
	"backend/internal/model"
	"backend/internal/shared/auth"
	"backend/internal/shared/response"
	"net/http"

	"github.com/gin-gonic/gin"
)

func InitUser(c *gin.Context) {
	var req model.OnboardingRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		response.SendError(c, http.StatusBadRequest, "기기 정보가 올바르지 않습니다.")
		return
	}

	accessToken, refreshToken, err := auth.GenerateTokens(req.DeviceID)
	if err != nil {
		response.SendError(c, http.StatusInternalServerError, "토큰 생성에 실패했습니다.")
		return
	}

	response.SendSuccess(c, http.StatusOK, model.OnboardingResponse{
		TokenResponse: model.TokenResponse{
			AccessToken:  accessToken,
			RefreshToken: refreshToken,
		},
	})
}
