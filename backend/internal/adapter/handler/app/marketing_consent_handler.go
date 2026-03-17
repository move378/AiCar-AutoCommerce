package app

import (
	"net/http"

	dto "backend/internal/adapter/handler/app/dto"
	usecase "backend/internal/usecase/auth"

	"github.com/gin-gonic/gin"
)

type MarketingConsentHandler struct {
	marketingConsentUsecase usecase.MarketingConsentUsecase
}

func NewMarketingConsentHandler(marketingConsentUsecase usecase.MarketingConsentUsecase) *MarketingConsentHandler {
	return &MarketingConsentHandler{marketingConsentUsecase: marketingConsentUsecase}
}

// SaveMarketingConsent godoc
// @Summary 마케팅 활용 동의 저장
// @Description 사용자의 마케팅 활용 동의 여부를 저장하거나 수정한다.
// @Tags auth
// @Accept json
// @Produce json
// @Param request body dto.MarketingConsentRequest true "마케팅 활용 동의 요청"
// @Success 200 {object} dto.MarketingConsentResponse
// @Failure 400 {object} dto.MarketingConsentResponse
// @Failure 500 {object} dto.MarketingConsentResponse
// @Router /api/v1/auth/agreed [post]
func (h *MarketingConsentHandler) SaveMarketingConsent(c *gin.Context) {
	var req dto.MarketingConsentRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.MarketingConsentResponse{
			Status:  http.StatusBadRequest,
			Message: "invalid request",
		})
		return
	}

	err := h.marketingConsentUsecase.SaveMarketingConsent(
		c.Request.Context(),
		req.DeviceID,
		req.MarketingAgreed,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.MarketingConsentResponse{
			Status:  http.StatusInternalServerError,
			Message: err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, dto.MarketingConsentResponse{
		Status:  http.StatusOK,
		Message: "success",
	})
}
