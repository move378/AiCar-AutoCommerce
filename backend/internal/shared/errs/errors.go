// internal/shared/errs/errors.go
package errs

import "errors"

var (
	ErrNotFound     = errors.New("리소스를 찾을 수 없습니다")
	ErrConflict     = errors.New("이미 존재하는 리소스입니다")
	ErrUnauthorized = errors.New("인증이 필요합니다")
	ErrForbidden    = errors.New("접근 권한이 없습니다")
)
