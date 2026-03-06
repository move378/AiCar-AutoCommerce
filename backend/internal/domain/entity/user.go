package entity

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// User: 'users' 테이블 (00002_create_users.sql 기준)
type User struct {
	ID         uuid.UUID      `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	Name       string         `gorm:"size:100" json:"name"`
	Gender     string         `gorm:"size:10" json:"gender"`
	Birth      *time.Time     `gorm:"type:date" json:"birth"`
	Location   string         `gorm:"type:text" json:"location"`
	OAuthType  string         `gorm:"column:oauth_type;size:20" json:"oauth_type"`
	OAuthID    string         `gorm:"column:oauth_id;size:255" json:"oauth_id"`
	Email      *string        `gorm:"size:255;uniqueIndex" json:"email"`
	ProfileURL string         `gorm:"column:profile_url;type:text" json:"profile_url"`
	CreatedAt  time.Time      `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt  time.Time      `gorm:"autoUpdateTime" json:"updated_at"`
	DeletedAt  gorm.DeletedAt `gorm:"index" json:"-"`
}

// Device: 'devices' 테이블 (00012_create_devices.sql 기준)
type Device struct {
	ID         uuid.UUID `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	UserID     uuid.UUID `gorm:"column:user_id;type:uuid;not null" json:"user_id"`
	DeviceUID  string    `gorm:"column:device_uid;size:255;not null;uniqueIndex" json:"device_uid"`
	DeviceType string    `gorm:"column:device_type;size:20" json:"device_type"`
	ModelName  string    `gorm:"column:model_name;size:20" json:"model_name"`
	OSVersion  string    `gorm:"column:os_version;size:20" json:"os_version"`
	CreatedAt  time.Time `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt  time.Time `gorm:"autoUpdateTime" json:"updated_at"`
	User       User      `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE" json:"-"`
}

// RefreshToken: 'tokens' 테이블 (00013_create_tokens.sql 기준)
// SQL 파일에서 테이블명이 'tokens'이므로 명시적 설정이 필요합니다.
type RefreshToken struct {
	ID        uuid.UUID `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	UserID    uuid.UUID `gorm:"type:uuid;not null" json:"user_id"`
	Token     string    `gorm:"type:text;not null" json:"token"`
	ExpiresAt time.Time `gorm:"not null" json:"expires_at"`
	CreatedAt time.Time `gorm:"autoCreateTime" json:"created_at"`

	// 관계 설정 (Belongs To)
	User User `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE" json:"-"`
}

// TableName: GORM이 기본값(refresh_tokens) 대신 'tokens' 테이블을 찾도록 지정
func (RefreshToken) TableName() string {
	return "tokens"
}
