package entity

import "time"

type Brand struct {
	ID        string    `gorm:"column:id;type:uuid;primaryKey"`
	Name      string    `gorm:"column:name"`
	CreatedAt time.Time `gorm:"column:created_at"`
	UpdatedAt time.Time `gorm:"column:updated_at"`
}

func (Brand) TableName() string {
	return "brands"
}

type CarModel struct {
	ID        string    `gorm:"column:id;type:uuid;primaryKey"`
	BrandID   string    `gorm:"column:brand_id;type:uuid"`
	Name      string    `gorm:"column:name"`
	Segment   *string   `gorm:"column:segment"`
	IsActive  bool      `gorm:"column:is_active"`
	CreatedAt time.Time `gorm:"column:created_at"`
	UpdatedAt time.Time `gorm:"column:updated_at"`

	Brand Brand `gorm:"foreignKey:BrandID"`
}

func (CarModel) TableName() string {
	return "car_models"
}

type Car struct {
	ID                 string     `gorm:"column:id;type:uuid;primaryKey"`
	ModelID            string     `gorm:"column:model_id;type:uuid"`
	TrimName           *string    `gorm:"column:trim_name"`
	Year               int        `gorm:"column:year"`
	Price              int        `gorm:"column:price"`
	FuelType           *string    `gorm:"column:fuel_type"`
	FuelEfficiency     *float64   `gorm:"column:fuel_efficiency"`
	Transmission       *string    `gorm:"column:transmission"`
	EngineDisplacement *int       `gorm:"column:engine_displacement"`
	Status             string     `gorm:"column:status"`
	ThumbnailURL       *string    `gorm:"column:thumbnail_url"`
	CreatedAt          time.Time  `gorm:"column:created_at"`
	UpdatedAt          time.Time  `gorm:"column:updated_at"`
	DeletedAt          *time.Time `gorm:"column:deleted_at"`

	Model CarModel `gorm:"foreignKey:ModelID"`
}

func (Car) TableName() string {
	return "cars"
}

type CarImage struct {
	ID          string    `gorm:"column:id;type:uuid;primaryKey"`
	CarID       string    `gorm:"column:car_id;type:uuid"`
	ImageURL    string    `gorm:"column:image_url"`
	IsThumbnail bool      `gorm:"column:is_thumbnail"`
	SortOrder   int       `gorm:"column:sort_order"`
	CreatedAt   time.Time `gorm:"column:created_at"`
}

func (CarImage) TableName() string {
	return "car_images"
}
