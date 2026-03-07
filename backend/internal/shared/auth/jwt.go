package auth

import (
	"errors"
	"fmt"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

func getJWTSecret() ([]byte, error) {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		return nil, errors.New("JWT_SECRET is not set in .env file")
	}
	return []byte(secret), nil
}

func GenerateTokens(userID uuid.UUID) (string, string, error) {
	jwtSecret, err := getJWTSecret()
	if err != nil {
		return "", "", err
	}

	accessTokenClaims := jwt.MapClaims{
		"user_id": userID,
		"exp":     time.Now().Add(time.Hour * 24).Unix(), // 테스트때문에 24시간으로 해뒀음 후에 1시간
		"iat":     time.Now().Unix(),
	}

	atObj := jwt.NewWithClaims(jwt.SigningMethodHS256, accessTokenClaims)
	acessToken, err := atObj.SignedString(jwtSecret)
	if err != nil {
		return "", "", err
	}

	refreshTokenClaims := jwt.MapClaims{
		"user_id": userID,
		"exp":     time.Now().Add(time.Hour * 24 * 7).Unix(),
		"iat":     time.Now().Unix(),
	}
	rtObj := jwt.NewWithClaims(jwt.SigningMethodHS256, refreshTokenClaims)
	refreshToken, err := rtObj.SignedString(jwtSecret)
	if err != nil {
		return "", "", err
	}

	return acessToken, refreshToken, nil

}

func parseToken(tokenStr string, secret []byte) (uuid.UUID, error) {
	token, err := jwt.Parse(tokenStr, func(t *jwt.Token) (interface{}, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method")
		}
		return secret, nil
	})

	if err != nil {
		return uuid.Nil, fmt.Errorf("토큰 파싱 실패: %w", err)
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok || !token.Valid {
		return uuid.Nil, fmt.Errorf("유효하지 않은 토큰")
	}

	userIDStr, ok := claims["user_id"].(string)
	if !ok {
		return uuid.Nil, fmt.Errorf("user_id 추출 실패")
	}

	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		return uuid.Nil, fmt.Errorf("user_id 파싱 실패: %w", err)
	}

	return userID, nil
}

func ParseAccessToken(tokenStr string) (uuid.UUID, error) {
	jwtSecret, err := getJWTSecret()
	if err != nil {
		return uuid.Nil, err
	}

	userId, err := parseToken(tokenStr, jwtSecret)
	if err != nil {
		return uuid.Nil, err
	}

	return userId, nil

}
