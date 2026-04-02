package app

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
)

type mockMarketingConsentUsecase struct {
	saveFn func(ctx context.Context, deviceID string, agreed bool) error
}

func (m *mockMarketingConsentUsecase) SaveMarketingConsent(ctx context.Context, deviceID string, agreed bool) error {
	return m.saveFn(ctx, deviceID, agreed)
}

func setupMarketingRouter(uc *mockMarketingConsentUsecase) *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := NewMarketingConsentHandler(uc)
	r.POST("/auth/agreed", h.SaveMarketingConsent)
	return r
}

func TestMarketingConsent_Success_Agreed(t *testing.T) {
	uc := &mockMarketingConsentUsecase{
		saveFn: func(_ context.Context, _ string, _ bool) error { return nil },
	}
	r := setupMarketingRouter(uc)

	body := map[string]any{
		"device_id":        "ANDROID-001",
		"marketing_agreed": true,
	}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/auth/agreed", bytes.NewReader(b))
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
	if int(resp["status"].(float64)) != 200 {
		t.Errorf("status 불일치: got %v", resp["status"])
	}
	if resp["message"] != "success" {
		t.Errorf("message 불일치: got %v", resp["message"])
	}
}

func TestMarketingConsent_Success_Disagreed(t *testing.T) {
	uc := &mockMarketingConsentUsecase{
		saveFn: func(_ context.Context, _ string, agreed bool) error {
			if agreed {
				t.Error("동의 false로 전달되어야 하는데 true가 왔습니다")
			}
			return nil
		},
	}
	r := setupMarketingRouter(uc)

	body := map[string]any{
		"device_id":        "ANDROID-001",
		"marketing_agreed": false,
	}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/auth/agreed", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", w.Code)
	}
}

func TestMarketingConsent_MissingDeviceID(t *testing.T) {
	uc := &mockMarketingConsentUsecase{}
	r := setupMarketingRouter(uc)

	body := map[string]any{"marketing_agreed": true} // device_id 누락
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/auth/agreed", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Fatalf("expected 400, got %d — body: %s", w.Code, w.Body.String())
	}
}

func TestMarketingConsent_InternalError(t *testing.T) {
	uc := &mockMarketingConsentUsecase{
		saveFn: func(_ context.Context, _ string, _ bool) error {
			return errors.New("db write failed")
		},
	}
	r := setupMarketingRouter(uc)

	body := map[string]any{
		"device_id":        "ANDROID-001",
		"marketing_agreed": true,
	}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/auth/agreed", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusInternalServerError {
		t.Fatalf("expected 500, got %d — body: %s", w.Code, w.Body.String())
	}
}
