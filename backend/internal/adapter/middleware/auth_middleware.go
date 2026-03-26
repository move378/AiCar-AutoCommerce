package middleware

import (
	"backend/internal/domain/repository"
	"backend/internal/shared/response"
	token "backend/internal/shared/token"
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
		accessToken := headerAuth[len("Bearer "):]
		userID, _, err := token.ParseAccessToken(accessToken)
		if err != nil {
			response.SendError(c, http.StatusUnauthorized, response.CodeUnauthorized, "Invalid token")
			c.Abort()
			return
		}

		// 블랙리스트 확인
		isBlacklist, err := tokenCache.IsBlacklisted(c, accessToken)
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
		c.Set("access_token", accessToken)
		c.Next()
	}
}
