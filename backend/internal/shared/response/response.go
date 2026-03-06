package response

import (
	"backend/internal/model"

	"github.com/gin-gonic/gin"
)

func SendSuccess(c *gin.Context, status int, data any) {
	c.JSON(status, model.APIResponse{
		Status: status,
		Data:   data,
	})
}

func SendError(c *gin.Context, status int, message string) {
	c.JSON(status, model.APIResponse{
		Status:  status,
		Data:    nil,
		Message: message,
	})
}
