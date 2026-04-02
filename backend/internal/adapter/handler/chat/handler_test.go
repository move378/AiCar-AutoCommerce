package chat

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"backend/internal/shared/errs"
	chatusecase "backend/internal/usecase/chat"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type mockChatUsecase struct {
	createSessionFn  func(ctx context.Context, userID string, title *string) (*chatusecase.SessionResponse, error)
	getSessionsFn    func(ctx context.Context, userID string) ([]chatusecase.SessionResponse, error)
	deleteSessionFn  func(ctx context.Context, sessionID, userID string) error
	createMessageFn  func(ctx context.Context, sessionID, userID, role, content string, metadata *string) (*chatusecase.MessageResponse, error)
	getMessagesFn    func(ctx context.Context, sessionID, userID string) ([]chatusecase.MessageResponse, error)
	updateFeedbackFn func(ctx context.Context, messageID, userID, feedback string) error
}

func (m *mockChatUsecase) CreateSession(ctx context.Context, userID string, title *string) (*chatusecase.SessionResponse, error) {
	return m.createSessionFn(ctx, userID, title)
}
func (m *mockChatUsecase) GetSessions(ctx context.Context, userID string) ([]chatusecase.SessionResponse, error) {
	return m.getSessionsFn(ctx, userID)
}
func (m *mockChatUsecase) DeleteSession(ctx context.Context, sessionID, userID string) error {
	return m.deleteSessionFn(ctx, sessionID, userID)
}
func (m *mockChatUsecase) CreateMessage(ctx context.Context, sessionID, userID, role, content string, metadata *string) (*chatusecase.MessageResponse, error) {
	return m.createMessageFn(ctx, sessionID, userID, role, content, metadata)
}
func (m *mockChatUsecase) GetMessages(ctx context.Context, sessionID, userID string) ([]chatusecase.MessageResponse, error) {
	return m.getMessagesFn(ctx, sessionID, userID)
}
func (m *mockChatUsecase) UpdateFeedback(ctx context.Context, messageID, userID, feedback string) error {
	return m.updateFeedbackFn(ctx, messageID, userID, feedback)
}

var chatTestUserID = uuid.MustParse("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb")

func setupChatRouter(uc chatusecase.Usecase) *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	auth := func(c *gin.Context) {
		c.Set("user_id", chatTestUserID)
		c.Next()
	}
	h := NewHandler(uc)
	g := r.Group("/chat", auth)
	g.POST("/sessions", h.CreateSession)
	g.GET("/sessions", h.GetSessions)
	g.DELETE("/sessions/:id", h.DeleteSession)
	g.POST("/sessions/:id/messages", h.CreateMessage)
	g.GET("/sessions/:id/messages", h.GetMessages)
	g.PATCH("/messages/:id/feedback", h.UpdateFeedback)
	return r
}

func sampleSession(id string) *chatusecase.SessionResponse {
	title := "테스트 세션"
	return &chatusecase.SessionResponse{
		ID:        id,
		Title:     &title,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
}

func sampleMessage(id, sessionID string) *chatusecase.MessageResponse {
	return &chatusecase.MessageResponse{
		ID:        id,
		SessionID: sessionID,
		Role:      "user",
		Content:   "안녕하세요",
		CreatedAt: time.Now(),
	}
}

// ============================================================
// POST /chat/sessions
// ============================================================

func TestChatCreateSession_Success(t *testing.T) {
	uc := &mockChatUsecase{
		createSessionFn: func(_ context.Context, _ string, _ *string) (*chatusecase.SessionResponse, error) {
			return sampleSession("sess-001"), nil
		},
	}
	r := setupChatRouter(uc)

	body := map[string]any{"title": "내 첫 채팅"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/chat/sessions", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusCreated {
		t.Fatalf("expected 201, got %d — body: %s", w.Code, w.Body.String())
	}
	var resp chatusecase.SessionResponse
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("응답 파싱 실패: %v", err)
	}
	if resp.ID != "sess-001" {
		t.Errorf("id 불일치: got %s", resp.ID)
	}
}

func TestChatCreateSession_NoTitle(t *testing.T) {
	uc := &mockChatUsecase{
		createSessionFn: func(_ context.Context, _ string, title *string) (*chatusecase.SessionResponse, error) {
			// title이 nil이어도 정상 동작
			return sampleSession("sess-002"), nil
		},
	}
	r := setupChatRouter(uc)

	req := httptest.NewRequest(http.MethodPost, "/chat/sessions", bytes.NewReader([]byte(`{}`)))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusCreated {
		t.Fatalf("expected 201, got %d", w.Code)
	}
}

// ============================================================
// GET /chat/sessions
// ============================================================

func TestChatGetSessions_Success(t *testing.T) {
	uc := &mockChatUsecase{
		getSessionsFn: func(_ context.Context, _ string) ([]chatusecase.SessionResponse, error) {
			return []chatusecase.SessionResponse{
				*sampleSession("sess-001"),
				*sampleSession("sess-002"),
			}, nil
		},
	}
	r := setupChatRouter(uc)

	req := httptest.NewRequest(http.MethodGet, "/chat/sessions", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", w.Code)
	}
	var resp map[string]any
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("응답 파싱 실패: %v", err)
	}
	items := resp["items"].([]any)
	if len(items) != 2 {
		t.Errorf("items 개수 불일치: want 2, got %d", len(items))
	}
}

// ============================================================
// DELETE /chat/sessions/:id
// ============================================================

