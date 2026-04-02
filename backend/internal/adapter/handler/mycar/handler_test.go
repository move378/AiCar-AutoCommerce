package mycar

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"backend/internal/domain/entity"

	"github.com/gin-gonic/gin"
)

type mockMyCarUsecase struct {
	registerFn     func(ctx context.Context, userID, licensePlate string) (string, error)
	getByUserIDFn  func(ctx context.Context, userID string) ([]entity.MyCar, error)
}

func (m *mockMyCarUsecase) RegisterMyCar(ctx context.Context, userID, licensePlate string) (string, error) {
	return m.registerFn(ctx, userID, licensePlate)
}
func (m *mockMyCarUsecase) GetMyCarsByUserID(ctx context.Context, userID string) ([]entity.MyCar, error) {
	return m.getByUserIDFn(ctx, userID)
}

func setupMyCarRouter(uc *mockMyCarUsecase) *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := NewHandler(uc)
	r.POST("/cars/register", h.RegisterMyCar)
	r.GET("/cars/register/:user_id", h.GetMyCars)
	return r
}

// ============================================================
// POST /cars/register
// ============================================================

func TestRegisterMyCar_Success(t *testing.T) {
	uc := &mockMyCarUsecase{
		registerFn: func(_ context.Context, _, _ string) (string, error) {
			return "mycar-001", nil
		},
	}
	r := setupMyCarRouter(uc)

	body := map[string]any{
		"user_id":       "user-001",
		"license_plate": "12가3456",
	}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/cars/register", bytes.NewReader(b))
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
	if resp["mycar_id"] != "mycar-001" {
		t.Errorf("mycar_id 불일치: got %v", resp["mycar_id"])
	}
	if int(resp["status"].(float64)) != 200 {
		t.Errorf("status 불일치: got %v", resp["status"])
	}
}

func TestRegisterMyCar_MissingFields(t *testing.T) {
	uc := &mockMyCarUsecase{}
	r := setupMyCarRouter(uc)

	body := map[string]any{"user_id": "user-001"} // license_plate 누락
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/cars/register", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Fatalf("expected 400, got %d — body: %s", w.Code, w.Body.String())
	}
}

func TestRegisterMyCar_AlreadyRegistered(t *testing.T) {
	uc := &mockMyCarUsecase{
		registerFn: func(_ context.Context, _, _ string) (string, error) {
			return "", errors.New("car already registered")
		},
	}
	r := setupMyCarRouter(uc)

	body := map[string]any{
		"user_id":       "user-001",
		"license_plate": "12가3456",
	}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/cars/register", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusConflict {
		t.Fatalf("expected 409, got %d — body: %s", w.Code, w.Body.String())
	}
}

func TestRegisterMyCar_CarNotFound(t *testing.T) {
	uc := &mockMyCarUsecase{
		registerFn: func(_ context.Context, _, _ string) (string, error) {
			return "", errors.New("car info not found")
		},
	}
	r := setupMyCarRouter(uc)

	body := map[string]any{
		"user_id":       "user-001",
		"license_plate": "99xx9999",
	}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/cars/register", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusNotFound {
		t.Fatalf("expected 404, got %d — body: %s", w.Code, w.Body.String())
	}
}

// ============================================================
// GET /cars/register/:user_id
// ============================================================

func TestGetMyCars_Success(t *testing.T) {
	now := time.Now()
	uc := &mockMyCarUsecase{
		getByUserIDFn: func(_ context.Context, _ string) ([]entity.MyCar, error) {
			return []entity.MyCar{
				{ID: "mc-001", UserID: "user-001", LicensePlate: "12가3456", Brand: "Hyundai", Model: "Avante", Year: 2022, FuelType: "Gasoline", CreatedAt: now, UpdatedAt: now},
			}, nil
		},
	}
	r := setupMyCarRouter(uc)

	req := httptest.NewRequest(http.MethodGet, "/cars/register/user-001", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d — body: %s", w.Code, w.Body.String())
	}
	var resp map[string]any
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("응답 파싱 실패: %v", err)
	}
	data, ok := resp["data"].([]any)
	if !ok {
		t.Fatalf("data 필드가 배열이 아닙니다: %v", resp)
	}
	if len(data) != 1 {
		t.Errorf("data 개수 불일치: want 1, got %d", len(data))
	}
	car := data[0].(map[string]any)
	if car["license_plate"] != "12가3456" {
		t.Errorf("license_plate 불일치: got %v", car["license_plate"])
	}
}

func TestGetMyCars_Empty(t *testing.T) {
	uc := &mockMyCarUsecase{
		getByUserIDFn: func(_ context.Context, _ string) ([]entity.MyCar, error) {
			return []entity.MyCar{}, nil
		},
	}
	r := setupMyCarRouter(uc)

	req := httptest.NewRequest(http.MethodGet, "/cars/register/user-999", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", w.Code)
	}
	var resp map[string]any
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("응답 파싱 실패: %v", err)
	}
	data := resp["data"].([]any)
	if len(data) != 0 {
		t.Errorf("빈 목록이어야 하는데 %d개 반환됨", len(data))
	}
}
