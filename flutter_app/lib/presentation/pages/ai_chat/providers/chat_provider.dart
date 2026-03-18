enum MessageRole { user, assistant }

class ChatMessage {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final List<VehicleRecommendation>? recommendations;
  final bool isTyping;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.recommendations,
    this.isTyping = false,
  });

  ChatMessage copyWith({
    String? content,
    List<VehicleRecommendation>? recommendations,
    bool? isTyping,
  }) {
    return ChatMessage(
      id: id,
      role: role,
      content: content ?? this.content,
      timestamp: timestamp,
      recommendations: recommendations ?? this.recommendations,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class VehicleRecommendation {
  final String name;
  final String price;
  final String year;
  final String imageAsset;
  final String? specs;

  const VehicleRecommendation({
    required this.name,
    required this.price,
    required this.year,
    required this.imageAsset,
    this.specs,
  });
}
