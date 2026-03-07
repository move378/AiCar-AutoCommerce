package auth

import (
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
	SocialLoginOrRegister(ctx context.Context, info SocialUserInfo) (*TokenResult, error)
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

// 소셜 로그인 또는 회원가입 처리
func (u *authSocialUsecase) SocialLoginOrRegister(ctx context.Context, info SocialUserInfo) (*TokenResult, error) {
	var userID uuid.UUID
	result, err := u.providerRepo.FindByProviderID(ctx, info.Provider, info.ProviderID)

	fmt.Printf("소셜 계정 조회 결과: %v, 에러: %v\n", result, err)

	if errors.Is(err, errs.ErrNotFound) {
		userID = info.UserID
		newProvider := &entity.UserAuthProvider{
			UserID:     userID,
			Provider:   info.Provider,
			ProviderID: info.ProviderID,
		}

		if err := u.providerRepo.Create(ctx, newProvider); err != nil {
			return nil, fmt.Errorf("소셜 계정 생성 실패: %w", err)
		}

		updateUser := &entity.User{
			ID:         userID,
			Email:      info.Email,
			Name:       info.Name,
			ProfileURL: info.ProfileURL,
			Status:     "registered",
		}

		if err := u.userRepo.Update(ctx, updateUser); err != nil {
			return nil, fmt.Errorf("유저 정보 업데이트 실패: %w", err)
		}

	} else if err != nil {
		return nil, fmt.Errorf("소셜 계정 조회 실패: %w", err)
	} else {
		userID = result.UserID
	}

	accessToken, refreshToken, err := auth.GenerateTokens(userID)

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

	return &TokenResult{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}, nil
}
