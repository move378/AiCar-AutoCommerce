package auth

import (
	"backend/internal/shared/response"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
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
	err := h.userUsecase.Logout(c.Request.Context(), accessToken)
	if err != nil {
		response.SendError(c, http.StatusInternalServerError, response.CodeInternalError, "로그아웃 처리중 오류가 발생했습니다.")
		return
	}

	response.SendSuccess(c, http.StatusOK, response.CodeSuccess, nil)
}

func (h *AuthHandler) DeleteAccount(c *gin.Context) {
	userID, ok := c.Get("user_id")

	if !ok {
		response.SendError(c, http.StatusUnauthorized, response.CodeUnauthorized, "유효하지 않은 액세스 토큰입니다")
		return
	}

	userUUID := userID.(uuid.UUID)

	if err := h.userUsecase.DeleteAccount(c.Request.Context(), userUUID); err != nil {
		response.SendError(c, http.StatusUnauthorized, response.CodeUnauthorized, "탈퇴 처리에 오류가 발생했습니다.")
		return
	}

	response.SendSuccess(c, http.StatusOK, response.CodeSuccess, nil)
}
