package response

import (
	"github.com/gin-gonic/gin"
)

type APIResponse struct {
	Status  int    `json:"status"`            // HTTP 상태 코드
	Code    string `json:"code"`              // 애플리케이션 레벨의 상태 코드 (예: "SUCCESS", "ERROR", "VALIDATION_ERROR" 등)
	Data    any    `json:"data"`              // 데이터 없으면 null 출력
	Message string `json:"message,omitempty"` // 에러일 때만 보이고, 성공 시(비어있을 때) 아예 숨김
}

const (
	CodeSuccess         = "SUCCESS"
	CodeBadRequest      = "BAD_REQUEST"
	CodeUnauthorized    = "UNAUTHORIZED"
	CodeNotFound        = "NOT_FOUND"
	CodeConflict        = "CONFLICT"
	CodeInternalError   = "INTERNAL_SERVER_ERROR"
	CodeLoginSuccess    = "LOGIN_SUCCESS"
	CodeRegisterSuccess = "REGISTER_SUCCESS"
)

func SendSuccess(c *gin.Context, status int, code string, data any, message ...string) {
	c.JSON(status, APIResponse{
		Status: status,
		Code:   code,
		Data:   data,
		Message: func() string {
			if len(message) > 0 {
				return message[0]
			}
			return ""
		}(),
	})
}

func SendError(c *gin.Context, status int, code string, message string) {
	c.JSON(status, APIResponse{
		Status:  status,
		Code:    code,
		Data:    nil,
		Message: message,
	})
}
