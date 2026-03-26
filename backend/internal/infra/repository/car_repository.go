package repository

import (
	"context"
	"database/sql"
	"fmt"

	"backend/internal/domain/entity"
	domainrepo "backend/internal/domain/repository"
	"backend/internal/shared/errs"
)

type carRepository struct {
	db *sql.DB
}

func NewCarRepository(db *sql.DB) domainrepo.CarRepository {
	return &carRepository{db: db}
}

func (r *carRepository) List(ctx context.Context, cond domainrepo.CarListCondition) ([]entity.Car, error) {
	fmt.Println("DEBUG: carRepository.List called, sort =", cond.Sort)
	orderBy := "c.created_at DESC"

	switch cond.Sort {
	case "price_asc":
		orderBy = "c.price ASC"
	case "price_desc":
		orderBy = "c.price DESC"
	case "year_asc":
		orderBy = "c.year ASC"
	case "year_desc":
		orderBy = "c.year DESC"
	case "created_at_asc":
		orderBy = "c.created_at ASC"
	case "created_at_desc", "":
		orderBy = "c.created_at DESC"
	default:
		orderBy = "c.created_at DESC"
	}

	query := `
		SELECT
			c.id,
			c.model_id,
			c.trim_name,
			c.year,
			c.price,
			c.fuel_type,
			c.fuel_efficiency,
			c.transmission,
			c.engine_displacement,
			c.status,
			c.thumbnail_url
		FROM cars c
		WHERE c.deleted_at IS NULL
		ORDER BY ` + orderBy + `
		LIMIT $1 OFFSET $2
	`

	page := cond.Page
	size := cond.Size

	if page <= 0 {
		page = 1
	}
	if size <= 0 {
		size = 10
	}

	offset := (page - 1) * size

	rows, err := r.db.QueryContext(ctx, query, size, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	items := make([]entity.Car, 0)
	for rows.Next() {
		var item entity.Car
		if err := rows.Scan(
			&item.ID,
			&item.ModelID,
			&item.TrimName,
			&item.Year,
			&item.Price,
			&item.FuelType,
			&item.FuelEfficiency,
			&item.Transmission,
			&item.EngineDisplacement,
			&item.Status,
			&item.ThumbnailURL,
		); err != nil {
			return nil, err
		}
		items = append(items, item)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return items, nil
}

func (r *carRepository) GetByID(ctx context.Context, id string) (*entity.Car, error) {
	query := `
		SELECT
			c.id,
			c.model_id,
			c.trim_name,
			c.year,
			c.price,
			c.fuel_type,
			c.fuel_efficiency,
			c.transmission,
			c.engine_displacement,
			c.status,
			c.thumbnail_url
		FROM cars c
		WHERE c.id = $1
		  AND c.deleted_at IS NULL
	`

	var car entity.Car
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&car.ID,
		&car.ModelID,
		&car.TrimName,
		&car.Year,
		&car.Price,
		&car.FuelType,
		&car.FuelEfficiency,
		&car.Transmission,
		&car.EngineDisplacement,
		&car.Status,
		&car.ThumbnailURL,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, errs.ErrNotFound
		}
		return nil, err
	}

	return &car, nil
}

func (r *carRepository) Count(ctx context.Context, cond domainrepo.CarListCondition) (int64, error) {
	query := `SELECT COUNT(*) FROM cars WHERE deleted_at IS NULL`
	var total int64
	if err := r.db.QueryRowContext(ctx, query).Scan(&total); err != nil {
		return 0, fmt.Errorf("차량 개수 조회 실패: %w", err)
	}
	return total, nil
}

func (r *carRepository) GetImagesByCarID(ctx context.Context, carID string) ([]entity.CarImage, error) {
	query := `
		SELECT
			id,
			car_id,
			image_url,
			sort_order
		FROM car_images
		WHERE car_id = $1
		ORDER BY sort_order ASC, id ASC
	`

	rows, err := r.db.QueryContext(ctx, query, carID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	images := make([]entity.CarImage, 0)
	for rows.Next() {
		var img entity.CarImage
		if err := rows.Scan(
			&img.ID,
			&img.CarID,
			&img.ImageURL,
			&img.SortOrder,
		); err != nil {
			return nil, err
		}
		images = append(images, img)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return images, nil
}
