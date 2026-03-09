package middleware

import (
	"backend/internal/shared/auth"
	"backend/internal/shared/response"
	"net/http"

	"strings"

	"github.com/gin-gonic/gin"
	// "github.com/golang-jwt/jwt/v5"
	// "github.com/your_project/internal/shared/response"
)

func AuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		headerAuth := c.GetHeader("Authorization")
		if headerAuth == "" {
			response.SendError(c, http.StatusUnauthorized, response.CodeUnauthorized, "Authorization header is missing")
			c.Abort()
			return
		}

		ok := strings.HasPrefix(headerAuth, "Bearer ")
		if !ok {
			response.SendError(c, http.StatusUnauthorized, response.CodeUnauthorized, "Authorization header format must be Bearer {token}")
			c.Abort()
			return
		}
		token := headerAuth[len("Bearer "):]
		userID, err := auth.ParseAccessToken(token)
		if err != nil {
			response.SendError(c, http.StatusUnauthorized, response.CodeUnauthorized, "Invalid token")
			c.Abort()
			return
		}

		c.Set("user_id", userID)
		c.Next()
	}
}
