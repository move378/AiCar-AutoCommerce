package auth

import (
	"errors"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

func getJWTSecret() ([]byte, error) {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		return nil, errors.New("JWT_SECRET is not set in .env file")
	}
	return []byte(secret), nil
}

func GenerateTokens(userID string) (string, string, error) {
	jwtSecret, err := getJWTSecret()
	if err != nil {
		return "", "", err
	}

	accessTokenClaims := jwt.MapClaims{
		"user_id": userID,
		"exp":     time.Now().Add(time.Hour * 1).Unix(),
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
