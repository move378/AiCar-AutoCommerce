package token

import (
	"backend/internal/config"
	"errors"
	"fmt"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

func getJWTAccessSecret() ([]byte, error) {
	secret := os.Getenv("JWT_ACCESS_SECRET")
	if secret == "" {
		return nil, errors.New("JWT_ACCESS_SECRET is not set in .env file")
	}
	return []byte(secret), nil
}

func getJWTRefreshSecret() ([]byte, error) {
	secret := os.Getenv("JWT_REFRESH_SECRET")
	if secret == "" {
		return nil, errors.New("JWT_REFRESH_SECRET is not set in .env file")
	}
	return []byte(secret), nil
}

func GenerateTokens(cfg *config.Config, userID uuid.UUID) (string, string, error) {
	jwtAccessSecret, err := getJWTAccessSecret()
	if err != nil {
		return "", "", err
	}

	accessTokenClaims := jwt.MapClaims{
		"user_id": userID,
		"exp":     time.Now().Add(cfg.JWT.AccessExpiration).Unix(), // 테스트때문에 24시간으로 해뒀음 후에 1시간
		"iat":     time.Now().Unix(),
	}

	atObj := jwt.NewWithClaims(jwt.SigningMethodHS256, accessTokenClaims)
	accessToken, err := atObj.SignedString(jwtAccessSecret)
	if err != nil {
		return "", "", err
	}

	refreshSecret, err := getJWTRefreshSecret()
	if err != nil {
		return "", "", err
	}
	refreshTokenClaims := jwt.MapClaims{
		"user_id": userID,
		"exp":     time.Now().Add(cfg.JWT.RefreshExpiration).Unix(),
		"iat":     time.Now().Unix(),
	}
	rtObj := jwt.NewWithClaims(jwt.SigningMethodHS256, refreshTokenClaims)
	refreshToken, err := rtObj.SignedString(refreshSecret)
	if err != nil {
		return "", "", err
	}

	return accessToken, refreshToken, nil

}

func parseToken(tokenStr string, secret []byte) (uuid.UUID, time.Duration, error) {
	token, err := jwt.Parse(tokenStr, func(t *jwt.Token) (interface{}, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method")
		}
		return secret, nil
	})

	if err != nil {
		return uuid.Nil, 0, fmt.Errorf("토큰 파싱 실패: %w", err)
	}

	claims, ok := token.Claims.(jwt.MapClaims)

	if !ok || !token.Valid {
		return uuid.Nil, 0, fmt.Errorf("유효하지 않은 토큰")
	}

	userIDStr, ok := claims["user_id"].(string)
	if !ok {
		return uuid.Nil, 0, fmt.Errorf("user_id 추출 실패")
	}

	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		return uuid.Nil, 0, fmt.Errorf("user_id 파싱 실패: %w", err)
	}

	ttl := time.Until(time.Unix(int64(claims["exp"].(float64)), 0))

	return userID, ttl, nil
}

func ParseAccessToken(tokenStr string) (uuid.UUID, time.Duration, error) {
	jwtSecret, err := getJWTAccessSecret()
	if err != nil {
		return uuid.Nil, 0, err
	}

	userId, ttl, err := parseToken(tokenStr, jwtSecret)
	if err != nil {
		return uuid.Nil, 0, err
	}

	return userId, ttl, nil
}

func ParseRefreshToken(tokenStr string) (uuid.UUID, time.Duration, error) {
	jwtSecret, err := getJWTRefreshSecret()
	if err != nil {
		return uuid.Nil, 0, err
	}

	userId, ttl, err := parseToken(tokenStr, jwtSecret)
	if err != nil {
		return uuid.Nil, 0, err
	}

	return userId, ttl, nil
}