func TestChatDeleteSession_Success(t *testing.T) {
	uc := &mockChatUsecase{
		deleteSessionFn: func(_ context.Context, _, _ string) error { return nil },
	}
	r := setupChatRouter(uc)

	req := httptest.NewRequest(http.MethodDelete, "/chat/sessions/sess-001", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusNoContent {
		t.Fatalf("expected 204, got %d — body: %s", w.Code, w.Body.String())
	}
}

func TestChatDeleteSession_NotFound(t *testing.T) {
	uc := &mockChatUsecase{
		deleteSessionFn: func(_ context.Context, _, _ string) error { return errs.ErrNotFound },
	}
	r := setupChatRouter(uc)

	req := httptest.NewRequest(http.MethodDelete, "/chat/sessions/nonexistent", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusNotFound {
		t.Fatalf("expected 404, got %d", w.Code)
	}
}

// ============================================================
// POST /chat/sessions/:id/messages
// ============================================================

func TestChatCreateMessage_Success(t *testing.T) {
	uc := &mockChatUsecase{
		createMessageFn: func(_ context.Context, sessionID, _, _, _ string, _ *string) (*chatusecase.MessageResponse, error) {
			return sampleMessage("msg-001", sessionID), nil
		},
	}
	r := setupChatRouter(uc)

	body := map[string]any{
		"role":    "user",
		"content": "안녕하세요",
	}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/chat/sessions/sess-001/messages", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusCreated {
		t.Fatalf("expected 201, got %d — body: %s", w.Code, w.Body.String())
	}
	var resp chatusecase.MessageResponse
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("응답 파싱 실패: %v", err)
	}
	if resp.ID != "msg-001" {
		t.Errorf("id 불일치: got %s", resp.ID)
	}
	if resp.Role != "user" {
		t.Errorf("role 불일치: got %s", resp.Role)
	}
}

func TestChatCreateMessage_MissingFields(t *testing.T) {
	uc := &mockChatUsecase{}
	r := setupChatRouter(uc)

	body := map[string]any{"role": "user"} // content 누락
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/chat/sessions/sess-001/messages", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Fatalf("expected 400, got %d", w.Code)
	}
}

func TestChatCreateMessage_SessionNotFound(t *testing.T) {
	uc := &mockChatUsecase{
		createMessageFn: func(_ context.Context, _, _, _, _ string, _ *string) (*chatusecase.MessageResponse, error) {
			return nil, errs.ErrNotFound
		},
	}
	r := setupChatRouter(uc)

	body := map[string]any{"role": "user", "content": "hello"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/chat/sessions/nonexistent/messages", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusNotFound {
		t.Fatalf("expected 404, got %d", w.Code)
	}
}

// ============================================================
// GET /chat/sessions/:id/messages
// ============================================================

func TestChatGetMessages_Success(t *testing.T) {
	uc := &mockChatUsecase{
		getMessagesFn: func(_ context.Context, sessionID, _ string) ([]chatusecase.MessageResponse, error) {
			return []chatusecase.MessageResponse{
				*sampleMessage("msg-001", sessionID),
				*sampleMessage("msg-002", sessionID),
			}, nil
		},
	}
	r := setupChatRouter(uc)

	req := httptest.NewRequest(http.MethodGet, "/chat/sessions/sess-001/messages", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", w.Code)
	}
	var resp map[string]any
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("응답 파싱 실패: %v", err)
	}
	items := resp["items"].([]any)
	if len(items) != 2 {
		t.Errorf("items 개수 불일치: want 2, got %d", len(items))
	}
}

func TestChatGetMessages_SessionNotFound(t *testing.T) {
	uc := &mockChatUsecase{
		getMessagesFn: func(_ context.Context, _, _ string) ([]chatusecase.MessageResponse, error) {
			return nil, errs.ErrNotFound
		},
	}
	r := setupChatRouter(uc)

	req := httptest.NewRequest(http.MethodGet, "/chat/sessions/nonexistent/messages", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusNotFound {
		t.Fatalf("expected 404, got %d", w.Code)
	}
}

// ============================================================
// PATCH /chat/messages/:id/feedback
// ============================================================

func TestChatUpdateFeedback_Like(t *testing.T) {
	uc := &mockChatUsecase{
		updateFeedbackFn: func(_ context.Context, _, _, _ string) error { return nil },
	}
	r := setupChatRouter(uc)

	body := map[string]any{"feedback": "like"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPatch, "/chat/messages/msg-001/feedback", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d — body: %s", w.Code, w.Body.String())
	}
	var resp map[string]any
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("응답 파싱 실패: %v", err)
	}
	if resp["message"] != "ok" {
		t.Errorf("message 불일치: got %v", resp["message"])
	}
}

func TestChatUpdateFeedback_Dislike(t *testing.T) {
	uc := &mockChatUsecase{
		updateFeedbackFn: func(_ context.Context, _, _, _ string) error { return nil },
	}
	r := setupChatRouter(uc)

	body := map[string]any{"feedback": "dislike"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPatch, "/chat/messages/msg-001/feedback", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", w.Code)
	}
}

func TestChatUpdateFeedback_InvalidValue(t *testing.T) {
	uc := &mockChatUsecase{}
	r := setupChatRouter(uc)

	body := map[string]any{"feedback": "meh"} // like/dislike 아닌 값
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPatch, "/chat/messages/msg-001/feedback", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Fatalf("expected 400, got %d", w.Code)
	}
}

func TestChatUpdateFeedback_MessageNotFound(t *testing.T) {
	uc := &mockChatUsecase{
		updateFeedbackFn: func(_ context.Context, _, _, _ string) error { return errs.ErrNotFound },
	}
	r := setupChatRouter(uc)

	body := map[string]any{"feedback": "like"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPatch, "/chat/messages/nonexistent/feedback", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusNotFound {
		t.Fatalf("expected 404, got %d", w.Code)
	}
}
