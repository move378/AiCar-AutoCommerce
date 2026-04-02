package auth

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"backend/internal/domain/entity"
	"backend/internal/shared/errs"
	"backend/internal/shared/token"
	authusecase "backend/internal/usecase/auth"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// --- mocks ---

type mockAuthUsecase struct {
	onboardingRefreshFn func(ctx context.Context, deviceUID string) (*token.TokenResult, error)
	refreshFn           func(ctx context.Context, refreshToken string) (*token.TokenResult, error)
}

func (m *mockAuthUsecase) OnboardingRefresh(ctx context.Context, deviceUID string) (*token.TokenResult, error) {
	return m.onboardingRefreshFn(ctx, deviceUID)
}
func (m *mockAuthUsecase) Refresh(ctx context.Context, refreshToken string) (*token.TokenResult, error) {
	return m.refreshFn(ctx, refreshToken)
}

type mockUserUsecase struct {
	onboardingFn      func(ctx context.Context, device *authusecase.OnboardingInput) (*token.TokenResult, error)
	logoutFn          func(ctx context.Context, accessToken string) error
	getProfileFn      func(ctx context.Context, accessToken string) (*authusecase.ProfileResult, error)
	deleteAccountFn   func(ctx context.Context, userID uuid.UUID) error
	socialLoginFn     func(ctx context.Context, info entity.SocialUserInfo) (*authusecase.SocialTokenResult, error)
}

func (m *mockUserUsecase) Onboarding(ctx context.Context, d *authusecase.OnboardingInput) (*token.TokenResult, error) {
	return m.onboardingFn(ctx, d)
}
func (m *mockUserUsecase) Logout(ctx context.Context, accessToken string) error {
	return m.logoutFn(ctx, accessToken)
}
func (m *mockUserUsecase) GetProfile(ctx context.Context, accessToken string) (*authusecase.ProfileResult, error) {
	return m.getProfileFn(ctx, accessToken)
}
func (m *mockUserUsecase) DeleteAccount(ctx context.Context, userID uuid.UUID) error {
	return m.deleteAccountFn(ctx, userID)
}
func (m *mockUserUsecase) SocialLoginOrRegister(ctx context.Context, info entity.SocialUserInfo) (*authusecase.SocialTokenResult, error) {
	return m.socialLoginFn(ctx, info)
}

type mockKakaoUsecase struct {
	loginFn func(ctx context.Context, userID uuid.UUID, token string) (*authusecase.SocialTokenResult, error)
}

func (m *mockKakaoUsecase) KakaoLogin(ctx context.Context, userID uuid.UUID, t string) (*authusecase.SocialTokenResult, error) {
	return m.loginFn(ctx, userID, t)
}

type mockGoogleUsecase struct {
	loginFn func(ctx context.Context, userID uuid.UUID, token string) (*authusecase.SocialTokenResult, error)
}

func (m *mockGoogleUsecase) GoogleLogin(ctx context.Context, userID uuid.UUID, t string) (*authusecase.SocialTokenResult, error) {
	return m.loginFn(ctx, userID, t)
}

type mockAppleUsecase struct {
	loginFn func(ctx context.Context, userID uuid.UUID, identityToken string, name *string) (*authusecase.SocialTokenResult, error)
}

func (m *mockAppleUsecase) AppleLogin(ctx context.Context, userID uuid.UUID, identityToken string, name *string) (*authusecase.SocialTokenResult, error) {
	return m.loginFn(ctx, userID, identityToken, name)
}

// --- helpers ---

var authTestUserID = uuid.MustParse("cccccccc-cccc-cccc-cccc-cccccccccccc")

func sampleTokenResult() *token.TokenResult {
	return &token.TokenResult{
		AccessToken:  "access.token.here",
		RefreshToken: "refresh.token.here",
	}
}

func sampleSocialResult(isNew bool) *authusecase.SocialTokenResult {
	return &authusecase.SocialTokenResult{
		IsNewUser: isNew,
		TokenResult: token.TokenResult{
			AccessToken:  "access.token.here",
			RefreshToken: "refresh.token.here",
		},
	}
}

