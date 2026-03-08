package auth

import (
	"backend/internal/config"
	"context"
	"fmt"
	"io"
	"net/http"

	"github.com/goccy/go-json"
	"github.com/google/uuid"
)

type GoogleUsecase interface {
	GoogleLogin(ctx context.Context, userID uuid.UUID, googleAccessToken string) (*SocialTokenResult, error)
}

type googleUsecase struct {
	social AuthSocialUsecase
}

func NewGoogleUsecase(
	social AuthSocialUsecase,
) GoogleUsecase {
	return &googleUsecase{
		social: social,
	}
}

type GoogleUser struct {
	ID      string `json:"id"`
	Email   string `json:"email"`
	Name    string `json:"name"`
	Picture string `json:"picture"`
}

func (u *googleUsecase) GoogleLogin(ctx context.Context, userID uuid.UUID, googleAccessToken string) (*SocialTokenResult, error) {
	c := config.LoadConfig()
	authConfig := c.Auth

	if authConfig.GoogleClientID == "" || authConfig.GoogleClientSecret == "" {
		return nil, fmt.Errorf("구글 OAuth 설정이 누락되었습니다")
	}
	// 1. 구글 API를 통해 사용자 정보 조회
	// 2. 사용자 정보로 유저 생성 또는 조회
	// 3. 토큰 발급 및 저장
	// 4. 결과 반환

	req, err := http.NewRequest("GET", "https://www.googleapis.com/oauth2/v2/userinfo", nil)

	if err != nil {
		return nil, fmt.Errorf("요청 생성 실패: %w", err)
	}
	req.Header.Set("Authorization", "Bearer "+googleAccessToken)

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("요청 실행 실패: %w", err)
	}

	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)
	user := &GoogleUser{}
	err = json.Unmarshal(body, user)

	fmt.Println("unmarshal err:", err)
	fmt.Println("body:", string(body))

	info := SocialUserInfo{
		UserID:     userID,
		Provider:   "google",
		ProviderID: fmt.Sprintf("%v", user.ID),
		Email:      &user.Email,
		Name:       &user.Name,
		ProfileURL: &user.Picture,
	}

	fmt.Printf("Email: %s, Name: %s, ProfileURL: %s\n", *info.Email, *info.Name, *info.ProfileURL)

	return u.social.SocialLoginOrRegister(ctx, info)
}
