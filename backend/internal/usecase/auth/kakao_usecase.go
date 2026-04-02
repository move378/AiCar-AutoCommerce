package auth

import (
	"backend/internal/domain/entity"
	"backend/internal/domain/repository"
	"context"
	"fmt"
	"io"
	"net/http"

	"github.com/goccy/go-json"
	"github.com/google/uuid"
)

type KakaoUsecase interface {
	KakaoLogin(ctx context.Context, userID uuid.UUID, kakaoAccessToken string) (*SocialTokenResult, error)
}

type kakaoUsecase struct {
	user        UserUsecase
	socialCache repository.SocialCacheRepository
}

func NewKakaoUsecase(
	user UserUsecase,
	socialCache repository.SocialCacheRepository,
) KakaoUsecase {
	return &kakaoUsecase{
		user:        user,
		socialCache: socialCache,
	}
}

type KakaoUser struct {
	ID           int64 `json:"id"`
	KakaoAccount struct {
		Email   string `json:"email"`
		Profile struct {
			Nickname     string `json:"nickname"`
			ProfileImage string `json:"profile_image_url"`
		} `json:"profile"`
	} `json:"kakao_account"`
}

func (u *kakaoUsecase) KakaoLogin(ctx context.Context, userID uuid.UUID, kakaoAccessToken string) (*SocialTokenResult, error) {
	// cached, cachedErr := u.socialCache.FindByProviderToken(ctx, kakaoAccessToken)
	// if cachedErr == nil && cached != nil {
	// 	info := entity.SocialUserInfo{
	// 		UserID:     userID,
	// 		Provider:   "kakao",
	// 		ProviderID: cached.ProviderID,
	// 		Email:      cached.Email,
	// 		Name:       cached.Name,
	// 		ProfileURL: cached.ProfileURL,
	// 	}
	// 	return u.user.SocialLoginOrRegister(ctx, info)
	// }

	req, err := http.NewRequest("GET", "https://kapi.kakao.com/v2/user/me", nil)
	if err != nil {
		return nil, fmt.Errorf("요청 생성 실패: %w", err)
	}
	req.Header.Set("Authorization", "Bearer "+kakaoAccessToken)

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("요청 실행 실패: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("카카오 API 오류 (status: %d)", resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("응답 읽기 실패: %w", err)
	}

	user := &KakaoUser{}
	if err = json.Unmarshal(body, user); err != nil {
		return nil, fmt.Errorf("응답 파싱 실패: %w", err)
	}

	if user.ID == 0 {
		return nil, fmt.Errorf("카카오 유저 정보를 가져올 수 없습니다")
	}

	info := entity.SocialUserInfo{
		UserID:     userID,
		Provider:   "kakao",
		ProviderID: fmt.Sprintf("%d", user.ID),
		Email:      &user.KakaoAccount.Email,
		Name:       &user.KakaoAccount.Profile.Nickname,
		ProfileURL: &user.KakaoAccount.Profile.ProfileImage,
	}

	// 캐시 저장
	_ = u.socialCache.Create(ctx, kakaoAccessToken, &entity.SocialUserInfo{
		Provider:   "kakao",
		ProviderID: info.ProviderID,
		Email:      info.Email,
		Name:       info.Name,
		ProfileURL: info.ProfileURL,
	})

	return u.user.SocialLoginOrRegister(ctx, info)
}
