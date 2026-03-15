package entity

import "time"

type MarketingConsent struct {
	ID              int64
	DeviceID        string
	MarketingAgreed bool
	AgreedAt        time.Time
	CreatedAt       time.Time
	UpdatedAt       time.Time
}
