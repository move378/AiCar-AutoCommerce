package entity

import "time"

type Estimate struct {
	ID             string     `gorm:"column:id;type:uuid;primaryKey"`
	UserID         string     `gorm:"column:user_id;type:uuid"`
	TrimID         string     `gorm:"column:trim_id;type:uuid"`
	PromotionID    *string    `gorm:"column:promotion_id;type:uuid"`
	ChatSessionID  string     `gorm:"column:chat_session_id;type:uuid"`
	BasePrice      int64      `gorm:"column:base_price"`
	DiscountAmount int64      `gorm:"column:discount_amount"`
	FinalPrice     int64      `gorm:"column:final_price"`
	Status         string     `gorm:"column:status"`
	CreatedAt      time.Time  `gorm:"column:created_at"`
	UpdatedAt      time.Time  `gorm:"column:updated_at"`

	Trim        VehicleTrim  `gorm:"foreignKey:TrimID"`
	Promotion   *Promotion   `gorm:"foreignKey:PromotionID"`
	ChatSession ChatSession  `gorm:"foreignKey:ChatSessionID"`
}

func (Estimate) TableName() string { return "estimates" }
