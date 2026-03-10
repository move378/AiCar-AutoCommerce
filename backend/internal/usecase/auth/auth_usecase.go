// internal/usecase/auth/auth_usecase.go
package auth

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"

	"backend/internal/config"
	"backend/internal/domain/entity"
	"backend/internal/domain/repository"
	"backend/internal/shared/auth"
	"backend/internal/shared/errs"
)

type AuthUsecase interface {
	Onboarding(ctx context.Context, device *OnboardingInput) (*TokenResult, error)
	Logout(ctx context.Context, accessToken string) error
	Refresh(ctx context.Context, refreshToken string) (*TokenResult, error)
}

type TokenResult struct {
	AccessToken  string
	RefreshToken string
}

type SocialTokenResult struct {
	IsNewUser bool
	TokenResult
}

type authUsecase struct {
	userRepo   repository.UserRepository
	deviceRepo repository.DeviceRepository
	tokenCache repository.TokenRepository
	txManager  repository.TxManager
}

func NewAuthUsecase(
	userRepo repository.UserRepository,
	deviceRepo repository.DeviceRepository,
	tokenCache repository.TokenRepository,
	txManager repository.TxManager,
) AuthUsecase {
	return &authUsecase{
		userRepo:   userRepo,
		deviceRepo: deviceRepo,
		tokenCache: tokenCache,
		txManager:  txManager,
	}
}

type OnboardingInput struct {
	DeviceUID  string
	DeviceType string
	ModelName  string
	OSVersion  string
	Latitude   *float64
	Longitude  *float64
}

// Onboarding: 디바이스 등록 + 유저 생성 + 토큰 발급
func (u *authUsecase) Onboarding(ctx context.Context, device *OnboardingInput) (*TokenResult, error) {
	// 1. 이미 등록된 디바이스인지 확인
	cfg := config.LoadConfig()
	existing, err := u.deviceRepo.FindByDeviceUID(ctx, device.DeviceUID)
	if err != nil && !errors.Is(err, errs.ErrNotFound) {
		return nil, fmt.Errorf("디바이스 조회 실패: %w", err)
	}
	if existing != nil {
		return nil, errs.ErrConflict
	}

	// 2. 유저 생성
	user := &entity.User{
		Latitude:  device.Latitude,
		Longitude: device.Longitude,
	}

	err = u.txManager.Transaction(ctx, func(ctx context.Context) error {
		if err := u.userRepo.Create(ctx, user); err != nil {
			return fmt.Errorf("유저 생성 실패: %w", err)
		}

		d := &entity.Device{
			UserID:     user.ID,
			DeviceUID:  device.DeviceUID,
			DeviceType: device.DeviceType,
			ModelName:  device.ModelName,
		}

		if err := u.deviceRepo.Create(ctx, d); err != nil {
			return fmt.Errorf("디바이스 생성 실패: %w", err)
		}

		return nil
	})

	if err != nil {
		return nil, err
	}

	// 4. 토큰 발급
	return u.generateTokens(ctx, cfg, user.ID)
}

// Logout: 액세스 토큰 블랙리스트 + 리프레쉬 토큰 삭제
func (u *authUsecase) Logout(ctx context.Context, accessToken string) error {
	userId, ttl, err := auth.ParseAccessToken(accessToken)

	if err != nil {
		return errs.ErrUnauthorized
	}
	if err := u.tokenCache.AddToBlacklist(ctx, accessToken, ttl); err != nil {
		return fmt.Errorf("블랙리스트 등록 실패: %w", err)
	}

	if err := u.tokenCache.DeleteByUserID(ctx, userId); err != nil {
		return fmt.Errorf("리프레시 토큰 삭제 실패: %w", err)
	}

	return nil
}

// Refresh: 리프레시 토큰 검증 + 새 토큰 발급
func (u *authUsecase) Refresh(ctx context.Context, refreshToken string) (*TokenResult, error) {
	cfg := config.LoadConfig()
	userID, _, err := auth.ParseRefreshToken(refreshToken)
	if err != nil {
		fmt.Println("리프레시 토큰 검증 실패:", err)
		return nil, errs.ErrUnauthorized
	}
	token, err := u.tokenCache.FindByUserID(ctx, userID)

	fmt.Println("토큰 조회 결과:", token, "err:", err)
	if err != nil {
		fmt.Println("토큰 조회 실패:", err)
		return nil, errs.ErrUnauthorized
	}

	if err := u.tokenCache.DeleteByUserID(ctx, userID); err != nil {
		fmt.Println("토큰 삭제 실패:", err)
		return nil, fmt.Errorf("토큰 삭제 실패: %w", err)
	}

	return u.generateTokens(ctx, cfg, token.UserID)
}

// generateTokens: 액세스/리프레시 토큰 생성 + 저장
func (u *authUsecase) generateTokens(ctx context.Context, cfg *config.Config, userID uuid.UUID) (*TokenResult, error) {
	accessToken, refreshToken, tokenErr := auth.GenerateTokens(cfg, userID) // JWT 생성

	if tokenErr != nil {
		return nil, fmt.Errorf("토큰 생성 실패: %w", tokenErr)
	}

	if err := u.tokenCache.Create(ctx, &entity.RefreshToken{
		UserID:    userID,
		Token:     refreshToken,
		ExpiresAt: time.Now().Add(cfg.JWT.RefreshExpiration), // 설정된 기간에 따라 달라짐
	}); err != nil {
		return nil, fmt.Errorf("토큰 저장 실패: %w", err)
	}

	return &TokenResult{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}, nil
}
