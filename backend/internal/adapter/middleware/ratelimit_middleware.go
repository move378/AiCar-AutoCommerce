package middleware

import (
	"net/http"
	"sync"
	"time"

	"backend/internal/shared/response"

	"github.com/gin-gonic/gin"
)

type rateLimitEntry struct {
	count     int
	windowEnd time.Time
}

type ipRateLimiter struct {
	mu      sync.Mutex
	entries map[string]*rateLimitEntry
	limit   int
	window  time.Duration
}

func newIPRateLimiter(limit int, window time.Duration) *ipRateLimiter {
	rl := &ipRateLimiter{
		entries: make(map[string]*rateLimitEntry),
		limit:   limit,
		window:  window,
	}
	// 만료된 엔트리 주기적으로 정리
	go rl.cleanup()
	return rl
}

func (rl *ipRateLimiter) allow(ip string) bool {
	rl.mu.Lock()
	defer rl.mu.Unlock()

	now := time.Now()
	entry, ok := rl.entries[ip]
	if !ok || now.After(entry.windowEnd) {
		rl.entries[ip] = &rateLimitEntry{count: 1, windowEnd: now.Add(rl.window)}
		return true
	}

	if entry.count >= rl.limit {
		return false
	}

	entry.count++
	return true
}

func (rl *ipRateLimiter) cleanup() {
	ticker := time.NewTicker(5 * time.Minute)
	defer ticker.Stop()
	for range ticker.C {
		rl.mu.Lock()
		now := time.Now()
		for ip, entry := range rl.entries {
			if now.After(entry.windowEnd) {
				delete(rl.entries, ip)
			}
		}
		rl.mu.Unlock()
	}
}

// RateLimitMiddleware: IP 기반 요청 제한
// limit: 윈도우 내 최대 요청 수, window: 시간 윈도우
func RateLimitMiddleware(limit int, window time.Duration) gin.HandlerFunc {
	limiter := newIPRateLimiter(limit, window)

	return func(c *gin.Context) {
		ip := c.ClientIP()
		if !limiter.allow(ip) {
			response.SendError(c, http.StatusTooManyRequests, "TOO_MANY_REQUESTS", "요청이 너무 많습니다. 잠시 후 다시 시도해주세요.")
			c.Abort()
			return
		}
		c.Next()
	}
}
