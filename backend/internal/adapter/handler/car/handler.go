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
// @Summary 차량 목록 조회
// @Description 차량 목록을 조회합니다.
// @Tags cars
// @Produce json
// @Param page query int false "페이지 번호"
// @Param size query int false "페이지 크기"
// @Param brand_id query string false "브랜드 ID"
// @Param fuel_type query string false "연료 타입"
// @Param min_price query int false "최소 가격"
// @Param max_price query int false "최대 가격"
// @Param sort query string false "정렬(price_asc, price_desc, year_asc, year_desc, created_at_asc, created_at_desc)"
// @Success 200 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /cars [get]

// GetDetail godoc
// @Summary 차량 상세 조회
// @Description 차량 상세 정보를 조회합니다.
// @Tags cars
// @Produce json
// @Param id path string true "차량 ID"
// @Success 200 {object} carusecase.CarDetailResponse
// @Failure 404 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /cars/{id} [get]

// @Summary 차량 이미지 조회
// @Description 차량 이미지를 조회합니다.
// @Tags cars
// @Produce json
// @Param id path string true "차량 ID"
// @Success 200 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /cars/{id}/images [get]
func (h *Handler) List(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	size, _ := strconv.Atoi(c.DefaultQuery("size", "10"))

	brandID := c.Query("brand_id")
	fuelType := c.Query("fuel_type")
	sort := c.DefaultQuery("sort", "created_at_desc")

	var minPrice *int
	var maxPrice *int
	var brandIDPtr *string
	var fuelTypePtr *string

	if brandID != "" {
		brandIDPtr = &brandID
	}

	if fuelType != "" {
		fuelTypePtr = &fuelType
	}

	if v := c.Query("min_price"); v != "" {
		if parsed, err := strconv.Atoi(v); err == nil {
			minPrice = &parsed
		}
	}

	if v := c.Query("max_price"); v != "" {
		if parsed, err := strconv.Atoi(v); err == nil {
			maxPrice = &parsed
		}
	}

	req := carusecase.ListCarsCondition{
		Page:     page,
		Size:     size,
		BrandID:  brandIDPtr,
		FuelType: fuelTypePtr,
		MinPrice: minPrice,
		MaxPrice: maxPrice,
		Sort:     sort,
	}

	cars, err := h.carUsecase.ListCars(c.Request.Context(), req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"items": cars,
		"page":  page,
		"size":  size,
	})
}

func (h *Handler) GetDetail(c *gin.Context) {
	id := c.Param("id")

	car, err := h.carUsecase.GetCarDetail(c.Request.Context(), id)
	if err != nil {
		if err == errs.ErrNotFound {
			c.JSON(http.StatusNotFound, gin.H{
				"message": "car not found",
			})
			return
		}

		c.JSON(http.StatusInternalServerError, gin.H{
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, car)
}

func (h *Handler) GetImages(c *gin.Context) {
	carID := c.Param("id")

	images, err := h.carUsecase.GetCarImages(c.Request.Context(), carID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"items": images,
	})
}
