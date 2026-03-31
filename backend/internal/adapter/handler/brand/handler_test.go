package brand

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"backend/internal/domain/entity"

	"github.com/gin-gonic/gin"
)

type mockBrandUsecase struct {
	listFn func(ctx context.Context) ([]entity.Brand, error)
}

func (m *mockBrandUsecase) ListBrands(ctx context.Context) ([]entity.Brand, error) {
	return m.listFn(ctx)
}

func setupBrandRouter(uc *mockBrandUsecase) *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := NewHandler(uc)
	r.GET("/brands", h.List)
	return r
}

func TestBrandList_Success(t *testing.T) {
	uc := &mockBrandUsecase{
		listFn: func(_ context.Context) ([]entity.Brand, error) {
			return []entity.Brand{
				{ID: "b-001", Name: "Mercedes-Benz"},
				{ID: "b-002", Name: "BMW"},
			}, nil
		},
	}
	r := setupBrandRouter(uc)

	req := httptest.NewRequest(http.MethodGet, "/brands", nil)
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
		t.Fatalf("items 필드가 배열이 아닙니다: %v", resp)
	}
	if len(items) != 2 {
		t.Errorf("items 개수 불일치: want 2, got %d", len(items))
	}
	first := items[0].(map[string]any)
	if first["name"] != "Mercedes-Benz" {
		t.Errorf("첫 번째 브랜드명 불일치: got %v", first["name"])
	}
}

func TestBrandList_InternalError(t *testing.T) {
	uc := &mockBrandUsecase{
		listFn: func(_ context.Context) ([]entity.Brand, error) {
			return nil, errors.New("db error")
		},
	}
	r := setupBrandRouter(uc)

	req := httptest.NewRequest(http.MethodGet, "/brands", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusInternalServerError {
		t.Fatalf("expected 500, got %d — body: %s", w.Code, w.Body.String())
	}
	var resp map[string]any
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("응답 파싱 실패: %v", err)
	}
	if _, ok := resp["message"]; !ok {
		t.Error("message 필드가 없습니다")
	}
}

func TestBrandList_Empty(t *testing.T) {
	uc := &mockBrandUsecase{
		listFn: func(_ context.Context) ([]entity.Brand, error) {
			return []entity.Brand{}, nil
		},
	}
	r := setupBrandRouter(uc)

	req := httptest.NewRequest(http.MethodGet, "/brands", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", w.Code)
	}
	var resp map[string]any
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("응답 파싱 실패: %v", err)
	}
	items := resp["items"].([]any)
	if len(items) != 0 {
		t.Errorf("빈 목록이어야 하는데 %d개 반환됨", len(items))
	}
}
