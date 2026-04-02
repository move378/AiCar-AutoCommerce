package postgres

import (
	"context"
	"errors"
	"time"

	"backend/internal/domain/entity"
	"backend/internal/domain/repository"
	"backend/internal/shared/errs"

	"gorm.io/gorm"
)

type chatRepo struct {
	db *DB
}

func NewChatRepo(db *DB) repository.ChatRepository {
	return &chatRepo{db: db}
}

func (r *chatRepo) CreateSession(ctx context.Context, session *entity.ChatSession) error {
	return r.db.WithContext(ctx).Create(session).Error
}

func (r *chatRepo) GetSessionsByUserID(ctx context.Context, userID string) ([]entity.ChatSession, error) {
	var sessions []entity.ChatSession
	err := r.db.WithContext(ctx).
		Where("user_id = ? AND deleted_at IS NULL", userID).
		Order("updated_at DESC").
		Find(&sessions).Error
	return sessions, err
}

func (r *chatRepo) GetSessionByID(ctx context.Context, id string) (*entity.ChatSession, error) {
	var session entity.ChatSession
	err := r.db.WithContext(ctx).
		Where("id = ? AND deleted_at IS NULL", id).
		First(&session).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errs.ErrNotFound
		}
		return nil, err
	}
	return &session, nil
}

func (r *chatRepo) SoftDeleteSession(ctx context.Context, id string, userID string) error {
	now := time.Now()
	result := r.db.WithContext(ctx).
		Model(&entity.ChatSession{}).
		Where("id = ? AND user_id = ? AND deleted_at IS NULL", id, userID).
		Update("deleted_at", now)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return errs.ErrNotFound
	}
	return nil
}

func (r *chatRepo) CreateMessage(ctx context.Context, message *entity.ChatMessage) error {
	if err := r.db.WithContext(ctx).Create(message).Error; err != nil {
		return err
	}
	// 세션 updated_at 갱신
	return r.db.WithContext(ctx).
		Model(&entity.ChatSession{}).
		Where("id = ?", message.SessionID).
		Update("updated_at", time.Now()).Error
}

func (r *chatRepo) GetMessagesBySessionID(ctx context.Context, sessionID string) ([]entity.ChatMessage, error) {
	var messages []entity.ChatMessage
	err := r.db.WithContext(ctx).
		Where("session_id = ?", sessionID).
		Order("created_at ASC").
		Find(&messages).Error
	return messages, err
}

func (r *chatRepo) UpdateFeedback(ctx context.Context, messageID string, sessionUserID string, feedback string) error {
	result := r.db.WithContext(ctx).
		Model(&entity.ChatMessage{}).
		Where(`id = ? AND session_id IN (
			SELECT id FROM chat_sessions WHERE user_id = ? AND deleted_at IS NULL
		)`, messageID, sessionUserID).
		Update("feedback", feedback)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return errs.ErrNotFound
	}
	return nil
}
