package app

import (
	"backend/internal/adapter/handler/app/dto"
	"backend/internal/shared/errs"
	"backend/internal/shared/response"
	"backend/internal/usecase/auth"
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"
)

type AuthHandler struct {
	authUsecase auth.AuthUsecase
}

func NewAuthHandler(authUsecase auth.AuthUsecase) *AuthHandler {
	return &AuthHandler{authUsecase: authUsecase}
}

func (h *AuthHandler) Onboarding(c *gin.Context) {
	var req dto.OnboardingRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.SendError(c, http.StatusBadRequest, "요청 데이터가 올바르지 않습니다")
		return
	}

	result, err := h.authUsecase.Onboarding(c.Request.Context(), req.DeviceID, req.DeviceType)
	if err != nil {
		if errors.Is(err, errs.ErrConflict) {
			response.SendError(c, http.StatusConflict, "이미 등록된 디바이스입니다")
			return
		}
		response.SendError(c, http.StatusInternalServerError, "서버 오류가 발생했습니다")
		return
	}

	response.SendSuccess(c, http.StatusOK, dto.OnboardingResponse{
		TokenResponse: dto.TokenResponse{
			AccessToken:  result.AccessToken,
			RefreshToken: result.RefreshToken,
		},
	})
}

func (h *AuthHandler) Refresh(c *gin.Context) {
	var req dto.RefreshRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.SendError(c, http.StatusBadRequest, "요청 데이터가 올바르지 않습니다")
		return
	}

	result, err := h.authUsecase.Refresh(c.Request.Context(), req.RefreshToken)
	if err != nil {
		if errors.Is(err, errs.ErrUnauthorized) {
			response.SendError(c, http.StatusUnauthorized, "유효하지 않은 토큰입니다")
			return
		}
		if errors.Is(err, errs.ErrNotFound) {
			response.SendError(c, http.StatusNotFound, "토큰을 찾을 수 없습니다")
			return
		}
		response.SendError(c, http.StatusInternalServerError, "서버 오류가 발생했습니다")
		return
	}

	response.SendSuccess(c, http.StatusOK, TokenResponse{
		AccessToken:  result.AccessToken,
		RefreshToken: result.RefreshToken,
	})
}