func setupAuthRouter(
	authUC authusecase.AuthUsecase,
	userUC authusecase.UserUsecase,
	kakaoUC authusecase.KakaoUsecase,
	googleUC authusecase.GoogleUsecase,
	appleUC authusecase.AppleUsecase,
) *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := NewAuthHandler(authUC, userUC, kakaoUC, googleUC, appleUC)

	authMiddleware := func(c *gin.Context) {
		c.Set("user_id", authTestUserID)
		c.Set("access_token", "access.token.here")
		c.Next()
	}

	pub := r.Group("/auth")
	pub.POST("/onboard", h.Onboarding)
	pub.POST("/onboard/refresh", h.OnboardingRefresh)
	pub.POST("/refresh", h.Refresh)

	priv := r.Group("/auth", authMiddleware)
	priv.POST("/kakao-login", h.KakaoLogin)
	priv.POST("/google-login", h.GoogleLogin)
	priv.POST("/apple-login", h.AppleLogin)

	user := r.Group("/user", authMiddleware)
	user.POST("/logout", h.Logout)
	user.GET("/me", h.GetProfile)
	user.DELETE("/me", h.DeleteAccount)

	return r
}

// ============================================================
// POST /auth/onboard
// ============================================================

func TestOnboarding_Success(t *testing.T) {
	userUC := &mockUserUsecase{
		onboardingFn: func(_ context.Context, _ *authusecase.OnboardingInput) (*token.TokenResult, error) {
			return sampleTokenResult(), nil
		},
	}
	r := setupAuthRouter(&mockAuthUsecase{}, userUC, &mockKakaoUsecase{}, &mockGoogleUsecase{}, &mockAppleUsecase{})

	body := map[string]any{
		"device_id":   "ANDROID-001",
		"device_type": "android",
	}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/auth/onboard", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d — body: %s", w.Code, w.Body.String())
	}
	var resp map[string]any
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("응답 파싱 실패: %v", err)
	}
	data := resp["data"].(map[string]any)
	if data["access_token"] != "access.token.here" {
		t.Errorf("access_token 불일치: got %v", data["access_token"])
	}
	if data["refresh_token"] != "refresh.token.here" {
		t.Errorf("refresh_token 불일치: got %v", data["refresh_token"])
	}
}

func TestOnboarding_MissingFields(t *testing.T) {
	r := setupAuthRouter(&mockAuthUsecase{}, &mockUserUsecase{}, &mockKakaoUsecase{}, &mockGoogleUsecase{}, &mockAppleUsecase{})

	body := map[string]any{"device_id": "ANDROID-001"} // device_type 누락
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/auth/onboard", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Fatalf("expected 400, got %d", w.Code)
	}
}

func TestOnboarding_Conflict(t *testing.T) {
	userUC := &mockUserUsecase{
		onboardingFn: func(_ context.Context, _ *authusecase.OnboardingInput) (*token.TokenResult, error) {
			return nil, errs.ErrConflict
		},
	}
	r := setupAuthRouter(&mockAuthUsecase{}, userUC, &mockKakaoUsecase{}, &mockGoogleUsecase{}, &mockAppleUsecase{})

	body := map[string]any{"device_id": "ANDROID-001", "device_type": "android"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/auth/onboard", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusConflict {
		t.Fatalf("expected 409, got %d", w.Code)
	}
}

// ============================================================
// POST /auth/onboard/refresh
// ============================================================

func TestOnboardingRefresh_Success(t *testing.T) {
	authUC := &mockAuthUsecase{
		onboardingRefreshFn: func(_ context.Context, _ string) (*token.TokenResult, error) {
			return sampleTokenResult(), nil
		},
	}
	r := setupAuthRouter(authUC, &mockUserUsecase{}, &mockKakaoUsecase{}, &mockGoogleUsecase{}, &mockAppleUsecase{})

	body := map[string]any{"device_id": "ANDROID-001"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/auth/onboard/refresh", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d — body: %s", w.Code, w.Body.String())
	}
}

