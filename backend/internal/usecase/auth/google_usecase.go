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
	user        UserUsecase
	socialCache repository.SocialCacheRepository
}

func NewGoogleUsecase(
	user UserUsecase,
	socialCache repository.SocialCacheRepository,
) GoogleUsecase {
	return &googleUsecase{
		user:        user,
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
			Provider:   "google",
			ProviderID: cached.ProviderID,
			Email:      cached.Email,
			Name:       cached.Name,
			ProfileURL: cached.ProfileURL,
		}
		return u.user.SocialLoginOrRegister(ctx, info)
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

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("구글 API 오류 (status: %d)", resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("응답 읽기 실패: %w", err)
	}

	user := &GoogleUser{}
	if err = json.Unmarshal(body, user); err != nil {
		return nil, fmt.Errorf("응답 파싱 실패: %w", err)
	}

	if user.ID == "" {
		return nil, fmt.Errorf("구글 유저 정보를 가져올 수 없습니다")
	}

	info := entity.SocialUserInfo{
		UserID:     userID,
		Provider:   "google",
		ProviderID: user.ID,
		Email:      &user.Email,
		Name:       &user.Name,
		ProfileURL: &user.Picture,
	}

	// 캐시 저장
	_ = u.socialCache.Create(ctx, googleAccessToken, &entity.SocialUserInfo{
		Provider:   "google",
		ProviderID: info.ProviderID,
		Email:      info.Email,
		Name:       info.Name,
		ProfileURL: info.ProfileURL,
	})

	return u.user.SocialLoginOrRegister(ctx, info)
}
