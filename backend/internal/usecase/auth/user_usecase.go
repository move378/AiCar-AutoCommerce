// internal/usecase/auth/user_usecase.go
package auth

import (
	"context"
	"fmt"
	"time"

	"backend/internal/domain/repository"
	"backend/internal/shared/auth"
	"backend/internal/shared/errs"
)

type UserUsecase interface {
	GetProfile(ctx context.Context, accessToken string) (*ProfileResult, error)
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
