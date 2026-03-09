package app

import (
	"backend/internal/adapter/handler/app/dto"
	"backend/internal/shared/errs"
	"backend/internal/shared/response"
	usecase "backend/internal/usecase/auth"
	"errors"
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type AuthHandler struct {
	authUsecase   usecase.AuthUsecase
	kakaoUsecase  usecase.KakaoUsecase
	googleUsecase usecase.GoogleUsecase
}

func NewAuthHandler(
	authUsecase usecase.AuthUsecase,
	kakaoUsecase usecase.KakaoUsecase,
	googleUsecase usecase.GoogleUsecase) *AuthHandler {
	return &AuthHandler{
		authUsecase:   authUsecase,
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
// @Failure     401 {object} response.APIResponse "유효하지 않은 토큰"
// @Failure     409 {object} response.APIResponse "이미 등록된 디바이스"
// @Failure     500 {object} response.APIResponse "서버 오류"
// @Security    ApiKeyAuth
// @Router      /auth/onboard [post]
func (h *AuthHandler) Onboarding(c *gin.Context) {
	var req dto.OnboardingRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.SendError(c, http.StatusBadRequest, response.CodeBadRequest, "요청 데이터가 올바르지 않습니다")
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

// @Summary     토큰 갱신
// @Description 리프레시 토큰으로 새 액세스/리프레시 토큰 발급
// @Tags        auth
// @Accept      json
// @Produce     json
// @Param       request body dto.RefreshRequest true "토큰 갱신 요청"
// @Success     200 {object} response.APIResponse{data=dto.TokenResponse} "토큰 갱신 성공"
// @Failure     400 {object} response.APIResponse "잘못된 요청"
// @Failure     401 {object} response.APIResponse "유효하지 않은 토큰"
// @Failure     404 {object} response.APIResponse "토큰 없음"
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

// @Summary     카카오 로그인
// @Description 카카오 액세스 토큰으로 소셜 로그인
// @Tags        auth
// @Accept      json
// @Produce     json
// @Security    BearerAuth
// @Param       request body dto.SocialLoginRequest true "카카오 로그인 요청"
// @Success     200 {object} response.APIResponse{data=dto.SocialTokenResponse} "카카오 로그인 성공"
// @Failure     400 {object} response.APIResponse "잘못된 요청"
// @Failure     401 {object} response.APIResponse "유효하지 않은 토큰"
// @Failure     500 {object} response.APIResponse "서버 오류"
// @Router      /auth/kakao-login [post]
func (h *AuthHandler) KakaoLogin(c *gin.Context) {
	var req dto.SocialLoginRequest

	userID, ok := c.Get("user_id")
	if !ok {
		response.SendError(c, http.StatusUnauthorized, response.CodeUnauthorized, "유효하지 않은 액세스 토큰입니다")
		return
	}
	userUUID := userID.(uuid.UUID)

	// 토큰을 실제로 파싱/검증할 필요가 있다면
	// h.authUsecase 또는 별도 헬퍼를 이용해 처리하세요

	if err := c.ShouldBindJSON(&req); err != nil {
		response.SendError(c, http.StatusBadRequest, response.CodeBadRequest, "카카오 액세스 토큰이 필요합니다.")
		return
	}

	fmt.Println("usecase 호출 전")
	result, err := h.kakaoUsecase.KakaoLogin(c.Request.Context(), userUUID, req.ProviderToken)

	if err != nil {
		response.SendError(c, http.StatusInternalServerError, response.CodeInternalError, "카카오 로그인 처리 중 오류가 발생했습니다.")
		return
	}

	response.SendSuccess(c, http.StatusOK, response.CodeSuccess, &dto.SocialTokenResponse{
		IsNewUser:    result.IsNewUser,
		AccessToken:  result.TokenResult.AccessToken,
		RefreshToken: result.TokenResult.RefreshToken,
	})
}

// @Summary     구글 로그인
// @Description 구글 ID 토큰으로 소셜 로그인
// @Tags        auth
// @Accept      json
// @Produce     json
// @Security    BearerAuth
// @Param       request body dto.SocialLoginRequest true "구글 로그인 요청"
// @Success     200 {object} response.APIResponse{data=dto.SocialTokenResponse} "구글 로그인 성공"
// @Failure     400 {object} response.APIResponse "잘못된 요청"
// @Failure     401 {object} response.APIResponse "유효하지 않은 토큰"
// @Failure     500 {object} response.APIResponse "서버 오류"
// @Router      /auth/google-login [post]
func (h *AuthHandler) GoogleLogin(c *gin.Context) {
	var req dto.SocialLoginRequest

	userID, ok := c.Get("user_id")
	if !ok {
		response.SendError(c, http.StatusUnauthorized, response.CodeUnauthorized, "유효하지 않은 액세스 토큰입니다")
		return
	}
	userUUID := userID.(uuid.UUID)

	if err := c.ShouldBindJSON(&req); err != nil {
		response.SendError(c, http.StatusBadRequest, response.CodeBadRequest, "구글 ID 토큰이 필요합니다.")
		return
	}

	result, err := h.googleUsecase.GoogleLogin(c.Request.Context(), userUUID, req.ProviderToken)
	if err != nil {
		response.SendError(c, http.StatusInternalServerError, response.CodeInternalError, "구글 로그인 처리 중 오류가 발생했습니다.")
		return
	}

	response.SendSuccess(c, http.StatusOK, response.CodeSuccess, &dto.SocialTokenResponse{
		IsNewUser:    result.IsNewUser,
		AccessToken:  result.TokenResult.AccessToken,
		RefreshToken: result.TokenResult.RefreshToken,
	})
}
