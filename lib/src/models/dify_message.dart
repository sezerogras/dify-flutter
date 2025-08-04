enum MessageRole { user, assistant, system }

enum MessageStatus { sending, sent, error, received }

class DifyMessage {
  final String id;
  final String content;
  final MessageRole role;
  final MessageStatus status;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final String? conversationId;
  final String? userId;

  const DifyMessage({
    required this.id,
    required this.content,
    required this.role,
    this.status = MessageStatus.sent,
    required this.timestamp,
    this.metadata,
    this.conversationId,
    this.userId,
  });

  factory DifyMessage.fromJson(Map<String, dynamic> json) {
    return DifyMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      role: MessageRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => MessageRole.user,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      conversationId: json['conversation_id'] as String?,
      userId: json['user_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role.toString().split('.').last,
      'status': status.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'conversation_id': conversationId,
      'user_id': userId,
    };
  }

  DifyMessage copyWith({
    String? id,
    String? content,
    MessageRole? role,
    MessageStatus? status,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    String? conversationId,
    String? userId,
  }) {
    return DifyMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      conversationId: conversationId ?? this.conversationId,
      userId: userId ?? this.userId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DifyMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 