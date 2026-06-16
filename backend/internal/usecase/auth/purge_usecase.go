package auth

import (
	"context"
	"fmt"
	"log"
	"time"

	"backend/internal/domain/repository"
)

type PurgeUsecase interface {
	PurgeDeletedUsers(ctx context.Context) error
}

type purgeUsecase struct {
	userRepo     repository.UserRepository
	chatRepo     repository.ChatRepository
	myCarRepo    repository.MyCarRepository
	estimateRepo repository.EstimateRepository
	txManager    repository.TxManager
}

func NewPurgeUsecase(
	userRepo repository.UserRepository,
	chatRepo repository.ChatRepository,
	myCarRepo repository.MyCarRepository,
	estimateRepo repository.EstimateRepository,
	txManager repository.TxManager,
) PurgeUsecase {
	return &purgeUsecase{
		userRepo:     userRepo,
		chatRepo:     chatRepo,
		myCarRepo:    myCarRepo,
		estimateRepo: estimateRepo,
		txManager:    txManager,
	}
}

// PurgeDeletedUsers: 탈퇴 후 6개월이 지난 유저의 데이터를 영구 삭제
func (u *purgeUsecase) PurgeDeletedUsers(ctx context.Context) error {
	cutoff := time.Now().AddDate(0, -6, 0)

	users, err := u.userRepo.FindDeletedBefore(ctx, cutoff)
	if err != nil {
		return fmt.Errorf("삭제 대상 유저 조회 실패: %w", err)
	}

	log.Printf("[purge] 삭제 대상 유저 %d명", len(users))

	for _, user := range users {
		userIDStr := user.ID.String()

		if err := u.txManager.Transaction(ctx, func(ctx context.Context) error {
			if err := u.chatRepo.DeleteAllByUserID(ctx, userIDStr); err != nil {
				return fmt.Errorf("채팅 데이터 삭제 실패: %w", err)
			}
			if err := u.myCarRepo.DeleteByUserID(ctx, userIDStr); err != nil {
				return fmt.Errorf("내 차 데이터 삭제 실패: %w", err)
			}
			if err := u.estimateRepo.DeleteByUserID(ctx, userIDStr); err != nil {
				return fmt.Errorf("견적 데이터 삭제 실패: %w", err)
			}
			if err := u.userRepo.HardDelete(ctx, user.ID); err != nil {
				return fmt.Errorf("유저 영구 삭제 실패: %w", err)
			}
			return nil
		}); err != nil {
			log.Printf("[purge] 유저 %s 삭제 실패: %v", userIDStr, err)
			continue
		}

		log.Printf("[purge] 유저 %s 영구 삭제 완료", userIDStr)
	}

	return nil
}
