package vehicle

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"backend/internal/shared/errs"
	vehicleusecase "backend/internal/usecase/vehicle"

	"github.com/gin-gonic/gin"
)

type mockVehicleUsecase struct {
	searchFn      func(ctx context.Context, cond vehicleusecase.SearchCondition) (*vehicleusecase.SearchResult, error)
	getDetailFn   func(ctx context.Context, id string) (*vehicleusecase.TrimDetailResponse, error)
	listBrandsFn  func(ctx context.Context) ([]vehicleusecase.BrandResponse, error)
}

func (m *mockVehicleUsecase) Search(ctx context.Context, cond vehicleusecase.SearchCondition) (*vehicleusecase.SearchResult, error) {
	return m.searchFn(ctx, cond)
}
func (m *mockVehicleUsecase) GetDetail(ctx context.Context, id string) (*vehicleusecase.TrimDetailResponse, error) {
	return m.getDetailFn(ctx, id)
}
func (m *mockVehicleUsecase) ListBrands(ctx context.Context) ([]vehicleusecase.BrandResponse, error) {
	return m.listBrandsFn(ctx)
}

func setupVehicleRouter(uc vehicleusecase.Usecase) *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := NewHandler(uc)
	r.GET("/vehicles", h.Search)
	r.GET("/vehicles/brands", h.ListBrands)
	r.GET("/vehicles/:id", h.GetDetail)
	return r
}

// ============================================================
// GET /vehicles
// ============================================================

func TestVehicleSearch_Success(t *testing.T) {
	uc := &mockVehicleUsecase{
		searchFn: func(_ context.Context, _ vehicleusecase.SearchCondition) (*vehicleusecase.SearchResult, error) {
			return &vehicleusecase.SearchResult{
				Items: []vehicleusecase.TrimListItemResponse{
					{ID: "t-001", BrandName: "Mercedes-Benz", TrimName: "E300"},
					{ID: "t-002", BrandName: "Mercedes-Benz", TrimName: "C200"},
				},
				Total: 2,
			}, nil
		},
	}
	r := setupVehicleRouter(uc)

	req := httptest.NewRequest(http.MethodGet, "/vehicles?page=1&size=10", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d — body: %s", w.Code, w.Body.String())
	}
	var resp map[string]any
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("응답 파싱 실패: %v", err)
	}
	if int(resp["total"].(float64)) != 2 {
		t.Errorf("total 불일치: want 2, got %v", resp["total"])
	}
	if int(resp["page"].(float64)) != 1 {
		t.Errorf("page 불일치: want 1, got %v", resp["page"])
	}
	items := resp["items"].([]any)
	if len(items) != 2 {
		t.Errorf("items 개수 불일치: want 2, got %d", len(items))
	}
}

func TestVehicleSearch_WithKeyword(t *testing.T) {
	var capturedCond vehicleusecase.SearchCondition
	uc := &mockVehicleUsecase{
		searchFn: func(_ context.Context, cond vehicleusecase.SearchCondition) (*vehicleusecase.SearchResult, error) {
			capturedCond = cond
			return &vehicleusecase.SearchResult{Items: []vehicleusecase.TrimListItemResponse{}, Total: 0}, nil
		},
	}
	r := setupVehicleRouter(uc)

	req := httptest.NewRequest(http.MethodGet, "/vehicles?q=벤츠", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", w.Code)
	}
	if capturedCond.Keyword == nil {
		t.Fatal("keyword가 usecase로 전달되지 않았습니다")
	}
	if *capturedCond.Keyword != "벤츠" {
		t.Errorf("keyword 불일치: want 벤츠, got %s", *capturedCond.Keyword)
	}
}