func TestOnboardingRefresh_DeviceNotFound(t *testing.T) {
	authUC := &mockAuthUsecase{
		onboardingRefreshFn: func(_ context.Context, _ string) (*token.TokenResult, error) {
			return nil, errs.ErrNotFound
		},
	}
	r := setupAuthRouter(authUC, &mockUserUsecase{}, &mockKakaoUsecase{}, &mockGoogleUsecase{}, &mockAppleUsecase{})

	body := map[string]any{"device_id": "nonexistent"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/auth/onboard/refresh", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusNotFound {
		t.Fatalf("expected 404, got %d", w.Code)
	}
}

func TestOnboardingRefresh_AlreadyRegistered(t *testing.T) {
	authUC := &mockAuthUsecase{
		onboardingRefreshFn: func(_ context.Context, _ string) (*token.TokenResult, error) {
			return nil, errs.ErrForbidden
		},
	}
	r := setupAuthRouter(authUC, &mockUserUsecase{}, &mockKakaoUsecase{}, &mockGoogleUsecase{}, &mockAppleUsecase{})

	body := map[string]any{"device_id": "ANDROID-001"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/auth/onboard/refresh", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusForbidden {
		t.Fatalf("expected 403, got %d", w.Code)
	}
}

// ============================================================
// POST /auth/refresh
// ============================================================

func TestRefresh_Success(t *testing.T) {
	authUC := &mockAuthUsecase{
		refreshFn: func(_ context.Context, _ string) (*token.TokenResult, error) {
			return sampleTokenResult(), nil
		},
	}
	r := setupAuthRouter(authUC, &mockUserUsecase{}, &mockKakaoUsecase{}, &mockGoogleUsecase{}, &mockAppleUsecase{})

	body := map[string]any{"refresh_token": "some.refresh.token"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/auth/refresh", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d — body: %s", w.Code, w.Body.String())
	}
	var resp map[string]any
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("응답 파싱 실패: %v", err)
	}
	data := resp["data"].(map[string]any)
	if data["access_token"] == nil {
		t.Error("access_token이 없습니다")
	}
}

func TestRefresh_MissingToken(t *testing.T) {
	r := setupAuthRouter(&mockAuthUsecase{}, &mockUserUsecase{}, &mockKakaoUsecase{}, &mockGoogleUsecase{}, &mockAppleUsecase{})

	req := httptest.NewRequest(http.MethodPost, "/auth/refresh", bytes.NewReader([]byte(`{}`)))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Fatalf("expected 400, got %d", w.Code)
	}
}

func TestRefresh_InvalidToken(t *testing.T) {
	authUC := &mockAuthUsecase{
		refreshFn: func(_ context.Context, _ string) (*token.TokenResult, error) {
			return nil, errs.ErrUnauthorized
		},
	}
	r := setupAuthRouter(authUC, &mockUserUsecase{}, &mockKakaoUsecase{}, &mockGoogleUsecase{}, &mockAppleUsecase{})

	body := map[string]any{"refresh_token": "invalid.token"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/auth/refresh", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401, got %d", w.Code)
	}
}

// ============================================================
// POST /auth/kakao-login
// ============================================================

func TestKakaoLogin_Success(t *testing.T) {
	kakaoUC := &mockKakaoUsecase{
		loginFn: func(_ context.Context, _ uuid.UUID, _ string) (*authusecase.SocialTokenResult, error) {
			return sampleSocialResult(true), nil
		},
	}
	r := setupAuthRouter(&mockAuthUsecase{}, &mockUserUsecase{}, kakaoUC, &mockGoogleUsecase{}, &mockAppleUsecase{})

	body := map[string]any{"provider_token": "kakao.access.token"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/auth/kakao-login", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d — body: %s", w.Code, w.Body.String())
	}
	var resp map[string]any
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("응답 파싱 실패: %v", err)
	}
	data := resp["data"].(map[string]any)
	if data["is_new_user"] != true {
		t.Errorf("is_new_user 불일치: got %v", data["is_new_user"])
	}
}

