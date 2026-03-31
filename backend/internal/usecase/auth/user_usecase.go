// internal/usecase/auth/user_usecase.go
package auth

import (
	"context"
	"errors"
	"fmt"
	"time"

	"backend/internal/config"
	"backend/internal/domain/entity"
	"backend/internal/domain/repository"
	"backend/internal/shared/errs"
	"backend/internal/shared/token"

	"github.com/google/uuid"
)

type UserUsecase interface {
	Onboarding(ctx context.Context, device *OnboardingInput) (*token.TokenResult, error)
	Logout(ctx context.Context, accessToken string) error
	GetProfile(ctx context.Context, accessToken string) (*ProfileResult, error)
	DeleteAccount(ctx context.Context, userID uuid.UUID) error
	SocialLoginOrRegister(ctx context.Context, info entity.SocialUserInfo) (*SocialTokenResult, error)
}

type userUsecase struct {
	deviceRepo repository.DeviceRepository
	userRepo   repository.UserRepository
	socialRepo repository.SocialRepository
	tokenCache repository.TokenCacheRepository
	txManager  repository.TxManager
}

func NewUserUsecase(
	deviceRepo repository.DeviceRepository,
	userRepo repository.UserRepository,
	socialRepo repository.SocialRepository,
	tokenCache repository.TokenCacheRepository,
	txManager repository.TxManager,
) UserUsecase {
	return &userUsecase{
		deviceRepo: deviceRepo,
		userRepo:   userRepo,
		socialRepo: socialRepo,
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

type ProfileResult struct {
	Name       *string    `json:"name"`
	Gender     *string    `json:"gender"`
	Birth      *time.Time `json:"birth"`
	Email      *string    `json:"email"`
	ProfileURL *string    `json:"profile_url"`
}

// Onboarding: 디바이스 등록 + 유저 생성 + 토큰 발급
func (u *userUsecase) Onboarding(ctx context.Context, device *OnboardingInput) (*token.TokenResult, error) {
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
		if _, err := u.userRepo.Create(ctx, user); err != nil {
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

	accessToken, refreshToken, err := token.GenerateTokens(cfg, user.ID)

	// 4. 토큰 발급
	return &token.TokenResult{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}, nil
}

// Logout: 액세스 토큰 블랙리스트 + 리프레쉬 토큰 삭제
func (u *userUsecase) Logout(ctx context.Context, accessToken string) error {
	userId, ttl, err := token.ParseAccessToken(accessToken)

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

func (u *userUsecase) GetProfile(ctx context.Context, accessToken string) (*ProfileResult, error) {
	userID, _, err := token.ParseAccessToken(accessToken)

	if err != nil {
		return nil, errs.ErrUnauthorized
	}

	user, userErr := u.userRepo.FindByID(ctx, userID)

	if userErr != nil {
		return nil, fmt.Errorf("유저 정보 조회 실패: %w", userErr)
	}

	return &ProfileResult{
		Name:       user.Name,
		Gender:     user.Gender,
		Birth:      user.Birth,
		Email:      user.Email,
		ProfileURL: user.ProfileURL,
	}, nil
}

func (u *userUsecase) DeleteAccount(ctx context.Context, userID uuid.UUID) error {
	var newUser *entity.User
	var newUserErr error
	user, userErr := u.userRepo.FindByID(ctx, userID)

	if userErr != nil {
		return fmt.Errorf("유저 정보 조회 실패: %w", userErr)
	}

	if err := u.txManager.Transaction(ctx, func(ctx context.Context) error {
		if err := u.socialRepo.DeleteByUserID(ctx, userID); err != nil {
			return fmt.Errorf("소셜 유저 삭제 실패: %w", err)
		}

		us := &entity.User{
			Latitude:  user.Latitude,
			Longitude: user.Longitude,
		}

		newUser, newUserErr = u.userRepo.Create(ctx, us)

		if newUserErr != nil {
			return fmt.Errorf("유저 생성 실패: %w", newUserErr)
		}

		if err := u.deviceRepo.UpdateUserID(ctx, userID, newUser.ID); err != nil {
			return fmt.Errorf("디바이스 유저 아이디 업데이트 실패: %w", err)
		}

		if err := u.userRepo.Delete(ctx, userID); err != nil {
			return fmt.Errorf("유저 삭제 실패: %w", err)
		}

		return nil
	}); err != nil {
		return fmt.Errorf("회원 탈퇴 실패: %w", userErr)
	}

	return nil
}

func filterUserInfo(info entity.SocialUserInfo, existingUser *entity.User) entity.SocialUserInfo {
	if existingUser.Email == nil {
		existingUser.Email = info.Email
	}
	if existingUser.Name == nil {
		existingUser.Name = info.Name
	}
	if existingUser.ProfileURL == nil {
		existingUser.ProfileURL = info.ProfileURL
	}
	return entity.SocialUserInfo{
		UserID:     existingUser.ID,
		Provider:   info.Provider,
		ProviderID: info.ProviderID,
		Email:      existingUser.Email,
		Name:       existingUser.Name,
		ProfileURL: existingUser.ProfileURL,
	}
}

func (u *userUsecase) upsertUser(ctx context.Context, userID uuid.UUID, info entity.SocialUserInfo) error {
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
func (u *userUsecase) SocialLoginOrRegister(ctx context.Context, info entity.SocialUserInfo) (*SocialTokenResult, error) {
	var userID uuid.UUID
	var isNewUser bool = false

	cfg := config.LoadConfig()

	result, err := u.socialRepo.FindByProviderID(ctx, info.Provider, info.ProviderID)

	if errors.Is(err, errs.ErrNotFound) {
		userID = info.UserID
		isNewUser = true
		newProvider := &entity.SocialProvider{
			UserID:     userID,
			Provider:   info.Provider,
			ProviderID: info.ProviderID,
		}

		if err := u.socialRepo.Create(ctx, newProvider); err != nil {
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

	accessToken, refreshToken, err := token.GenerateTokens(cfg, userID)

	if err != nil {
		return nil, fmt.Errorf("JWT 생성 실패: %w", err)
	}

	if err := u.tokenCache.DeleteByUserID(ctx, userID); err != nil {
		return nil, fmt.Errorf("기존 토큰 삭제 실패: %w", err)
	}

	if err := u.tokenCache.Create(ctx, &entity.RefreshToken{
		UserID:    userID,
		Token:     refreshToken,
		ExpiresAt: time.Now().Add(time.Hour * 24 * 7),
	}); err != nil {
		return nil, fmt.Errorf("리프레시 토큰 저장 실패: %w", err)
	}

	return &SocialTokenResult{
		IsNewUser: isNewUser,
		TokenResult: token.TokenResult{
			AccessToken:  accessToken,
			RefreshToken: refreshToken,
		},
	}, nil
}
