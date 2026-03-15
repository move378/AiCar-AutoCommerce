package brand

import (
	"context"

	"backend/internal/domain/entity"
	"backend/internal/domain/repository"
)

type BrandUsecase interface {
	ListBrands(ctx context.Context) ([]entity.Brand, error)
}

type brandUsecase struct {
	brandRepo repository.BrandRepository
}

func NewBrandUsecase(brandRepo repository.BrandRepository) BrandUsecase {
	return &brandUsecase{brandRepo: brandRepo}
}

func (u *brandUsecase) ListBrands(ctx context.Context) ([]entity.Brand, error) {
	return u.brandRepo.List(ctx)
}
