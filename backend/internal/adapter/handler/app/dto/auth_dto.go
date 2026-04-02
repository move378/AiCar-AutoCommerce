package dto

// =============================================================================
// [REQUEST DTO] - 클라이언트로부터 받는 데이터 (Input)
// =============================================================================

type OnboardingRequest struct {
	DeviceID   string   `json:"device_id" binding:"required" example:"ANDROID-DEVICE-789"`
	DeviceType string   `json:"device_type" binding:"required,oneof=ios android" example:"android" enums:"ios,android"`
	ModelName  string   `json:"model_name" example:"Galaxy S24"`
	OSVersion  string   `json:"os_version" example:"14.0"`
	Latitude   *float64 `json:"latitude" example:"37.5665"`
	Longitude  *float64 `json:"longitude" example:"126.9780"`
}

type OnboardingRefreshRequest struct {
	DeviceID string `json:"device_id" binding:"required" example:"ANDROID-DEVICE-789"`
}

type RefreshRequest struct {
	RefreshToken string `json:"refresh_token" binding:"required" example:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."`
}

type SocialLoginRequest struct {
	ProviderToken string `json:"provider_token" binding:"required" example:"ya29.a0AfH6SMBx..."`
}

type AppleLoginRequest struct {
	UserName string `json:"user_name" example:"홍길동"`
	IdentityToken string `json:"identity_token" binding:"required" example:"ya29.a0AfH6SMBx..."`
}

// =============================================================================
// [RESPONSE DTO] - 클라이언트에게 돌려주는 데이터 (Output)
// =============================================================================

type TokenResponse struct {
	AccessToken  string `json:"access_token" example:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."`
	RefreshToken string `json:"refresh_token" example:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."`
}

type SocialTokenResponse struct {
	IsNewUser    bool   `json:"is_new_user" example:"true"`
	AccessToken  string `json:"access_token" example:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."`
	RefreshToken string `json:"refresh_token" example:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."`
}

type OnboardingResponse struct {
	TokenResponse
}
