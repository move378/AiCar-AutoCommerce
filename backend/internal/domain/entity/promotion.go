package entity

import "time"

type Promotion struct {
	ID             string    `gorm:"column:id;type:uuid;primaryKey"`
	TrimID         string    `gorm:"column:trim_id;type:uuid"`
	PurchaseMethod string    `gorm:"column:purchase_method"`
	DiscountAmount int64     `gorm:"column:discount_amount"`
	StartDate      time.Time `gorm:"column:start_date"`
	EndDate        time.Time `gorm:"column:end_date"`
	CreatedAt      time.Time `gorm:"column:created_at"`
	UpdatedAt      time.Time `gorm:"column:updated_at"`

	Trim VehicleTrim `gorm:"foreignKey:TrimID"`
}

func (Promotion) TableName() string { return "promotions" }
