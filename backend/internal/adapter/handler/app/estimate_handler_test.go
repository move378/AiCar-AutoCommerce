package app

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"backend/internal/shared/errs"
	estimateusecase "backend/internal/usecase/estimate"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// --- mock ---

type mockEstimateUsecase struct {
	createFn      func(ctx context.Context, userID, trimID, chatSessionID string, promotionID *string) (*estimateusecase.EstimateResponse, error)
	getByIDFn     func(ctx context.Context, id, userID string) (*estimateusecase.EstimateResponse, error)
	getByUserIDFn func(ctx context.Context, userID string) ([]estimateusecase.EstimateResponse, error)
}

func (m *mockEstimateUsecase) Create(ctx context.Context, userID, trimID, chatSessionID string, promotionID *string) (*estimateusecase.EstimateResponse, error) {
	return m.createFn(ctx, userID, trimID, chatSessionID, promotionID)
}
func (m *mockEstimateUsecase) GetByID(ctx context.Context, id, userID string) (*estimateusecase.EstimateResponse, error) {
	return m.getByIDFn(ctx, id, userID)
}
func (m *mockEstimateUsecase) GetByUserID(ctx context.Context, userID string) ([]estimateusecase.EstimateResponse, error) {
	return m.getByUserIDFn(ctx, userID)
}

// --- 헬퍼 ---

var testUserID = uuid.MustParse("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa")

func setupEstimateRouter(uc estimateusecase.Usecase) *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New()

	// JWT 미들웨어 대신 user_id를 직접 주입하는 테스트용 미들웨어
	auth := func(c *gin.Context) {
		c.Set("user_id", testUserID)
		c.Next()
	}

	h := NewEstimateHandler(uc)
	g := r.Group("/estimates", auth)
	g.POST("", h.Create)
	g.GET("/:id", h.GetByID)
	g.GET("", h.List)
	return r
}

func sampleEstimate(id string) *estimateusecase.EstimateResponse {
	return &estimateusecase.EstimateResponse{
		ID:             id,
		TrimID:         "trim-0001",
		TrimName:       "E300 Avantgarde",
		ChatSessionID:  "session-0001",
		BasePrice:      75_000_000,
		DiscountAmount: 0,
		FinalPrice:     75_000_000,
		Status:         "draft",
		CreatedAt:      time.Now(),
	}
}

// ============================================================
// POST /estimates
// ============================================================

func TestEstimateCreate_Success(t *testing.T) {
	estID := "est-0001"
	uc := &mockEstimateUsecase{
		createFn: func(_ context.Context, _, _, _ string, _ *string) (*estimateusecase.EstimateResponse, error) {
			return sampleEstimate(estID), nil
		},
	}
	r := setupEstimateRouter(uc)

	body := map[string]any{
		"trim_id":         "trim-0001",
		"chat_session_id": "session-0001",
	}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/estimates", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()

	r.ServeHTTP(w, req)

	if w.Code != http.StatusCreated {
		t.Fatalf("expected 201, got %d — body: %s", w.Code, w.Body.String())
	}

	var resp estimateusecase.EstimateResponse
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("응답 파싱 실패: %v", err)
	}
	if resp.ID != estID {
		t.Errorf("id 불일치: want %q, got %q", estID, resp.ID)
	}
	if resp.FinalPrice != 75_000_000 {
		t.Errorf("final_price 불일치: want 75000000, got %d", resp.FinalPrice)
	}
}

func TestEstimateCreate_WithPromotion(t *testing.T) {
	promoID := "promo-0001"
	uc := &mockEstimateUsecase{
		createFn: func(_ context.Context, _, _, _ string, promotionID *string) (*estimateusecase.EstimateResponse, error) {
			resp := sampleEstimate("est-0002")
			resp.PromotionID = promotionID
			resp.DiscountAmount = 2_000_000
			resp.FinalPrice = 73_000_000
			return resp, nil
		},
	}
	r := setupEstimateRouter(uc)

	body := map[string]any{
		"trim_id":         "trim-0001",
		"chat_session_id": "session-0001",
		"promotion_id":    promoID,
	}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/estimates", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()

	r.ServeHTTP(w, req)

	if w.Code != http.StatusCreated {
		t.Fatalf("expected 201, got %d — body: %s", w.Code, w.Body.String())
	}

	var resp map[string]any
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("응답 파싱 실패: %v", err)
	}
	if resp["promotion_id"] != promoID {
		t.Errorf("promotion_id 불일치: want %q, got %v", promoID, resp["promotion_id"])
	}
	if int64(resp["discount_amount"].(float64)) != 2_000_000 {
		t.Errorf("discount_amount 불일치")
	}
	if int64(resp["final_price"].(float64)) != 73_000_000 {
		t.Errorf("final_price 불일치")
	}
}

