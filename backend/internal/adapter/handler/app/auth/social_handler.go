package auth

import (
	"backend/internal/adapter/handler/app/dto"
	"backend/internal/shared/errs"
	"backend/internal/shared/response"
	"errors"
	"net/http"
	"fmt"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

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

	if err := c.ShouldBindJSON(&req); err != nil {
		response.SendError(c, http.StatusBadRequest, response.CodeBadRequest, "카카오 액세스 토큰이 필요합니다.")
		return
	}

	result, err := h.kakaoUsecase.KakaoLogin(c.Request.Context(), userUUID, req.ProviderToken)

	if errors.Is(err, errs.ErrNotFound) {
		response.SendError(c, http.StatusNotFound, response.CodeNotFound, "디바이스 유저를 찾을 수 없습니다")
		return
	}
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

	if errors.Is(err, errs.ErrNotFound) {
		response.SendError(c, http.StatusNotFound, response.CodeNotFound, "디바이스 유저를 찾을 수 없습니다")
		return
	}
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


// @Summary     애플 로그인
// @Description 애플 ID 토큰으로 소셜 로그인
// @Tags        auth
// @Accept      json
// @Produce     json
// @Security    BearerAuth
// @Param       request body dto.SocialLoginRequest true "애플 로그인 요청"
// @Success     200 {object} response.APIResponse{data=dto.SocialTokenResponse} "애플 로그인 성공"
// @Failure     400 {object} response.APIResponse "잘못된 요청"
// @Failure     401 {object} response.APIResponse "유효하지 않은 토큰"
// @Failure     500 {object} response.APIResponse "서버 오류"
// @Router      /auth/google-login [post]
func (h *AuthHandler) AppleLogin(c *gin.Context) {
	var req dto.AppleLoginRequest

	userID, ok := c.Get("user_id")

	if !ok {
		response.SendError(c, http.StatusUnauthorized, response.CodeUnauthorized, "유효하지 않은 액세스 토큰입니다")
		return
	}
	userUUID := userID.(uuid.UUID)

	fmt.Println(userUUID)

	if err := c.ShouldBindJSON(&req); err != nil {
		response.SendError(c, http.StatusBadRequest, response.CodeBadRequest, "애플 액세스 토큰이 필요합니다.")
		return
	}


	fmt.Println("애플 토큰",req.IdentityToken)

	// result, err := h.googleUsecase.GoogleLogin(c.Request.Context(), userUUID, req.ProviderToken)

	// if errors.Is(err, errs.ErrNotFound) {
	// 	response.SendError(c, http.StatusNotFound, response.CodeNotFound, "디바이스 유저를 찾을 수 없습니다")
	// 	return
	// }
	// if err != nil {
	// 	response.SendError(c, http.StatusInternalServerError, response.CodeInternalError, "구글 로그인 처리 중 오류가 발생했습니다.")
	// 	return
	// }
	response.SendSuccess(c, http.StatusOK, response.CodeSuccess,nil)
	// response.SendSuccess(c, http.StatusOK, response.CodeSuccess, &dto.SocialTokenResponse{
	// 	IsNewUser:    result.IsNewUser,
	// 	AccessToken:  result.TokenResult.AccessToken,
	// 	RefreshToken: result.TokenResult.RefreshToken,
	// })
}
