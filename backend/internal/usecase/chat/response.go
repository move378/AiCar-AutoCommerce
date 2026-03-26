package chat

import "time"

type SessionResponse struct {
	ID        string    `json:"id"`
	Title     *string   `json:"title"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type MessageResponse struct {
	ID        string    `json:"id"`
	SessionID string    `json:"session_id"`
	Role      string    `json:"role"`
	Content   string    `json:"content"`
	Metadata  *string   `json:"metadata,omitempty"`
	Feedback  *string   `json:"feedback,omitempty"`
	CreatedAt time.Time `json:"created_at"`
}
