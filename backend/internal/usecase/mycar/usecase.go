package mycar

import (
	"context"
	"errors"
	"time"

	"backend/internal/adapter/external"
	"backend/internal/domain/entity"
	domainRepo "backend/internal/domain/repository"
	"backend/internal/shared/errs"

	"github.com/google/uuid"
)

type Usecase interface {
	RegisterMyCar(ctx context.Context, userID, licensePlate string) (string, error)
	GetMyCarsByUserID(ctx context.Context, userID string) ([]entity.MyCar, error)
}

type usecase struct {
	myCarRepo   domainRepo.MyCarRepository
	carProvider external.CarInfoProvider
}

func NewUsecase(
	myCarRepo domainRepo.MyCarRepository,
	carProvider external.CarInfoProvider,
) Usecase {
	return &usecase{
		myCarRepo:   myCarRepo,
		carProvider: carProvider,
	}
}

func (u *usecase) RegisterMyCar(ctx context.Context, userID, licensePlate string) (string, error) {
	existing, err := u.myCarRepo.FindByUserIDAndPlate(ctx, userID, licensePlate)
	if err == nil && existing != nil {
		return "", errors.New("car already registered")
	}
	if err != nil && !errors.Is(err, errs.ErrNotFound) {
		return "", err
	}

	carInfo, err := u.carProvider.GetCarInfoByPlate(ctx, licensePlate)
	if err != nil {
		return "", err
	}

	now := time.Now()

	myCar := &entity.MyCar{
		ID:           uuid.New().String(),
		UserID:       userID,
		LicensePlate: carInfo.LicensePlate,
		Brand:        carInfo.Brand,
		Model:        carInfo.Model,
		Year:         carInfo.Year,
		FuelType:     carInfo.FuelType,
		CreatedAt:    now,
		UpdatedAt:    now,
	}

	if err := u.myCarRepo.Create(ctx, myCar); err != nil {
		return "", err
	}

	return myCar.ID, nil
}

func (u *usecase) GetMyCarsByUserID(ctx context.Context, userID string) ([]entity.MyCar, error) {
	return u.myCarRepo.FindByUserID(ctx, userID)
}
