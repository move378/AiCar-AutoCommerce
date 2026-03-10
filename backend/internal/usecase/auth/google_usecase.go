package auth

import (
	"backend/internal/config"
	"backend/internal/domain/entity"
	"backend/internal/domain/repository"
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
	social      AuthSocialUsecase
	socialCache repository.SocialCacheRepository
}

func NewGoogleUsecase(
	social AuthSocialUsecase,
	socialCache repository.SocialCacheRepository,
) GoogleUsecase {
	return &googleUsecase{
		social:      social,
		socialCache: socialCache,
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

	cached, cachedErr := u.socialCache.FindByProviderToken(ctx, googleAccessToken)
	if cachedErr == nil && cached != nil {
		info := entity.SocialUserInfo{
			UserID:     userID,
			Provider:   "kakao",
			ProviderID: cached.ProviderID,
			Email:      cached.Email,
			Name:       cached.Name,
			ProfileURL: cached.ProfileURL,
		}
		return u.social.SocialLoginOrRegister(ctx, info)
	}

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

	info := entity.SocialUserInfo{
		UserID:     userID,
		Provider:   "google",
		ProviderID: fmt.Sprintf("%v", user.ID),
		Email:      &user.Email,
		Name:       &user.Name,
		ProfileURL: &user.Picture,
	}

	// 캐시 저장
	_ = u.socialCache.Create(ctx, googleAccessToken, &entity.SocialUserInfo{
		Provider:   "kakao",
		ProviderID: info.ProviderID,
		Email:      info.Email,
		Name:       info.Name,
		ProfileURL: info.ProfileURL,
	})

	return u.social.SocialLoginOrRegister(ctx, info)
}
