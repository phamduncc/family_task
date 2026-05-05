class Member {
  final int? id;
  final String name;
  final String role;
  final String avatarEmoji;
  final int totalPoints;
  final int streakDays;
  final String? createdAt;

  Member({
    this.id,
    required this.name,
    required this.role,
    required this.avatarEmoji,
    this.totalPoints = 0,
    this.streakDays = 0,
    this.createdAt,
  });

  Member copyWith({
    int? id,
    String? name,
    String? role,
    String? avatarEmoji,
    int? totalPoints,
    int? streakDays,
    String? createdAt,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      totalPoints: totalPoints ?? this.totalPoints,
      streakDays: streakDays ?? this.streakDays,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'avatarEmoji': avatarEmoji,
      'totalPoints': totalPoints,
      'streakDays': streakDays,
      'createdAt': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'],
      name: map['name'],
      role: map['role'],
      avatarEmoji: map['avatarEmoji'],
      totalPoints: map['totalPoints'] ?? 0,
      streakDays: map['streakDays'] ?? 0,
      createdAt: map['createdAt'],
    );
  }
}
