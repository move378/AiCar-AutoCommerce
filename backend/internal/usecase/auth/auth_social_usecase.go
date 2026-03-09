package auth

import (
	"backend/internal/config"
	"backend/internal/domain/entity"
	"backend/internal/domain/repository"
	"backend/internal/shared/auth"
	"backend/internal/shared/errs"
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
)

type SocialUserInfo struct {
	UserID     uuid.UUID
	Provider   string
	ProviderID string
	Email      *string
	Name       *string
	ProfileURL *string
}

type AuthSocialUsecase interface {
	SocialLoginOrRegister(ctx context.Context, info SocialUserInfo) (*SocialTokenResult, error)
}

type authSocialUsecase struct {
	userRepo     repository.UserRepository
	providerRepo repository.UserAuthProviderRepository
	tokenRepo    repository.TokenRepository
}

func NewSocialUsecase(
	userRepo repository.UserRepository,
	providerRepo repository.UserAuthProviderRepository,
	tokenRepo repository.TokenRepository,
) AuthSocialUsecase {
	return &authSocialUsecase{
		userRepo:     userRepo,
		providerRepo: providerRepo,
		tokenRepo:    tokenRepo,
	}
}

func filterUserInfo(info SocialUserInfo, existingUser *entity.User) SocialUserInfo {
	if existingUser.Email == nil {
		existingUser.Email = info.Email
	}
	if existingUser.Name == nil {
		existingUser.Name = info.Name
	}
	if existingUser.ProfileURL == nil {
		existingUser.ProfileURL = info.ProfileURL
	}
	return SocialUserInfo{
		UserID:     existingUser.ID,
		Provider:   info.Provider,
		ProviderID: info.ProviderID,
		Email:      existingUser.Email,
		Name:       existingUser.Name,
		ProfileURL: existingUser.ProfileURL,
	}
}

func (u *authSocialUsecase) upsertUser(ctx context.Context, userID uuid.UUID, info SocialUserInfo) error {
	existingUser, err := u.userRepo.FindByID(ctx, userID)
	if err != nil {
		return fmt.Errorf("유저 조회 실패: %w", err)
	}

	filterUserInfo(info, existingUser)
	existingUser.Status = "registered" // 상태 업데이트
	if err := u.userRepo.Update(ctx, existingUser); err != nil {
		return fmt.Errorf("유저 정보 업데이트 실패: %w", err)
	}

	return nil
}

// 소셜 로그인 또는 회원가입 처리
func (u *authSocialUsecase) SocialLoginOrRegister(ctx context.Context, info SocialUserInfo) (*SocialTokenResult, error) {
	var userID uuid.UUID
	var isNewUser bool = false

	cfg := config.LoadConfig()
	result, err := u.providerRepo.FindByProviderID(ctx, info.Provider, info.ProviderID)

	if errors.Is(err, errs.ErrNotFound) {
		userID = info.UserID
		isNewUser = true
		newProvider := &entity.UserAuthProvider{
			UserID:     userID,
			Provider:   info.Provider,
			ProviderID: info.ProviderID,
		}

		if err := u.providerRepo.Create(ctx, newProvider); err != nil {
			return nil, fmt.Errorf("소셜 계정 생성 실패: %w", err)
		}

	} else if err != nil {
		return nil, fmt.Errorf("소셜 계정 조회 실패: %w", err)
	} else {
		userID = result.UserID
	}

	if err := u.upsertUser(ctx, userID, info); err != nil {
		return nil, fmt.Errorf("유저 정보 업데이트 실패: %w", err)
	}

	accessToken, refreshToken, err := auth.GenerateTokens(cfg, userID)

	if err != nil {
		return nil, fmt.Errorf("JWT 생성 실패: %w", err)
	}

	if err := u.tokenRepo.DeleteByUserID(ctx, userID); err != nil {
		return nil, fmt.Errorf("기존 토큰 삭제 실패: %w", err)
	}

	if err := u.tokenRepo.Create(ctx, &entity.RefreshToken{
		UserID:    userID,
		Token:     refreshToken,
		ExpiresAt: time.Now().Add(time.Hour * 24 * 7),
	}); err != nil {
		return nil, fmt.Errorf("리프레시 토큰 저장 실패: %w", err)
	}

	return &SocialTokenResult{
		IsNewUser: isNewUser,
		TokenResult: TokenResult{
			AccessToken:  accessToken,
			RefreshToken: refreshToken,
		},
	}, nil
}
