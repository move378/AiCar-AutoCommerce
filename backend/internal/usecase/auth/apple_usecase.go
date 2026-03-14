package auth

import (
	"backend/internal/domain/entity"
	"backend/internal/domain/repository"
	"backend/internal/shared/auth"
	"context"
	"fmt"

	"github.com/google/uuid"
)

type AppleUsecase interface {
	AppleLogin(ctx context.Context, userID uuid.UUID, identityToken string, name *string) (*SocialTokenResult, error)
}

type appleUsecase struct {
	social      SocialUsecase
	socialCache repository.SocialCacheRepository
	clientID    string // cfg.APPLE_CLIENT_ID가 담길 곳
}

func NewAppleUsecase(
	social SocialUsecase,
	socialCache repository.SocialCacheRepository,
	clientID string, // 컨테이너에서 cfg.APPLE_CLIENT_ID를 넘겨받음
) AppleUsecase {
	return &appleUsecase{
		social:      social,
		socialCache: socialCache,
		clientID:    clientID,
	}
}

func (u *appleUsecase) AppleLogin(ctx context.Context, userID uuid.UUID, identityToken string, name *string) (*SocialTokenResult, error) {
	// 1. 캐시 확인
	cached, cachedErr := u.socialCache.FindByProviderToken(ctx, identityToken)
	if cachedErr == nil && cached != nil {
		info := entity.SocialUserInfo{
			UserID:     userID,
			Provider:   "apple",
			ProviderID: cached.ProviderID,
			Email:      cached.Email,
			Name:       cached.Name,
		}
		return u.social.SocialLoginOrRegister(ctx, info)
	}

	// 2. 분리된 유틸 함수 호출하여 검증 및 디코딩
	claims, err := auth.VerifyAppleIdentityToken(identityToken, u.clientID)
	if err != nil {
		return nil, fmt.Errorf("apple auth failed: %w", err)
	}

	// 3. 엔티티 매핑 (앱 기반이므로 sub를 ProviderID로 사용)
	info := entity.SocialUserInfo{
		UserID:     userID,        // 현재 디바이스 임시 유저
		Provider:   "apple",
		ProviderID: claims.Sub,     // 불변 고유 ID
		Email:      &claims.Email,
		Name:       name,           // 프론트에서 받은 이름
	}

	// 4. 캐시 저장
	_ = u.socialCache.Create(ctx, identityToken, &entity.SocialUserInfo{
		Provider:   "apple",
		ProviderID: info.ProviderID,
		Email:      info.Email,
		Name:       info.Name,
	})

	// 5. 공통 로직 실행 (임시 유저 -> 정식 유저 전환)
	return u.social.SocialLoginOrRegister(ctx, info)
}