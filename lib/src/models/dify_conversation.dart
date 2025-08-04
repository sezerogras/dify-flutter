class DifyConversation {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> messageIds;
  final Map<String, dynamic>? metadata;
  final String? userId;

  const DifyConversation({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.messageIds = const [],
    this.metadata,
    this.userId,
  });

  factory DifyConversation.fromJson(Map<String, dynamic> json) {
    return DifyConversation(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      messageIds: List<String>.from(json['message_ids'] ?? []),
      metadata: json['metadata'] as Map<String, dynamic>?,
      userId: json['user_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'message_ids': messageIds,
      'metadata': metadata,
      'user_id': userId,
    };
  }

  DifyConversation copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? messageIds,
    Map<String, dynamic>? metadata,
    String? userId,
  }) {
    return DifyConversation(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messageIds: messageIds ?? this.messageIds,
      metadata: metadata ?? this.metadata,
      userId: userId ?? this.userId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DifyConversation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 