func TestKakaoLogin_MissingProviderToken(t *testing.T) {
	r := setupAuthRouter(&mockAuthUsecase{}, &mockUserUsecase{}, &mockKakaoUsecase{}, &mockGoogleUsecase{}, &mockAppleUsecase{})

	req := httptest.NewRequest(http.MethodPost, "/auth/kakao-login", bytes.NewReader([]byte(`{}`)))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Fatalf("expected 400, got %d", w.Code)
	}
}

// ============================================================
// POST /auth/google-login
// ============================================================

func TestGoogleLogin_Success(t *testing.T) {
	googleUC := &mockGoogleUsecase{
		loginFn: func(_ context.Context, _ uuid.UUID, _ string) (*authusecase.SocialTokenResult, error) {
			return sampleSocialResult(false), nil
		},
	}
	r := setupAuthRouter(&mockAuthUsecase{}, &mockUserUsecase{}, &mockKakaoUsecase{}, googleUC, &mockAppleUsecase{})

	body := map[string]any{"provider_token": "google.id.token"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/auth/google-login", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d — body: %s", w.Code, w.Body.String())
	}
}

// ============================================================
// POST /auth/apple-login
// ============================================================

func TestAppleLogin_Success(t *testing.T) {
	appleUC := &mockAppleUsecase{
		loginFn: func(_ context.Context, _ uuid.UUID, _ string, _ *string) (*authusecase.SocialTokenResult, error) {
			return sampleSocialResult(true), nil
		},
	}
	r := setupAuthRouter(&mockAuthUsecase{}, &mockUserUsecase{}, &mockKakaoUsecase{}, &mockGoogleUsecase{}, appleUC)

	body := map[string]any{"identity_token": "apple.identity.token"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/auth/apple-login", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d — body: %s", w.Code, w.Body.String())
	}
}

// ============================================================
// POST /user/logout
// ============================================================

func TestLogout_Success(t *testing.T) {
	userUC := &mockUserUsecase{
		logoutFn: func(_ context.Context, _ string) error { return nil },
	}
	r := setupAuthRouter(&mockAuthUsecase{}, userUC, &mockKakaoUsecase{}, &mockGoogleUsecase{}, &mockAppleUsecase{})

	req := httptest.NewRequest(http.MethodPost, "/user/logout", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d — body: %s", w.Code, w.Body.String())
	}
}

// ============================================================
// GET /user/me
// ============================================================

func TestGetProfile_Success(t *testing.T) {
	name := "홍길동"
	userUC := &mockUserUsecase{
		getProfileFn: func(_ context.Context, _ string) (*authusecase.ProfileResult, error) {
			return &authusecase.ProfileResult{Name: &name}, nil
		},
	}
	r := setupAuthRouter(&mockAuthUsecase{}, userUC, &mockKakaoUsecase{}, &mockGoogleUsecase{}, &mockAppleUsecase{})

	req := httptest.NewRequest(http.MethodGet, "/user/me", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d — body: %s", w.Code, w.Body.String())
	}
	var resp map[string]any
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("응답 파싱 실패: %v", err)
	}
	data := resp["data"].(map[string]any)
	if data["name"] != name {
		t.Errorf("name 불일치: got %v", data["name"])
	}
}

// ============================================================
// DELETE /user/me
// ============================================================

func TestDeleteAccount_Success(t *testing.T) {
	userUC := &mockUserUsecase{
		deleteAccountFn: func(_ context.Context, _ uuid.UUID) error { return nil },
	}
	r := setupAuthRouter(&mockAuthUsecase{}, userUC, &mockKakaoUsecase{}, &mockGoogleUsecase{}, &mockAppleUsecase{})

	req := httptest.NewRequest(http.MethodDelete, "/user/me", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d — body: %s", w.Code, w.Body.String())
	}
}
