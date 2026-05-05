class TaskBadge {
  final int? id;
  final String name;
  final String description;
  final String emoji;
  final String condition;
  final int requiredValue;

  TaskBadge({
    this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.condition,
    required this.requiredValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'emoji': emoji,
      'condition': condition,
      'requiredValue': requiredValue,
    };
  }

  factory TaskBadge.fromMap(Map<String, dynamic> map) {
    return TaskBadge(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      emoji: map['emoji'],
      condition: map['condition'],
      requiredValue: map['requiredValue'],
    );
  }
}

class MemberBadge {
  final int? id;
  final int memberId;
  final int badgeId;
  final String earnedAt;

  MemberBadge({
    this.id,
    required this.memberId,
    required this.badgeId,
    required this.earnedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'badgeId': badgeId,
      'earnedAt': earnedAt,
    };
  }

  factory MemberBadge.fromMap(Map<String, dynamic> map) {
    return MemberBadge(
      id: map['id'],
      memberId: map['memberId'],
      badgeId: map['badgeId'],
      earnedAt: map['earnedAt'],
    );
  }
}
