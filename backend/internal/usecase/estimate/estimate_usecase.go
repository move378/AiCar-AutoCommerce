package estimate

import (
	"context"
	"time"

	"backend/internal/domain/entity"
	"backend/internal/domain/repository"
)

type Usecase interface {
	Create(ctx context.Context, userID, trimID, chatSessionID string, promotionID *string) (*EstimateResponse, error)
	GetByID(ctx context.Context, id, userID string) (*EstimateResponse, error)
	GetByUserID(ctx context.Context, userID string) ([]EstimateResponse, error)
}

type usecase struct {
	estimateRepo  repository.EstimateRepository
	promotionRepo repository.PromotionRepository
	vehicleRepo   repository.VehicleRepository
}

func NewUsecase(
	estimateRepo repository.EstimateRepository,
	promotionRepo repository.PromotionRepository,
	vehicleRepo repository.VehicleRepository,
) Usecase {
	return &usecase{
		estimateRepo:  estimateRepo,
		promotionRepo: promotionRepo,
		vehicleRepo:   vehicleRepo,
	}
}

func (u *usecase) Create(ctx context.Context, userID, trimID, chatSessionID string, promotionID *string) (*EstimateResponse, error) {
	trim, err := u.vehicleRepo.GetByID(ctx, trimID)
	if err != nil {
		return nil, err
	}

	basePrice := int64(0)
	if trim.BasePrice != nil {
		basePrice = *trim.BasePrice
	}

	discountAmount := int64(0)
	if promotionID != nil {
		promotion, err := u.promotionRepo.GetByID(ctx, *promotionID)
		if err != nil {
			return nil, err
		}
		discountAmount = promotion.DiscountAmount
	}

	estimate := &entity.Estimate{
		UserID:         userID,
		TrimID:         trimID,
		PromotionID:    promotionID,
		ChatSessionID:  chatSessionID,
		BasePrice:      basePrice,
		DiscountAmount: discountAmount,
		FinalPrice:     basePrice - discountAmount,
		Status:         "draft",
	}

	if err := u.estimateRepo.Create(ctx, estimate); err != nil {
		return nil, err
	}
	estimate.Trim = *trim
	return toResponse(estimate), nil
}

func (u *usecase) GetByID(ctx context.Context, id, userID string) (*EstimateResponse, error) {
	estimate, err := u.estimateRepo.GetByID(ctx, id, userID)
	if err != nil {
		return nil, err
	}
	return toResponse(estimate), nil
}

func (u *usecase) GetByUserID(ctx context.Context, userID string) ([]EstimateResponse, error) {
	estimates, err := u.estimateRepo.GetByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}
	result := make([]EstimateResponse, 0, len(estimates))
	for _, e := range estimates {
		result = append(result, *toResponse(&e))
	}
	return result, nil
}

type EstimateResponse struct {
	ID             string     `json:"id"`
	TrimID         string     `json:"trim_id"`
	TrimName       string     `json:"trim_name"`
	PromotionID    *string    `json:"promotion_id,omitempty"`
	ChatSessionID  string     `json:"chat_session_id"`
	BasePrice      int64      `json:"base_price"`
	DiscountAmount int64      `json:"discount_amount"`
	FinalPrice     int64      `json:"final_price"`
	Status         string     `json:"status"`
	CreatedAt      time.Time  `json:"created_at"`
}

func toResponse(e *entity.Estimate) *EstimateResponse {
	return &EstimateResponse{
		ID:             e.ID,
		TrimID:         e.TrimID,
		TrimName:       e.Trim.TrimName,
		PromotionID:    e.PromotionID,
		ChatSessionID:  e.ChatSessionID,
		BasePrice:      e.BasePrice,
		DiscountAmount: e.DiscountAmount,
		FinalPrice:     e.FinalPrice,
		Status:         e.Status,
		CreatedAt:      e.CreatedAt,
	}
}
