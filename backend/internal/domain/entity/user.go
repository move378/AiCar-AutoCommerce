package entity

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// User: 'users' 테이블 스키마
type User struct {
	ID         uuid.UUID      `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	Name       string         `gorm:"size:100" json:"name"`
	Gender     string         `gorm:"size:10" json:"gender"`
	Birth      *time.Time     `gorm:"type:date" json:"birth"`
	Location   string         `gorm:"type:text" json:"location"`
	OAuthType  string         `gorm:"size:20" json:"oauth_type"`
	OAuthID    string         `gorm:"size:255" json:"oauth_id"`
	Email      string         `gorm:"size:255;uniqueIndex" json:"email"`
	ProfileURL string         `gorm:"type:text" json:"profile_url"`
	CreatedAt  time.Time      `json:"created_at"`
	UpdatedAt  time.Time      `json:"updated_at"`
	DeletedAt  gorm.DeletedAt `gorm:"index" json:"-"`
}

// Device: 'devices' 테이블 스키마
type Device struct {
	ID         uuid.UUID `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	UserID     uuid.UUID `gorm:"type:uuid;not null" json:"user_id"`
	DeviceUID  string    `gorm:"size:255;uniqueIndex;not null" json:"device_uid"`
	DeviceType string    `gorm:"size:20" json:"device_type"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`

	// 관계 설정
	User User `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE" json:"-"`
}

// RefreshToken: 'refresh_tokens' 테이블 스키마
type RefreshToken struct {
	ID        uuid.UUID `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	UserID    uuid.UUID `gorm:"type:uuid;not null" json:"user_id"`
	Token     string    `gorm:"type:text;not null" json:"token"`
	ExpiresAt time.Time `json:"expires_at"`
	CreatedAt time.Time `json:"created_at"`
}
