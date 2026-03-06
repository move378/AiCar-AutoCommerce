// internal/usecase/auth/auth_usecase.go
package auth

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"

	"backend/internal/domain/entity"
	"backend/internal/domain/repository"
	"backend/internal/shared/auth"
	"backend/internal/shared/errs"
)

type AuthUsecase interface {
	Onboarding(ctx context.Context, device *entity.Device) (*TokenResult, error)
	Refresh(ctx context.Context, refreshToken string) (*TokenResult, error)
}

type TokenResult struct {
	AccessToken  string
	RefreshToken string
}

type authUsecase struct {
	userRepo   repository.UserRepository
	deviceRepo repository.DeviceRepository
	tokenRepo  repository.TokenRepository
}

func NewAuthUsecase(
	userRepo repository.UserRepository,
	deviceRepo repository.DeviceRepository,
	tokenRepo repository.TokenRepository,
) AuthUsecase {
	return &authUsecase{
		userRepo:   userRepo,
		deviceRepo: deviceRepo,
		tokenRepo:  tokenRepo,
	}
}

// Onboarding: 디바이스 등록 + 유저 생성 + 토큰 발급
func (u *authUsecase) Onboarding(ctx context.Context, device *entity.Device) (*TokenResult, error) {
	// 1. 이미 등록된 디바이스인지 확인
	existing, err := u.deviceRepo.FindByDeviceUID(ctx, device.DeviceUID)
	if err != nil && !errors.Is(err, errs.ErrNotFound) {
		return nil, fmt.Errorf("디바이스 조회 실패: %w", err)
	}
	if existing != nil {
		return nil, errs.ErrConflict
	}

	// 2. 유저 생성
	user := &entity.User{}

	if err := u.userRepo.Create(ctx, user); err != nil {
		return nil, fmt.Errorf("유저 생성 실패: %w", err)
	}

	// 3. 디바이스 생성
	d := &entity.Device{
		UserID:     user.ID,
		DeviceUID:  device.DeviceUID,
		DeviceType: device.DeviceType,
		ModelName:  device.ModelName,
	}
	if err := u.deviceRepo.Create(ctx, d); err != nil {
		return nil, fmt.Errorf("디바이스 생성 실패: %w", err)
	}

	// 4. 토큰 발급
	return u.generateTokens(ctx, user.ID)
}

// Refresh: 리프레시 토큰 검증 + 새 토큰 발급
func (u *authUsecase) Refresh(ctx context.Context, refreshToken string) (*TokenResult, error) {
	token, err := u.tokenRepo.FindByToken(ctx, refreshToken)
	if err != nil {
		return nil, errs.ErrUnauthorized
	}

	if time.Now().After(token.ExpiresAt) {
		return nil, errs.ErrUnauthorized
	}

	if err := u.tokenRepo.DeleteByToken(ctx, refreshToken); err != nil {
		return nil, fmt.Errorf("토큰 삭제 실패: %w", err)
	}

	return u.generateTokens(ctx, token.UserID)
}

// generateTokens: 액세스/리프레시 토큰 생성 + 저장
func (u *authUsecase) generateTokens(ctx context.Context, userID uuid.UUID) (*TokenResult, error) {
	accessToken, refreshToken, tokenErr := auth.GenerateTokens(userID) // JWT 생성

	if tokenErr != nil {
		return nil, fmt.Errorf("토큰 생성 실패: %w", tokenErr)
	}

	if err := u.tokenRepo.Create(ctx, &entity.RefreshToken{
		UserID:    userID,
		Token:     refreshToken,
		ExpiresAt: time.Now().Add(30 * 24 * time.Hour), // 30일
	}); err != nil {
		return nil, fmt.Errorf("토큰 저장 실패: %w", err)
	}

	return &TokenResult{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}, nil
}
