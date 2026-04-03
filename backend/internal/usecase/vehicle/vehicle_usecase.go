package vehicle

import (
	"context"
	"strings"

	"backend/internal/domain/repository"
	"backend/internal/shared/errs"
)

// brandAliases: 한국어 별칭 → DB에 저장된 실제 브랜드명
var brandAliases = map[string]string{
	"벤츠":        "Mercedes-Benz",
	"메르세데스":     "Mercedes-Benz",
	"메르세데스벤츠":   "Mercedes-Benz",
	"메르세데스-벤츠":  "Mercedes-Benz",
	"bmw":        "BMW",
	"아우디":        "Audi",
	"폭스바겐":       "Volkswagen",
	"폭바":         "Volkswagen",
	"포르쉐":        "Porsche",
	"렉서스":        "Lexus",
	"볼보":         "Volvo",
	"랜드로버":       "Land Rover",
	"재규어":        "Jaguar",
	"미니":         "MINI",
	"페라리":        "Ferrari",
	"람보르기니":      "Lamborghini",
	"마세라티":       "Maserati",
	"제네시스":       "Genesis",
	"현대":         "Hyundai",
	"기아":         "Kia",
	"도요타":        "Toyota",
	"혼다":         "Honda",
	"닛산":         "Nissan",
}

func resolveKeyword(kw string) string {
	lower := strings.ToLower(strings.TrimSpace(kw))
	if resolved, ok := brandAliases[lower]; ok {
		return resolved
	}
	return kw
}

type Usecase interface {
	Search(ctx context.Context, cond SearchCondition) (*SearchResult, error)
	GetDetail(ctx context.Context, id string) (*TrimDetailResponse, error)
	ListBrands(ctx context.Context) ([]BrandResponse, error)
}

type usecase struct {
	repo repository.VehicleRepository
}

func NewUsecase(repo repository.VehicleRepository) Usecase {
	return &usecase{repo: repo}
}

type SearchCondition struct {
	Page    int
	Size    int
	Keyword *string
}

func (u *usecase) Search(ctx context.Context, cond SearchCondition) (*SearchResult, error) {
	if cond.Page <= 0 {
		cond.Page = 1
	}
	if cond.Size <= 0 {
		cond.Size = 10
	}

	if cond.Keyword != nil && *cond.Keyword != "" {
		resolved := resolveKeyword(*cond.Keyword)
		cond.Keyword = &resolved
	}

	repoCond := repository.VehicleSearchCondition{
		Page:    cond.Page,
		Size:    cond.Size,
		Keyword: cond.Keyword,
	}

	trims, err := u.repo.Search(ctx, repoCond)
	if err != nil {
		return nil, err
	}

	total, err := u.repo.Count(ctx, repoCond)
	if err != nil {
		return nil, err
	}

	items := make([]TrimListItemResponse, 0, len(trims))
	for _, t := range trims {
		item := TrimListItemResponse{
			ID:        t.ID,
			BrandName: t.Model.Brand.Name,
			ModelName: t.Model.ModelName,
			TrimName:  t.TrimName,
			Year:      t.Year,
			BasePrice: t.BasePrice,
			FuelType:  t.FuelType,
			BodyType:  t.BodyType,
			Segment:   t.Model.Segment,
			ImageURL:  t.ImageURL,
		}
		if t.IceSpec != nil {
			item.FuelEffCombined = t.IceSpec.FuelEffCombined
		}
		items = append(items, item)
	}

	return &SearchResult{Items: items, Total: total}, nil
}

func (u *usecase) GetDetail(ctx context.Context, id string) (*TrimDetailResponse, error) {
	t, err := u.repo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}

	if t == nil {
		return nil, errs.ErrNotFound
	}

	resp := &TrimDetailResponse{
		ID:               t.ID,
		BrandName:        t.Model.Brand.Name,
		BrandLogoURL:     t.Model.Brand.LogoURL,
		ModelName:        t.Model.ModelName,
		Classification:   t.Model.Classification,
		Segment:          t.Model.Segment,
		TrimName:         t.TrimName,
		BodyType:         t.BodyType,
		Year:             t.Year,
		BasePrice:        t.BasePrice,
		FuelType:         t.FuelType,
		SeatingCapacity:  t.SeatingCapacity,
		MaxOutput:        t.MaxOutput,
		Acceleration:     t.Acceleration,
		Length:           t.Length,
		Width:            t.Width,
		Height:           t.Height,
		CurbWeight:       t.CurbWeight,
		Transmission:     t.Transmission,
		TransmissionType: t.TransmissionType,
		ImageURL:         t.ImageURL,
		TopSpeed:         t.TopSpeed,
		Doors:            t.Doors,
	}

	if t.IceSpec != nil {
		resp.IceSpec = &IceSpecResponse{
			Displacement:     t.IceSpec.Displacement,
			FuelTankCapacity: t.IceSpec.FuelTankCapacity,
			FuelEffCombined:  t.IceSpec.FuelEffCombined,
			FuelEffCity:      t.IceSpec.FuelEffCity,
			FuelEffHighway:   t.IceSpec.FuelEffHighway,
			EnergyGrade:      t.IceSpec.EnergyGrade,
			Cylinder:         t.IceSpec.Cylinder,
		}
	}

	if t.EvSpec != nil {
		resp.EvSpec = &EvSpecResponse{
			BatteryCapacity: t.EvSpec.BatteryCapacity,
			MaxRange:        t.EvSpec.MaxRange,
			EffCombined:     t.EvSpec.EffCombined,
			EffCity:         t.EvSpec.EffCity,
			EffHighway:      t.EvSpec.EffHighway,
			EnergyGrade:     t.EvSpec.EnergyGrade,
		}
	}

	images := make([]TrimImageResponse, 0, len(t.Images))
	for _, img := range t.Images {
		images = append(images, TrimImageResponse{
			ID:        img.ID,
			ImageURL:  img.ImageURL,
			ImageType: img.ImageType,
		})
	}
	resp.Images = images

	return resp, nil
}

func (u *usecase) ListBrands(ctx context.Context) ([]BrandResponse, error) {
	brands, err := u.repo.ListBrands(ctx)
	if err != nil {
		return nil, err
	}

	result := make([]BrandResponse, 0, len(brands))
	for _, b := range brands {
		result = append(result, BrandResponse{
			ID:      b.ID,
			Name:    b.Name,
			Country: b.Country,
			LogoURL: b.LogoURL,
		})
	}
	return result, nil
}
