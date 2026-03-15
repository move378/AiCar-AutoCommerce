package auth

import (
	"backend/internal/shared/response"
	"net/http"

	"github.com/gin-gonic/gin"
)

func (h *AuthHandler) GetProfile(c *gin.Context) {
	token, ok := c.Get("access_token")
	if !ok {
		response.SendError(c, http.StatusUnauthorized, response.CodeUnauthorized, "유효하지 않은 액세스 토큰입니다")
		return
	}

	accessToken := token.(string)

	profile, err := h.userUsecase.GetProfile(c.Request.Context(), accessToken)

	if err != nil {
		response.SendError(c, http.StatusInternalServerError, response.CodeInternalError, "로그아웃 처리중 오류가 발생했습니다.")
		return
	}

	response.SendSuccess(c, http.StatusOK, response.CodeSuccess, profile)
}

func (h *AuthHandler) Logout(c *gin.Context) {
	token, ok := c.Get("access_token")
	if !ok {
		response.SendError(c, http.StatusUnauthorized, response.CodeUnauthorized, "유효하지 않은 액세스 토큰입니다")
		return
	}

	accessToken := token.(string)
	err := h.authUsecase.Logout(c.Request.Context(), accessToken)
	if err != nil {
		response.SendError(c, http.StatusInternalServerError, response.CodeInternalError, "로그아웃 처리중 오류가 발생했습니다.")
		return
	}

	response.SendSuccess(c, http.StatusOK, response.CodeSuccess, nil)
}

// 프로필 핸들러 나중에 여기에 추가