func TestVehicleSearch_DefaultPagination(t *testing.T) {
	var capturedCond vehicleusecase.SearchCondition
	uc := &mockVehicleUsecase{
		searchFn: func(_ context.Context, cond vehicleusecase.SearchCondition) (*vehicleusecase.SearchResult, error) {
			capturedCond = cond
			return &vehicleusecase.SearchResult{Items: []vehicleusecase.TrimListItemResponse{}, Total: 0}, nil
		},
	}
	r := setupVehicleRouter(uc)

	req := httptest.NewRequest(http.MethodGet, "/vehicles", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if capturedCond.Page != 1 {
		t.Errorf("기본 page 불일치: want 1, got %d", capturedCond.Page)
	}
	if capturedCond.Size != 10 {
		t.Errorf("기본 size 불일치: want 10, got %d", capturedCond.Size)
	}
}

func TestVehicleSearch_InternalError(t *testing.T) {
	uc := &mockVehicleUsecase{
		searchFn: func(_ context.Context, _ vehicleusecase.SearchCondition) (*vehicleusecase.SearchResult, error) {
			return nil, errors.New("db error")
		},
	}
	r := setupVehicleRouter(uc)

	req := httptest.NewRequest(http.MethodGet, "/vehicles", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusInternalServerError {
		t.Fatalf("expected 500, got %d", w.Code)
	}
}

// ============================================================
// GET /vehicles/:id
// ============================================================

func TestVehicleGetDetail_Success(t *testing.T) {
	trimID := "t-001"
	trimName := "E300 Avantgarde"
	uc := &mockVehicleUsecase{
		getDetailFn: func(_ context.Context, id string) (*vehicleusecase.TrimDetailResponse, error) {
			return &vehicleusecase.TrimDetailResponse{
				ID:        id,
				BrandName: "Mercedes-Benz",
				ModelName: "E-Class",
				TrimName:  trimName,
				Images:    []vehicleusecase.TrimImageResponse{},
			}, nil
		},
	}
	r := setupVehicleRouter(uc)

	req := httptest.NewRequest(http.MethodGet, "/vehicles/"+trimID, nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d — body: %s", w.Code, w.Body.String())
	}
	var resp map[string]any
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("응답 파싱 실패: %v", err)
	}
	if resp["id"] != trimID {
		t.Errorf("id 불일치: want %s, got %v", trimID, resp["id"])
	}
	if resp["trim_name"] != trimName {
		t.Errorf("trim_name 불일치: want %s, got %v", trimName, resp["trim_name"])
	}
}

func TestVehicleGetDetail_NotFound(t *testing.T) {
	uc := &mockVehicleUsecase{
		getDetailFn: func(_ context.Context, _ string) (*vehicleusecase.TrimDetailResponse, error) {
			return nil, errs.ErrNotFound
		},
	}
	r := setupVehicleRouter(uc)

	req := httptest.NewRequest(http.MethodGet, "/vehicles/nonexistent", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusNotFound {
		t.Fatalf("expected 404, got %d", w.Code)
	}
}

// ============================================================
// GET /vehicles/brands
// ============================================================

func TestVehicleListBrands_Success(t *testing.T) {
	uc := &mockVehicleUsecase{
		listBrandsFn: func(_ context.Context) ([]vehicleusecase.BrandResponse, error) {
			return []vehicleusecase.BrandResponse{
				{ID: "b-001", Name: "Mercedes-Benz"},
				{ID: "b-002", Name: "BMW"},
				{ID: "b-003", Name: "Audi"},
			}, nil
		},
	}
	r := setupVehicleRouter(uc)

	req := httptest.NewRequest(http.MethodGet, "/vehicles/brands", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d — body: %s", w.Code, w.Body.String())
	}
	var resp map[string]any
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("응답 파싱 실패: %v", err)
	}
	items := resp["items"].([]any)
	if len(items) != 3 {
		t.Errorf("items 개수 불일치: want 3, got %d", len(items))
	}
}

func TestVehicleListBrands_InternalError(t *testing.T) {
	uc := &mockVehicleUsecase{
		listBrandsFn: func(_ context.Context) ([]vehicleusecase.BrandResponse, error) {
			return nil, errors.New("db error")
		},
	}
	r := setupVehicleRouter(uc)

	req := httptest.NewRequest(http.MethodGet, "/vehicles/brands", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusInternalServerError {
		t.Fatalf("expected 500, got %d", w.Code)
	}
}
