package middleware

import (
	"backend/internal/domain/repository"
	"backend/internal/shared/auth"
	"backend/internal/shared/response"
	"fmt"
	"net/http"

	"strings"

	"github.com/gin-gonic/gin"
)

func AuthMiddleware(tokenCache repository.TokenCacheRepository) gin.HandlerFunc {
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
		userID, _, err := auth.ParseAccessToken(token)
		if err != nil {
			response.SendError(c, http.StatusUnauthorized, response.CodeUnauthorized, "Invalid token")
			c.Abort()
			return
		}

		// 블랙리스트 확인
		isBlacklist, err := tokenCache.IsBlacklisted(c, token)
		fmt.Println("블랙임?", isBlacklist)
		if err != nil {
			response.SendError(c, http.StatusUnauthorized, response.CodeUnauthorized, "Error occurred while checking token status")
			c.Abort()
			return
		}
		if isBlacklist {
			response.SendError(c, http.StatusUnauthorized, response.CodeUnauthorized, "Token is blacklisted")
			c.Abort()
			return
		}

		c.Set("user_id", userID)
		c.Set("access_token", token)
		c.Next()
	}
}
