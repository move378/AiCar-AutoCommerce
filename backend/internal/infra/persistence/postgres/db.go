// internal/infra/persistence/postgres/db.go
package postgres

import (
	"context"
	"fmt"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"

	"backend/internal/config"
)

type DB struct {
	*gorm.DB
}

func NewDB(cfg *config.Config) (*DB, error) {
	dsn := fmt.Sprintf(
		"host=%s user=%s password=%s dbname=%s port=%s sslmode=disable TimeZone=Asia/Seoul",
		cfg.DB.Host,
		cfg.DB.User,
		cfg.DB.Password,
		cfg.DB.Name,
		cfg.DB.Port,
	)

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		return nil, fmt.Errorf("데이터베이스 연결 실패: %w", err)
	}

	return &DB{db}, nil
}

func (d *DB) Transaction(ctx context.Context, fn func(ctx context.Context) error) error {
	return d.DB.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		txCtx := context.WithValue(ctx, txKey{}, &DB{tx})
		return fn(txCtx)
	})
}

type txKey struct{}

func GetTx(ctx context.Context, db *DB) *DB {
	if tx, ok := ctx.Value(txKey{}).(*DB); ok {
		return tx
	}
	return db
}
