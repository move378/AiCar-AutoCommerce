package entity

import "time"

type MyCar struct {
	ID           string    `json:"id"`
	UserID       string    `json:"user_id"`
	LicensePlate string    `json:"license_plate"`
	Brand        string    `json:"brand"`
	Model        string    `json:"model"`
	Year         int       `json:"year"`
	FuelType     string    `json:"fuel_type"`
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`
}
