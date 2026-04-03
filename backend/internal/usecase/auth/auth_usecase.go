// internal/usecase/auth/auth_usecase.go
package auth

import (
	"context"
	"errors"
	"fmt"

	"backend/internal/config"
	"backend/internal/domain/repository"
	"backend/internal/shared/errs"
	"backend/internal/shared/token"
)

type AuthUsecase interface {
	OnboardingRefresh(ctx context.Context, deviceUID string) (*token.TokenResult, error)
	Refresh(ctx context.Context, refreshToken string) (*token.TokenResult, error)
}

type SocialTokenResult struct {
	IsNewUser bool
	token.TokenResult
}

type authUsecase struct {
	userRepo   repository.UserRepository
	deviceRepo repository.DeviceRepository
	tokenCache repository.TokenCacheRepository
	txManager  repository.TxManager
}

func NewAuthUsecase(
	userRepo repository.UserRepository,
	deviceRepo repository.DeviceRepository,
	tokenCache repository.TokenCacheRepository,
	txManager repository.TxManager,
) AuthUsecase {
	return &authUsecase{
		userRepo:   userRepo,
		deviceRepo: deviceRepo,
		tokenCache: tokenCache,
		txManager:  txManager,
	}
}

func (u *authUsecase) OnboardingRefresh(ctx context.Context, deviceUID string) (*token.TokenResult, error) {
	cfg := config.LoadConfig()
	device, err := u.deviceRepo.FindByDeviceUID(ctx, deviceUID)

	if errors.Is(err, errs.ErrNotFound) {
		return nil, errs.ErrNotFound
	}
	if err != nil {
		return nil, fmt.Errorf("디바이스 조회 실패: %w", err)
	}

	user, userErr := u.userRepo.FindByID(ctx, device.UserID)

	if userErr != nil {
		return nil, fmt.Errorf("유저 조회 실패: %w", userErr)
	}

	if user.Status != "guest" {
		return nil, errs.ErrForbidden
	}

	if err := u.tokenCache.DeleteByUserID(ctx, user.ID); err != nil && !errors.Is(err, errs.ErrNotFound) {
		return nil, fmt.Errorf("토큰 삭제 실패: %w", err)
	}

	return token.GenerateAndStoreTokens(ctx, cfg, u.tokenCache, user.ID)
}

// Refresh: 리프레시 토큰 검증 + 새 토큰 발급
func (u *authUsecase) Refresh(ctx context.Context, refreshToken string) (*token.TokenResult, error) {
	cfg := config.LoadConfig()
	userID, _, err := token.ParseRefreshToken(refreshToken)
	if err != nil {
		return nil, errs.ErrUnauthorized
	}
	tokenData, err := u.tokenCache.FindByUserID(ctx, userID)
	if err != nil {
		return nil, errs.ErrUnauthorized
	}

	if err := u.tokenCache.DeleteByUserID(ctx, userID); err != nil {
		return nil, fmt.Errorf("토큰 삭제 실패: %w", err)
	}

	return token.GenerateAndStoreTokens(ctx, cfg, u.tokenCache, tokenData.UserID)
}
