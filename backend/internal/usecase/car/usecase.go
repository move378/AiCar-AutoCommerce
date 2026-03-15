package car

import (
	"context"

	"backend/internal/domain/entity"
	"backend/internal/domain/repository"
)

type CarUsecase interface {
	ListCars(ctx context.Context, req ListCarsCondition) ([]CarListItemResponse, error)
	GetCarDetail(ctx context.Context, id string) (*CarDetailResponse, error)
	GetCarImages(ctx context.Context, carID string) ([]entity.CarImage, error)
}

type carUsecase struct {
	carRepo repository.CarRepository
}

type ListCarsCondition struct {
	Page     int
	Size     int
	BrandID  *string
	FuelType *string
	MinPrice *int
	MaxPrice *int
	Sort     string
}

func NewCarUsecase(carRepo repository.CarRepository) CarUsecase {
	return &carUsecase{carRepo: carRepo}
}

func (u *carUsecase) ListCars(ctx context.Context, req ListCarsCondition) ([]CarListItemResponse, error) {
	if req.Page <= 0 {
		req.Page = 1
	}
	if req.Size <= 0 {
		req.Size = 10
	}
	if req.Sort == "" {
		req.Sort = "created_at_desc"
	}

	cars, err := u.carRepo.List(ctx, repository.CarListCondition{
		Page:     req.Page,
		Size:     req.Size,
		BrandID:  req.BrandID,
		FuelType: req.FuelType,
		MinPrice: req.MinPrice,
		MaxPrice: req.MaxPrice,
		Sort:     req.Sort,
	})
	if err != nil {
		return nil, err
	}

	result := make([]CarListItemResponse, 0, len(cars))
	for _, car := range cars {
		result = append(result, CarListItemResponse{
			ID:                 car.ID,
			ModelID:            car.ModelID,
			BrandName:          car.Model.Brand.Name,
			ModelName:          car.Model.Name,
			TrimName:           car.TrimName,
			Year:               car.Year,
			Price:              car.Price,
			FuelType:           car.FuelType,
			FuelEfficiency:     car.FuelEfficiency,
			Transmission:       car.Transmission,
			EngineDisplacement: car.EngineDisplacement,
			Status:             car.Status,
			ThumbnailURL:       car.ThumbnailURL,
		})
	}

	return result, nil
}

func (u *carUsecase) GetCarDetail(ctx context.Context, id string) (*CarDetailResponse, error) {
	car, err := u.carRepo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}

	images, err := u.carRepo.GetImagesByCarID(ctx, id)
	if err != nil {
		return nil, err
	}

	imageResponses := make([]CarImageResponse, 0, len(images))
	for _, img := range images {
		imageResponses = append(imageResponses, CarImageResponse{
			ID:          img.ID,
			CarID:       img.CarID,
			ImageURL:    img.ImageURL,
			IsThumbnail: img.IsThumbnail,
			SortOrder:   img.SortOrder,
		})
	}

	return &CarDetailResponse{
		ID:                 car.ID,
		ModelID:            car.ModelID,
		TrimName:           car.TrimName,
		Year:               car.Year,
		Price:              car.Price,
		FuelType:           car.FuelType,
		FuelEfficiency:     car.FuelEfficiency,
		Transmission:       car.Transmission,
		EngineDisplacement: car.EngineDisplacement,
		Status:             car.Status,
		ThumbnailURL:       car.ThumbnailURL,
		Images:             imageResponses,
	}, nil
}

func (u *carUsecase) GetCarImages(ctx context.Context, carID string) ([]entity.CarImage, error) {
	return u.carRepo.GetImagesByCarID(ctx, carID)
}
