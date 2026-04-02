package entity

import "time"

type ChatSession struct {
	ID        string     `gorm:"column:id;type:uuid;primaryKey"`
	UserID    string     `gorm:"column:user_id;type:uuid"`
	Title     *string    `gorm:"column:title"`
	CreatedAt time.Time  `gorm:"column:created_at"`
	UpdatedAt time.Time  `gorm:"column:updated_at"`
	DeletedAt *time.Time `gorm:"column:deleted_at"`

	Messages []ChatMessage `gorm:"foreignKey:SessionID"`
}

func (ChatSession) TableName() string { return "chat_sessions" }

type ChatMessage struct {
	ID        string     `gorm:"column:id;type:uuid;primaryKey"`
	SessionID string     `gorm:"column:session_id;type:uuid"`
	Role      string     `gorm:"column:role"`
	Content   string     `gorm:"column:content"`
	Metadata  *string    `gorm:"column:metadata;type:jsonb"`
	Feedback  *string    `gorm:"column:feedback"`
	CreatedAt time.Time  `gorm:"column:created_at"`
}

func (ChatMessage) TableName() string { return "chat_messages" }
