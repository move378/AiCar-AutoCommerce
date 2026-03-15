package brand

import (
	"net/http"

	brandusecase "backend/internal/usecase/brand"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	brandUsecase brandusecase.BrandUsecase
}

func NewHandler(brandUsecase brandusecase.BrandUsecase) *Handler {
	return &Handler{brandUsecase: brandUsecase}
}

// List godoc
// @Summary 브랜드 목록 조회
// @Description 브랜드 목록을 조회합니다.
// @Tags brands
// @Produce json
// @Success 200 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /brands [get]
func (h *Handler) List(c *gin.Context) {
	brands, err := h.brandUsecase.ListBrands(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"items": brands,
	})
}
