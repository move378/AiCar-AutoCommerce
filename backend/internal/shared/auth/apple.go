package auth

import (
	"crypto/rsa"
	"encoding/base64"
	"encoding/binary"
	"encoding/json"
	"fmt"
	"math/big"
	"net/http"

	"github.com/golang-jwt/jwt/v5"
)

// AppleClaims: 애플 Identity Token 내부에 담긴 데이터 구조
type AppleClaims struct {
	Email string `json:"email"`
	Sub   string `json:"sub"` // 애플 유저 고유 ID
	jwt.RegisteredClaims
}

// VerifyAppleIdentityToken: 애플 공개키를 가져와 토큰의 유효성을 검증하고 데이터를 반환합니다.
func VerifyAppleIdentityToken(tokenStr string, clientID string) (*AppleClaims, error) {
	// 1. 애플 공개키 목록(JWKS) 가져오기
	resp, err := http.Get("https://appleid.apple.com/auth/keys")
	if err != nil {
		return nil, fmt.Errorf("apple keys fetch failed: %w", err)
	}
	defer resp.Body.Close()

	var jwks struct {
		Keys []struct {
			Kid string `json:"kid"`
			N   string `json:"n"`
			E   string `json:"e"`
		} `json:"keys"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&jwks); err != nil {
		return nil, err
	}

	// 2. 토큰 파싱 및 RSA 서명 검증 (RS256 방식)
	token, err := jwt.ParseWithClaims(tokenStr, &AppleClaims{}, func(t *jwt.Token) (interface{}, error) {
		// 애플은 비대칭키(RS256)를 사용하므로 SigningMethodRSA를 확인합니다.
		if _, ok := t.Method.(*jwt.SigningMethodRSA); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", t.Header["alg"])
		}

		kid := t.Header["kid"].(string)
		for _, key := range jwks.Keys {
			if key.Kid == kid {
				// n, e 값을 RSA PublicKey 객체로 변환
				nBytes, _ := base64.RawURLEncoding.DecodeString(key.N)
				eBytes, _ := base64.RawURLEncoding.DecodeString(key.E)
				var e int
				if len(eBytes) < 4 {
					data := make([]byte, 4)
					copy(data[4-len(eBytes):], eBytes)
					e = int(binary.BigEndian.Uint32(data))
				} else {
					e = int(binary.BigEndian.Uint32(eBytes))
				}

				return &rsa.PublicKey{N: new(big.Int).SetBytes(nBytes), E: e}, nil
			}
		}
		return nil, fmt.Errorf("matching key not found")
	})

	if err != nil || !token.Valid {
		return nil, fmt.Errorf("invalid apple token: %w", err)
	}

	claims, ok := token.Claims.(*AppleClaims)
	if !ok {
		return nil, fmt.Errorf("failed to cast apple claims")
	}

	// 3. 발급자 및 대상(App ID) 검증
	// aud 필드가 앱의 Bundle ID와 일치해야 합니다.
	if claims.Issuer != "https://appleid.apple.com" || claims.Audience[0] != clientID {
		return nil, fmt.Errorf("invalid issuer or audience (expected: %s)", clientID)
	}

	return claims, nil
}