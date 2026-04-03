---
phase: 05-ai-chat
created: 2026-04-02
source: /paul:discuss
---

# Phase 5 Discussion Context

## Goals
1. GNB 3번째 탭 "챗봇" → AI 상담 Chat UI 구현
2. 키워드 매칭 MVP 10 시나리오 자동 응답
3. 기존 디자인 시스템 위젯 최대 재사용 (ChatBubble만 신규)
4. CARL 규칙 준수 (freezed, 듀얼 구현체, backendTypeProvider)

## Scope Decisions
- **히스토리 목록 → 05-02로 분리** (헤더 우측 버튼은 placeholder)
- **Standard 트랙 유지** (3 태스크)
- **Plan 분할**: 05-01 (Chat UI + MVP), 05-02 (히스토리 목록)

## Approach
- Component-first: ChatBubble 위젯 먼저 → Page 조립
- 기존 위젯 import: AiCarInputField, AiCarButton, AiCarChip, AiCarHeader
- freezed로 ChatMessage 엔티티 생성
- go_api/ + supabase/ 듀얼 Repository 구현체
- backendTypeProvider로 스위칭

## Figma-Flutter Workflow
1. 기존 디자인 토큰 기반 설계/구현
2. Figma MCP 한계분 → 사용자가 수동으로 에셋/내부요소 전달
3. Flutter 스크린샷 vs Figma 디자인 대조 → 정확 구현
4. 공통 위젯/컴포넌트 → 디자인 시스템 추출 및 등록

## Figma Reference
- Chat Welcome: 2304-753 (375×812, 퀵 액션 버튼 포함)
- Chat Short: 2304-817 (375×812, 짧은 대화)
- Chat Full: 2304-870 (375×1188, 긴 대화 스크롤)
- Chatbot Section: 2306-1090 (UI 전체 2306-1089 하위)

## Open Questions
- ChatBubble 상세 스타일 (색상, 모서리, 패딩) → Figma 대조 시 확정
- Welcome 캐릭터 일러스트 에셋 → 사용자 수동 전달 예정
