class DifyUser {
  final String id;
  final String? name;
  final String? email;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DifyUser({
    required this.id,
    this.name,
    this.email,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DifyUser.fromJson(Map<String, dynamic> json) {
    return DifyUser(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  DifyUser copyWith({
    String? id,
    String? name,
    String? email,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DifyUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DifyUser && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 