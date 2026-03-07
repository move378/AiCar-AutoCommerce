package auth

import (
	"context"
	"fmt"
	"io"
	"net/http"

	"github.com/goccy/go-json"
	"github.com/google/uuid"
)

type KakaoUsecase interface {
	KakaoLogin(ctx context.Context, userID uuid.UUID, kakaoAccessToken string) (*TokenResult, error)
	//GoogleLogin(ctx context.Context, googleAccessToken string) (*TokenResult, error)
	//AppleLogin(ctx context.Context, identityToken string) (*TokenResult, error)
}

type kakaoUsecase struct {
	social AuthSocialUsecase
}

func NewKakaoUsecase(
	social AuthSocialUsecase,
) KakaoUsecase {
	return &kakaoUsecase{
		social: social,
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

func (u *kakaoUsecase) KakaoLogin(ctx context.Context, userID uuid.UUID, kakaoAccessToken string) (*TokenResult, error) {
	// 1. 카카오 API를 통해 사용자 정보 조회
	// 2. 사용자 정보로 유저 생성 또는 조회
	// 3. 토큰 발급 및 저장
	// 4. 결과 반환

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

	body, _ := io.ReadAll(resp.Body)
	user := &KakaoUser{}
	err = json.Unmarshal(body, user)

	fmt.Println("unmarshal err:", err)
	fmt.Println("body:", string(body))

	info := SocialUserInfo{
		UserID:     userID,
		Provider:   "kakao",
		ProviderID: fmt.Sprintf("%d", user.ID),
		Email:      &user.KakaoAccount.Email,
		Name:       &user.KakaoAccount.Profile.Nickname,
		ProfileURL: &user.KakaoAccount.Profile.ProfileImage,
	}

	return u.social.SocialLoginOrRegister(ctx, info)
}

// {
//   "id": 12345678,
//   "kakao_account": {
//     "email": "test@kakao.com",
//     "profile": {
//       "nickname": "홍길동",
//       "profile_image_url": "https://..."
//     }
//   }
// }
