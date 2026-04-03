package repository

import (
	"context"

	"backend/internal/domain/entity"
)

type ChatRepository interface {
	CreateSession(ctx context.Context, session *entity.ChatSession) error
	GetSessionsByUserID(ctx context.Context, userID string) ([]entity.ChatSession, error)
	GetSessionByID(ctx context.Context, id string) (*entity.ChatSession, error)
	SoftDeleteSession(ctx context.Context, id string, userID string) error

	CreateMessage(ctx context.Context, message *entity.ChatMessage) error
	GetMessagesBySessionID(ctx context.Context, sessionID string) ([]entity.ChatMessage, error)
	UpdateFeedback(ctx context.Context, messageID string, sessionUserID string, feedback string) error
}
