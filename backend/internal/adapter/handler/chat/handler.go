package chat

import (
	"net/http"

	chatusecase "backend/internal/usecase/chat"
	"backend/internal/shared/errs"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	uc chatusecase.Usecase
}

func NewHandler(uc chatusecase.Usecase) *Handler {
	return &Handler{uc: uc}
}

// CreateSession godoc
// @Summary 채팅 세션 생성
// @Tags chat
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param body body createSessionRequest false "세션 제목 (선택)"
// @Success 201 {object} map[string]interface{}
// @Failure 401 {object} map[string]interface{}
// @Router /chat/sessions [post]
func (h *Handler) CreateSession(c *gin.Context) {
	userID := c.GetString("user_id")

	var req createSessionRequest
	_ = c.ShouldBindJSON(&req)

	session, err := h.uc.CreateSession(c.Request.Context(), userID, req.Title)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, session)
}

// GetSessions godoc
// @Summary 내 채팅 세션 목록
// @Tags chat
// @Security BearerAuth
// @Produce json
// @Success 200 {object} map[string]interface{}
// @Failure 401 {object} map[string]interface{}
// @Router /chat/sessions [get]
func (h *Handler) GetSessions(c *gin.Context) {
	userID := c.GetString("user_id")

	sessions, err := h.uc.GetSessions(c.Request.Context(), userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"items": sessions})
}

// DeleteSession godoc
// @Summary 채팅 세션 삭제
// @Tags chat
// @Security BearerAuth
// @Produce json
// @Param id path string true "세션 ID"
// @Success 204
// @Failure 404 {object} map[string]interface{}
// @Router /chat/sessions/{id} [delete]
func (h *Handler) DeleteSession(c *gin.Context) {
	userID := c.GetString("user_id")
	sessionID := c.Param("id")

	if err := h.uc.DeleteSession(c.Request.Context(), sessionID, userID); err != nil {
		if err == errs.ErrNotFound {
			c.JSON(http.StatusNotFound, gin.H{"message": "session not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}
	c.Status(http.StatusNoContent)
}

// CreateMessage godoc
// @Summary 메시지 저장
// @Tags chat
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param id path string true "세션 ID"
// @Param body body createMessageRequest true "메시지"
// @Success 201 {object} map[string]interface{}
// @Failure 400 {object} map[string]interface{}
// @Failure 404 {object} map[string]interface{}
// @Router /chat/sessions/{id}/messages [post]
func (h *Handler) CreateMessage(c *gin.Context) {
	userID := c.GetString("user_id")
	sessionID := c.Param("id")

	var req createMessageRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "role, content는 필수입니다"})
		return
	}

	msg, err := h.uc.CreateMessage(c.Request.Context(), sessionID, userID, req.Role, req.Content, req.Metadata)
	if err != nil {
		if err == errs.ErrNotFound {
			c.JSON(http.StatusNotFound, gin.H{"message": "session not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, msg)
}

// GetMessages godoc
// @Summary 세션 메시지 목록
// @Tags chat
// @Security BearerAuth
// @Produce json
// @Param id path string true "세션 ID"
// @Success 200 {object} map[string]interface{}
// @Failure 404 {object} map[string]interface{}
// @Router /chat/sessions/{id}/messages [get]
func (h *Handler) GetMessages(c *gin.Context) {
	userID := c.GetString("user_id")
	sessionID := c.Param("id")

	messages, err := h.uc.GetMessages(c.Request.Context(), sessionID, userID)
	if err != nil {
		if err == errs.ErrNotFound {
			c.JSON(http.StatusNotFound, gin.H{"message": "session not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"items": messages})
}

// UpdateFeedback godoc
// @Summary 메시지 피드백 등록
// @Tags chat
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param id path string true "메시지 ID"
// @Param body body feedbackRequest true "피드백"
// @Success 200 {object} map[string]interface{}
// @Failure 400 {object} map[string]interface{}
// @Failure 404 {object} map[string]interface{}
// @Router /chat/messages/{id}/feedback [patch]
func (h *Handler) UpdateFeedback(c *gin.Context) {
	userID := c.GetString("user_id")
	messageID := c.Param("id")

	var req feedbackRequest
	if err := c.ShouldBindJSON(&req); err != nil || (req.Feedback != "like" && req.Feedback != "dislike") {
		c.JSON(http.StatusBadRequest, gin.H{"message": "feedback는 'like' 또는 'dislike'여야 합니다"})
		return
	}

	if err := h.uc.UpdateFeedback(c.Request.Context(), messageID, userID, req.Feedback); err != nil {
		if err == errs.ErrNotFound {
			c.JSON(http.StatusNotFound, gin.H{"message": "message not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "ok"})
}

type createSessionRequest struct {
	Title *string `json:"title"`
}

type createMessageRequest struct {
	Role     string  `json:"role"    binding:"required"`
	Content  string  `json:"content" binding:"required"`
	Metadata *string `json:"metadata"`
}

type feedbackRequest struct {
	Feedback string `json:"feedback" binding:"required"`
}
