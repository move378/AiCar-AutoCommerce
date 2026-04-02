package app

import (
	"net/http"

	"backend/internal/shared/errs"
	estimateusecase "backend/internal/usecase/estimate"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type EstimateHandler struct {
	uc estimateusecase.Usecase
}

func NewEstimateHandler(uc estimateusecase.Usecase) *EstimateHandler {
	return &EstimateHandler{uc: uc}
}

// CreateEstimate godoc
// @Summary 견적 생성
// @Tags estimate
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param body body createEstimateRequest true "견적 생성 요청"
// @Success 201 {object} map[string]interface{}
// @Failure 400 {object} map[string]interface{}
// @Failure 404 {object} map[string]interface{}
// @Router /estimates [post]
func (h *EstimateHandler) Create(c *gin.Context) {
	userIDVal, _ := c.Get("user_id")
	userID := userIDVal.(uuid.UUID).String()

	var req createEstimateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "trim_id, chat_session_id는 필수입니다"})
		return
	}

	estimate, err := h.uc.Create(c.Request.Context(), userID, req.TrimID, req.ChatSessionID, req.PromotionID)
	if err != nil {
		if err == errs.ErrNotFound {
			c.JSON(http.StatusNotFound, gin.H{"message": "트림 또는 프로모션을 찾을 수 없습니다"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, estimate)
}

// GetEstimate godoc
// @Summary 견적 단건 조회
// @Tags estimate
// @Security BearerAuth
// @Produce json
// @Param id path string true "견적 ID"
// @Success 200 {object} map[string]interface{}
// @Failure 404 {object} map[string]interface{}
// @Router /estimates/{id} [get]
func (h *EstimateHandler) GetByID(c *gin.Context) {
	userIDVal, _ := c.Get("user_id")
	userID := userIDVal.(uuid.UUID).String()
	id := c.Param("id")

	estimate, err := h.uc.GetByID(c.Request.Context(), id, userID)
	if err != nil {
		if err == errs.ErrNotFound {
			c.JSON(http.StatusNotFound, gin.H{"message": "견적을 찾을 수 없습니다"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}
	c.JSON(http.StatusOK, estimate)
}

// ListEstimates godoc
// @Summary 내 견적 목록
// @Tags estimate
// @Security BearerAuth
// @Produce json
// @Success 200 {object} map[string]interface{}
// @Router /estimates [get]
func (h *EstimateHandler) List(c *gin.Context) {
	userIDVal, _ := c.Get("user_id")
	userID := userIDVal.(uuid.UUID).String()

	estimates, err := h.uc.GetByUserID(c.Request.Context(), userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"items": estimates})
}

type createEstimateRequest struct {
	TrimID        string  `json:"trim_id"         binding:"required"`
	ChatSessionID string  `json:"chat_session_id" binding:"required"`
	PromotionID   *string `json:"promotion_id"`
}
