package middleware

import (
	"backend/internal/shared/auth"

	"strings"

	"github.com/gin-gonic/gin"
	// "github.com/golang-jwt/jwt/v5"
	// "github.com/your_project/internal/shared/response"
)

func AuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		headerAuth := c.GetHeader("Authorization")
		if headerAuth == "" {
			c.AbortWithStatusJSON(401, gin.H{"error": "Authorization header is missing"})
			return
		}

		ok := strings.HasPrefix(headerAuth, "Bearer ")
		if !ok {
			c.AbortWithStatusJSON(401, gin.H{"error": "Authorization header format must be Bearer {token}"})
			return
		}
		token := headerAuth[len("Bearer "):]
		userID, err := auth.ParseAccessToken(token)
		if err != nil {
			c.AbortWithStatusJSON(401, gin.H{"error": "Invalid token"})
			return
		}

		c.Set("user_id", userID)
		c.Next()
	}
}
