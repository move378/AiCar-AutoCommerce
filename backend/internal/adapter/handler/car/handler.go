package car

import (
	"net/http"
	"strconv"

	"backend/internal/shared/errs"
	carusecase "backend/internal/usecase/car"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	carUsecase carusecase.CarUsecase
}

func NewHandler(carUsecase carusecase.CarUsecase) *Handler {
	return &Handler{carUsecase: carUsecase}
}

// List godoc
// @Summary 차량 검색/목록 조회
// @Description 키워드, 브랜드, 연료 타입, 가격 범위로 차량을 검색합니다.
// @Tags cars
// @Produce json
// @Param q query string false "검색어 (브랜드명, 모델명, 트림명)"
// @Param page query int false "페이지 번호 (기본값: 1)"
// @Param size query int false "페이지 크기 (기본값: 10)"
// @Param brand_id query string false "브랜드 ID"
// @Param fuel_type query string false "연료 타입"
// @Param min_price query integer false "최소 가격"
// @Param max_price query integer false "최대 가격"
// @Param sort query string false "정렬 (price_asc, price_desc, year_asc, year_desc, name_asc, name_desc)"
// @Success 200 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /cars [get]
func (h *Handler) List(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	size, _ := strconv.Atoi(c.DefaultQuery("size", "10"))
	sort := c.DefaultQuery("sort", "price_desc")

	req := carusecase.ListCarsCondition{
		Page: page,
		Size: size,
		Sort: sort,
	}

	if v := c.Query("q"); v != "" {
		req.Keyword = &v
	}
	if v := c.Query("brand_id"); v != "" {
		req.BrandID = &v
	}
	if v := c.Query("fuel_type"); v != "" {
		req.FuelType = &v
	}
	if v := c.Query("min_price"); v != "" {
		if parsed, err := strconv.Atoi(v); err == nil {
			req.MinPrice = &parsed
		}
	}

	if v := c.Query("max_price"); v != "" {
		if parsed, err := strconv.Atoi(v); err == nil {
			req.MaxPrice = &parsed
		}
	}

	result, err := h.carUsecase.ListCars(c.Request.Context(), req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"items": result.Items,
		"total": result.Total,
		"page":  page,
		"size":  size,
	})
}

// GetDetail godoc
// @Summary 차량 상세 조회
// @Description 차량 ID로 상세 정보를 조회합니다.
// @Tags cars
// @Produce json
// @Param id path string true "차량 ID"
// @Success 200 {object} map[string]interface{}
// @Failure 404 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /cars/{id} [get]
func (h *Handler) GetDetail(c *gin.Context) {
	id := c.Param("id")

	car, err := h.carUsecase.GetCarDetail(c.Request.Context(), id)
	if err != nil {
		if err == errs.ErrNotFound {
			c.JSON(http.StatusNotFound, gin.H{"message": "car not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, car)
}

// GetImages godoc
// @Summary 차량 이미지 조회
// @Description 차량 ID로 이미지 목록을 조회합니다.
// @Tags cars
// @Produce json
// @Param id path string true "차량 ID"
// @Success 200 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /cars/{id}/images [get]
func (h *Handler) GetImages(c *gin.Context) {
	carID := c.Param("id")

	images, err := h.carUsecase.GetCarImages(c.Request.Context(), carID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"items": images})
}
