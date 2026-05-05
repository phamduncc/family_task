class Reward {
  final int? id;
  final String name;
  final String description;
  final String emoji;
  final int pointCost;
  bool isRedeemed;
  final int? redeemedByMemberId;
  final String? redeemedAt;

  Reward({
    this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.pointCost,
    this.isRedeemed = false,
    this.redeemedByMemberId,
    this.redeemedAt,
  });

  Reward copyWith({
    int? id,
    String? name,
    String? description,
    String? emoji,
    int? pointCost,
    bool? isRedeemed,
    int? redeemedByMemberId,
    String? redeemedAt,
  }) {
    return Reward(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      pointCost: pointCost ?? this.pointCost,
      isRedeemed: isRedeemed ?? this.isRedeemed,
      redeemedByMemberId: redeemedByMemberId ?? this.redeemedByMemberId,
      redeemedAt: redeemedAt ?? this.redeemedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'emoji': emoji,
      'pointCost': pointCost,
      'isRedeemed': isRedeemed ? 1 : 0,
      'redeemedByMemberId': redeemedByMemberId,
      'redeemedAt': redeemedAt,
    };
  }

  factory Reward.fromMap(Map<String, dynamic> map) {
    return Reward(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      emoji: map['emoji'],
      pointCost: map['pointCost'],
      isRedeemed: (map['isRedeemed'] ?? 0) == 1,
      redeemedByMemberId: map['redeemedByMemberId'],
      redeemedAt: map['redeemedAt'],
    );
  }
}
