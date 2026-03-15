package postgres

import (
	"context"
	"fmt"

	"backend/internal/domain/entity"
	"backend/internal/domain/repository"
)

type brandRepo struct {
	db *DB
}

func NewBrandRepo(db *DB) repository.BrandRepository {
	return &brandRepo{db: db}
}

func (r *brandRepo) List(ctx context.Context) ([]entity.Brand, error) {
	var brands []entity.Brand

	err := r.db.WithContext(ctx).
		Order("name ASC").
		Find(&brands).Error
	if err != nil {
		return nil, fmt.Errorf("브랜드 목록 조회 실패: %w", err)
	}

	return brands, nil
}
