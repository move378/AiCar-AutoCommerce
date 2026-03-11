package auth

import (
	"backend/internal/adapter/handler/app/dto"
	"backend/internal/shared/errs"
	"backend/internal/shared/response"
	usecase "backend/internal/usecase/auth"
	"errors"
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
)

type AuthHandler struct {
	authUsecase   usecase.AuthUsecase
	kakaoUsecase  usecase.KakaoUsecase
	googleUsecase usecase.GoogleUsecase
	userUsecase   usecase.UserUsecase
}

func NewAuthHandler(
	authUsecase usecase.AuthUsecase,
	userUsecase usecase.UserUsecase,
	kakaoUsecase usecase.KakaoUsecase,
	googleUsecase usecase.GoogleUsecase) *AuthHandler {
	return &AuthHandler{
		authUsecase:   authUsecase,
		userUsecase:   userUsecase,
		kakaoUsecase:  kakaoUsecase,
		googleUsecase: googleUsecase,
	}
}

// @Summary     온보딩
// @Description 디바이스 등록 + 유저 생성 + 토큰 발급
// @Tags        auth
// @Accept      json
// @Produce     json
// @Param       request body dto.OnboardingRequest true "온보딩 요청"
// @Success     200 {object} response.APIResponse{data=dto.OnboardingResponse} "온보딩 성공"
// @Failure     400 {object} response.APIResponse "잘못된 요청"
// @Failure     409 {object} response.APIResponse "이미 등록된 디바이스"
// @Failure     500 {object} response.APIResponse "서버 오류"
// @Router      /auth/onboard [post]
func (h *AuthHandler) Onboarding(c *gin.Context) {
	var req dto.OnboardingRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.SendError(c, http.StatusBadRequest, response.CodeBadRequest, "요청 데이터가 올바르지 않습니다.")
		return
	}

	result, err := h.authUsecase.Onboarding(c.Request.Context(), &usecase.OnboardingInput{
		DeviceUID:  req.DeviceID,
		DeviceType: req.DeviceType,
		ModelName:  req.ModelName,
		OSVersion:  req.OSVersion,
		Latitude:   req.Latitude,
		Longitude:  req.Longitude,
	})

	fmt.Println("Onboarding result:", result)
	fmt.Println("Onboarding err:", err)
	if err != nil {
		if errors.Is(err, errs.ErrConflict) {
			response.SendError(c, http.StatusConflict, response.CodeConflict, "이미 등록된 디바이스입니다")
			return
		}
		response.SendError(c, http.StatusInternalServerError, response.CodeInternalError, "서버 오류가 발생했습니다")
		return
	}

	response.SendSuccess(c, http.StatusOK, response.CodeSuccess, dto.OnboardingResponse{
		TokenResponse: dto.TokenResponse{
			AccessToken:  result.AccessToken,
			RefreshToken: result.RefreshToken,
		},
	})
}

func (h *AuthHandler) OnboardingRefresh(c *gin.Context) {
	var req dto.OnboardingRefreshRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		response.SendError(c, http.StatusBadRequest, response.CodeBadRequest, "요청 데이터가 올바르지 않습니다.")
		return
	}

	result, err := h.authUsecase.OnboardingRefresh(c.Request.Context(), req.DeviceID)

	if errors.Is(err, errs.ErrNotFound) {
		response.SendError(c, http.StatusNotFound, response.CodeNotFound, "디바이스를 찾을 수 없습니다")
		return
	}
	if errors.Is(err, errs.ErrForbidden) {
		response.SendError(c, http.StatusForbidden, response.CodeForbidden, "이미 회원가입된 유저입니다")
		return
	}
	if err != nil {
		response.SendError(c, http.StatusInternalServerError, response.CodeInternalError, "토큰 재발급 실패")
		return
	}

	response.SendSuccess(c, http.StatusOK, response.CodeSuccess, dto.TokenResponse{
		AccessToken:  result.AccessToken,
		RefreshToken: result.RefreshToken,
	})
}

// @Summary     토큰 갱신
// @Description 리프레시 토큰으로 새 액세스/리프레시 토큰 발급
// @Tags        auth
// @Accept      json
// @Produce     json
// @Param       request body dto.RefreshRequest true "토큰 갱신 요청"
// @Success     200 {object} response.APIResponse{data=dto.TokenResponse} "토큰 갱신 성공"
// @Failure     400 {object} response.APIResponse "잘못된 요청"
// @Failure     401 {object} response.APIResponse "유효하지 않은 토큰"
// @Failure     500 {object} response.APIResponse "서버 오류"
// @Router      /auth/refresh [post]
func (h *AuthHandler) Refresh(c *gin.Context) {
	var req dto.RefreshRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.SendError(c, http.StatusBadRequest, response.CodeBadRequest, "요청 데이터가 올바르지 않습니다")
		return
	}

	result, err := h.authUsecase.Refresh(c.Request.Context(), req.RefreshToken)
	if err != nil {
		if errors.Is(err, errs.ErrUnauthorized) {
			response.SendError(c, http.StatusUnauthorized, response.CodeUnauthorized, "유효하지 않은 토큰입니다")
			return
		}
		if errors.Is(err, errs.ErrNotFound) {
			response.SendError(c, http.StatusNotFound, response.CodeNotFound, "토큰을 찾을 수 없습니다")
			return
		}
		response.SendError(c, http.StatusInternalServerError, response.CodeInternalError, "서버 오류가 발생했습니다")
		return
	}

	response.SendSuccess(c, http.StatusOK, response.CodeSuccess, dto.TokenResponse{
		AccessToken:  result.AccessToken,
		RefreshToken: result.RefreshToken,
	})
}