func TestEstimateCreate_MissingFields(t *testing.T) {
	uc := &mockEstimateUsecase{}
	r := setupEstimateRouter(uc)

	// trim_id 누락
	body := map[string]any{"chat_session_id": "session-0001"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/estimates", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()

	r.ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Fatalf("expected 400, got %d — body: %s", w.Code, w.Body.String())
	}

	var resp map[string]any
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("응답 파싱 실패: %v", err)
	}
	if _, ok := resp["message"]; !ok {
		t.Error("message 필드가 없습니다")
	}
}

func TestEstimateCreate_TrimNotFound(t *testing.T) {
	uc := &mockEstimateUsecase{
		createFn: func(_ context.Context, _, _, _ string, _ *string) (*estimateusecase.EstimateResponse, error) {
			return nil, errs.ErrNotFound
		},
	}
	r := setupEstimateRouter(uc)

	body := map[string]any{
		"trim_id":         "nonexistent",
		"chat_session_id": "session-0001",
	}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/estimates", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()

	r.ServeHTTP(w, req)

	if w.Code != http.StatusNotFound {
		t.Fatalf("expected 404, got %d — body: %s", w.Code, w.Body.String())
	}
}

// ============================================================
// GET /estimates/:id
// ============================================================

func TestEstimateGetByID_Success(t *testing.T) {
	estID := "est-0001"
	uc := &mockEstimateUsecase{
		getByIDFn: func(_ context.Context, id, _ string) (*estimateusecase.EstimateResponse, error) {
			return sampleEstimate(id), nil
		},
	}
	r := setupEstimateRouter(uc)

	req := httptest.NewRequest(http.MethodGet, "/estimates/"+estID, nil)
	w := httptest.NewRecorder()

	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d — body: %s", w.Code, w.Body.String())
	}

	var resp estimateusecase.EstimateResponse
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("응답 파싱 실패: %v", err)
	}
	if resp.ID != estID {
		t.Errorf("id 불일치: want %q, got %q", estID, resp.ID)
	}
	if resp.TrimName == "" {
		t.Error("trim_name이 비어 있습니다")
	}
	if resp.Status != "draft" {
		t.Errorf("status 불일치: want draft, got %q", resp.Status)
	}
}

func TestEstimateGetByID_NotFound(t *testing.T) {
	uc := &mockEstimateUsecase{
		getByIDFn: func(_ context.Context, _, _ string) (*estimateusecase.EstimateResponse, error) {
			return nil, errs.ErrNotFound
		},
	}
	r := setupEstimateRouter(uc)

	req := httptest.NewRequest(http.MethodGet, "/estimates/nonexistent", nil)
	w := httptest.NewRecorder()

	r.ServeHTTP(w, req)

	if w.Code != http.StatusNotFound {
		t.Fatalf("expected 404, got %d — body: %s", w.Code, w.Body.String())
	}

	var resp map[string]any
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("응답 파싱 실패: %v", err)
	}
	if _, ok := resp["message"]; !ok {
		t.Error("message 필드가 없습니다")
	}
}

// ============================================================
// GET /estimates  (목록)
// ============================================================

func TestEstimateList_Success(t *testing.T) {
	uc := &mockEstimateUsecase{
		getByUserIDFn: func(_ context.Context, _ string) ([]estimateusecase.EstimateResponse, error) {
			return []estimateusecase.EstimateResponse{
				*sampleEstimate("est-0001"),
				*sampleEstimate("est-0002"),
			}, nil
		},
	}
	r := setupEstimateRouter(uc)

	req := httptest.NewRequest(http.MethodGet, "/estimates", nil)
	w := httptest.NewRecorder()

	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d — body: %s", w.Code, w.Body.String())
	}

	var resp map[string]any
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("응답 파싱 실패: %v", err)
	}
	items, ok := resp["items"].([]any)
	if !ok {
		t.Fatalf("items 필드가 없거나 배열이 아닙니다: %v", resp)
	}
	if len(items) != 2 {
		t.Errorf("items 개수 불일치: want 2, got %d", len(items))
	}
}

func TestEstimateList_Empty(t *testing.T) {
	uc := &mockEstimateUsecase{
		getByUserIDFn: func(_ context.Context, _ string) ([]estimateusecase.EstimateResponse, error) {
			return []estimateusecase.EstimateResponse{}, nil
		},
	}
	r := setupEstimateRouter(uc)

	req := httptest.NewRequest(http.MethodGet, "/estimates", nil)
	w := httptest.NewRecorder()

	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d — body: %s", w.Code, w.Body.String())
	}

	var resp map[string]any
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("응답 파싱 실패: %v", err)
	}
	items, ok := resp["items"].([]any)
	if !ok {
		t.Fatalf("items 필드가 없거나 배열이 아닙니다: %v", resp)
	}
	if len(items) != 0 {
		t.Errorf("빈 목록이어야 하는데 %d개 반환됨", len(items))
	}
}
