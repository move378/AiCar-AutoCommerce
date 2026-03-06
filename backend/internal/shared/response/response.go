package response

import (
	"github.com/gin-gonic/gin"
)

type APIResponse struct {
	Status  int    `json:"status"`            // HTTP 상태 코드
	Data    any    `json:"data"`              // 없으면 null 출력
	Message string `json:"message,omitempty"` // 에러일 때만 보이고, 성공 시(비어있을 때) 아예 숨김
}

func SendSuccess(c *gin.Context, status int, data any) {
	c.JSON(status, APIResponse{
		Status: status,
		Data:   data,
	})
}

func SendError(c *gin.Context, status int, message string) {
	c.JSON(status, APIResponse{
		Status:  status,
		Data:    nil,
		Message: message,
	})
}
