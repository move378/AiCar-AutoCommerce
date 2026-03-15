// internal/usecase/auth/user_usecase.go
package auth

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
	"backend/internal/domain/repository"
	"backend/internal/shared/auth"
	"backend/internal/shared/errs"
)

type UserUsecase interface {
	Logout(ctx context.Context, accessToken string) error
	GetProfile(ctx context.Context, accessToken string) (*ProfileResult, error)
	DeleteAccount(ctx context.Context, userID uuid.UUID) error
}

type userUsecase struct {
	userRepo repository.UserRepository
}

func NewUserUsecase(
	userRepo repository.UserRepository,
) UserUsecase {
	return &authUsecase{
		userRepo: userRepo,
	}
}

type ProfileResult struct {
	Name       *string
	Gender     *string
	Birth      *time.Time
	Email      *string
	ProfileURL *string
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

func (u *authUsecase) GetProfile(ctx context.Context, accessToken string) (*ProfileResult, error) {
	userId, _, err := auth.ParseAccessToken(accessToken)

	if err != nil {
		return nil, errs.ErrUnauthorized
	}

	user, userErr := u.userRepo.FindByID(ctx, userId)

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

func (u *authUsecase) DeleteAccount(ctx context.Context, userID uuid.UUID) error {
	

	return nil
}