package dto

// =============================================================================
// [REQUEST DTO] - 클라이언트로부터 받는 데이터 (Input)
// =============================================================================

// OnboardingRequest: 앱 최초 진입 시 온보딩에 필요한 정보를 담습니다.
type OnboardingRequest struct {
	DeviceID   string `json:"device_id" binding:"required"`   // 필수값
	DeviceType string `json:"device_type" binding:"required"` // 필수값 (ios, android)
	ModelName  string `json:"model_name"`
	OSVersion  string `json:"os_version"`
}

// RefreshRequest: 토큰 갱신 요청 시 필요한 정보입니다.
type RefreshRequest struct {
	RefreshToken string `json:"refresh_token" binding:"required"`
}

type KakaoLoginRequest struct {
	KakaoAccessToken string `json:"kakao_access_token" binding:"required"`
}

type GoogleLoginRequest struct {
	GoogleAccessToken string `json:"google_access_token" binding:"required"`
}

type AppleLoginRequest struct {
	IdentityToken string `json:"identity_token" binding:"required"`
}

// =============================================================================
// [RESPONSE DTO] - 클라이언트에게 돌려주는 데이터 (Output)
// =============================================================================

// TokenResponse: 모든 인증 관련 API에서 공통으로 사용될 토큰 구조입니다.
type TokenResponse struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
}

// OnboardingResponse: 온보딩 성공 시 반환되는 결과입니다.
// TokenResponse를 임베딩하여 'data' 필드 안에 토큰 정보가 바로 담기게 합니다.
type OnboardingResponse struct {
	TokenResponse // AccessToken, RefreshToken 필드를 그대로 가져옴
}
