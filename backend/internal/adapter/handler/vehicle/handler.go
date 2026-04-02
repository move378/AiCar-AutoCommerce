package vehicle

import (
	"net/http"
	"strconv"

	"backend/internal/shared/errs"
	vehicleusecase "backend/internal/usecase/vehicle"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	uc vehicleusecase.Usecase
}

func NewHandler(uc vehicleusecase.Usecase) *Handler {
	return &Handler{uc: uc}
}

// Search godoc
// @Summary 차량 검색
// @Description 검색어(브랜드명·한국어 별칭·모델명·트림명)로 차량을 검색합니다. 예: "벤츠", "E 200"
// @Tags vehicles
// @Produce json
// @Param q    query string false "검색어 (예: 벤츠, E 200, GLE 450)"
// @Param page query int    false "페이지 번호 (기본 1)"
// @Param size query int    false "페이지 크기 (기본 10)"
// @Success 200 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /vehicles [get]
func (h *Handler) Search(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	size, _ := strconv.Atoi(c.DefaultQuery("size", "10"))

	cond := vehicleusecase.SearchCondition{
		Page: page,
		Size: size,
	}

	if v := c.Query("q"); v != "" {
		cond.Keyword = &v
	}

	result, err := h.uc.Search(c.Request.Context(), cond)
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
// @Summary 차량 트림 상세 조회
// @Description 트림 ID로 상세 스펙을 조회합니다.
// @Tags vehicles
// @Produce json
// @Param id path string true "트림 ID"
// @Success 200 {object} map[string]interface{}
// @Failure 404 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /vehicles/{id} [get]
func (h *Handler) GetDetail(c *gin.Context) {
	id := c.Param("id")

	detail, err := h.uc.GetDetail(c.Request.Context(), id)
	if err != nil {
		if err == errs.ErrNotFound {
			c.JSON(http.StatusNotFound, gin.H{"message": "vehicle not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, detail)
}

// ListBrands godoc
// @Summary 차량 브랜드 목록
// @Description vehicles_brands 기준 브랜드 목록을 반환합니다.
// @Tags vehicles
// @Produce json
// @Success 200 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /vehicles/brands [get]
func (h *Handler) ListBrands(c *gin.Context) {
	brands, err := h.uc.ListBrands(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"items": brands})
}
