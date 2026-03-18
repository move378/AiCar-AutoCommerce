import 'package:aicar/constants/assets.dart';
import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/presentation/pages/ai_chat/providers/chat_provider.dart';
import 'package:aicar/presentation/pages/ai_chat/widgets/chat_bubble.dart';
import 'package:aicar/presentation/pages/ai_chat/widgets/message_input.dart';
import 'package:aicar/presentation/pages/ai_chat/widgets/quick_action_bar.dart';
import 'package:flutter/material.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _showQuickActions = true;
  int _messageIdCounter = 0;

  @override
  void initState() {
    super.initState();
    // Add initial AI welcome message
    _messages.add(ChatMessage(
      id: _nextId(),
      role: MessageRole.assistant,
      content: '안녕하세요! 어떤 차량을 찾고 계신가요? 😊',
      timestamp: DateTime.now(),
    ));
  }

  String _nextId() => 'msg_${_messageIdCounter++}';

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSendMessage(String text) {
    // Add user message
    setState(() {
      _messages.insert(
        0,
        ChatMessage(
          id: _nextId(),
          role: MessageRole.user,
          content: text,
          timestamp: DateTime.now(),
        ),
      );
      _showQuickActions = false;
    });
    _scrollToBottom();

    // Show typing indicator
    final typingId = _nextId();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            id: typingId,
            role: MessageRole.assistant,
            content: '',
            timestamp: DateTime.now(),
            isTyping: true,
          ),
        );
      });
      _scrollToBottom();
    });

    // First AI response
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        final typingIndex =
            _messages.indexWhere((m) => m.id == typingId);
        if (typingIndex != -1) {
          _messages[typingIndex] = ChatMessage(
            id: typingId,
            role: MessageRole.assistant,
            content: '좋은 선택이에요! 조건에 맞는 차량을 찾아볼게요.',
            timestamp: DateTime.now(),
          );
        }
      });
      _scrollToBottom();

      // Show typing for recommendation
      final recTypingId = _nextId();
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          _messages.insert(
            0,
            ChatMessage(
              id: recTypingId,
              role: MessageRole.assistant,
              content: '',
              timestamp: DateTime.now(),
              isTyping: true,
            ),
          );
        });
        _scrollToBottom();
      });

      // Vehicle recommendation response
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (!mounted) return;
        setState(() {
          final recTypingIndex =
              _messages.indexWhere((m) => m.id == recTypingId);
          if (recTypingIndex != -1) {
            _messages[recTypingIndex] = ChatMessage(
              id: recTypingId,
              role: MessageRole.assistant,
              content: '조건에 맞는 차량을 찾았어요! 아래 추천 차량을 확인해보세요.',
              timestamp: DateTime.now(),
              recommendations: const [
                VehicleRecommendation(
                  name: 'BMW X3',
                  price: '4,850만원~',
                  year: '2024년형',
                  imageAsset: Assets.rectangle43568,
                  specs: 'xDrive 20i',
                ),
                VehicleRecommendation(
                  name: 'Mercedes-Benz GLC',
                  price: '4,950만원~',
                  year: '2024년형',
                  imageAsset: Assets.rectangle43569,
                  specs: 'GLC 200',
                ),
                VehicleRecommendation(
                  name: 'Volvo XC60',
                  price: '4,490만원~',
                  year: '2024년형',
                  imageAsset: Assets.rectangle43570,
                  specs: 'B5 AWD',
                ),
              ],
            );
          }
        });
        _scrollToBottom();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'AiCar',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.surface,
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(
                  message: message,
                  showStreaming: index == 0 &&
                      message.role == MessageRole.assistant &&
                      !message.isTyping,
                );
              },
            ),
          ),

          // Quick action bar (visible only at start)
          if (_showQuickActions)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: QuickActionBar(
                onTap: _handleSendMessage,
              ),
            ),

          // Message input
          MessageInput(onSubmitted: _handleSendMessage),
        ],
      ),
    );
  }
}
