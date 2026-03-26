package chat

import (
	"context"

	"backend/internal/domain/entity"
	"backend/internal/domain/repository"
)

type Usecase interface {
	CreateSession(ctx context.Context, userID string, title *string) (*SessionResponse, error)
	GetSessions(ctx context.Context, userID string) ([]SessionResponse, error)
	DeleteSession(ctx context.Context, sessionID string, userID string) error

	CreateMessage(ctx context.Context, sessionID string, userID string, role string, content string, metadata *string) (*MessageResponse, error)
	GetMessages(ctx context.Context, sessionID string, userID string) ([]MessageResponse, error)

	UpdateFeedback(ctx context.Context, messageID string, userID string, feedback string) error
}

type usecase struct {
	repo repository.ChatRepository
}

func NewUsecase(repo repository.ChatRepository) Usecase {
	return &usecase{repo: repo}
}

func (u *usecase) CreateSession(ctx context.Context, userID string, title *string) (*SessionResponse, error) {
	session := &entity.ChatSession{
		UserID: userID,
		Title:  title,
	}
	if err := u.repo.CreateSession(ctx, session); err != nil {
		return nil, err
	}
	return toSessionResponse(session), nil
}

func (u *usecase) GetSessions(ctx context.Context, userID string) ([]SessionResponse, error) {
	sessions, err := u.repo.GetSessionsByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}
	result := make([]SessionResponse, 0, len(sessions))
	for _, s := range sessions {
		result = append(result, *toSessionResponse(&s))
	}
	return result, nil
}

func (u *usecase) DeleteSession(ctx context.Context, sessionID string, userID string) error {
	return u.repo.SoftDeleteSession(ctx, sessionID, userID)
}

func (u *usecase) CreateMessage(ctx context.Context, sessionID string, userID string, role string, content string, metadata *string) (*MessageResponse, error) {
	// 세션이 해당 유저 소유인지 확인
	if _, err := u.repo.GetSessionByID(ctx, sessionID); err != nil {
		return nil, err
	}

	msg := &entity.ChatMessage{
		SessionID: sessionID,
		Role:      role,
		Content:   content,
		Metadata:  metadata,
	}
	if err := u.repo.CreateMessage(ctx, msg); err != nil {
		return nil, err
	}
	return toMessageResponse(msg), nil
}

func (u *usecase) GetMessages(ctx context.Context, sessionID string, userID string) ([]MessageResponse, error) {
	// 세션이 해당 유저 소유인지 확인
	if _, err := u.repo.GetSessionByID(ctx, sessionID); err != nil {
		return nil, err
	}

	messages, err := u.repo.GetMessagesBySessionID(ctx, sessionID)
	if err != nil {
		return nil, err
	}
	result := make([]MessageResponse, 0, len(messages))
	for _, m := range messages {
		result = append(result, *toMessageResponse(&m))
	}
	return result, nil
}

func (u *usecase) UpdateFeedback(ctx context.Context, messageID string, userID string, feedback string) error {
	return u.repo.UpdateFeedback(ctx, messageID, userID, feedback)
}

func toSessionResponse(s *entity.ChatSession) *SessionResponse {
	return &SessionResponse{
		ID:        s.ID,
		Title:     s.Title,
		CreatedAt: s.CreatedAt,
		UpdatedAt: s.UpdatedAt,
	}
}

func toMessageResponse(m *entity.ChatMessage) *MessageResponse {
	return &MessageResponse{
		ID:        m.ID,
		SessionID: m.SessionID,
		Role:      m.Role,
		Content:   m.Content,
		Metadata:  m.Metadata,
		Feedback:  m.Feedback,
		CreatedAt: m.CreatedAt,
	}
}
