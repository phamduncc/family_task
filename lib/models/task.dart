enum TaskPriority { low, medium, high }

enum TaskStatus { pending, inProgress, completed }

enum RepeatType { none, daily, weekly, monthly, custom }

class Task {
  final int? id;
  final String title;
  final String? note;
  final TaskPriority priority;
  TaskStatus status;
  final List<int> assignedMemberIds;
  final DateTime? dueDate;
  final String? reminderTime;
  final RepeatType repeatType;
  final List<int> repeatDays;
  final int points;
  final String? imagePath;
  final String? createdAt;
  final String? completedAt;
  final int? completedByMemberId;

  Task({
    this.id,
    required this.title,
    this.note,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    this.assignedMemberIds = const [],
    this.dueDate,
    this.reminderTime,
    this.repeatType = RepeatType.none,
    this.repeatDays = const [],
    this.points = 10,
    this.imagePath,
    this.createdAt,
    this.completedAt,
    this.completedByMemberId,
  });

  Task copyWith({
    int? id,
    String? title,
    String? note,
    TaskPriority? priority,
    TaskStatus? status,
    List<int>? assignedMemberIds,
    DateTime? dueDate,
    String? reminderTime,
    RepeatType? repeatType,
    List<int>? repeatDays,
    int? points,
    String? imagePath,
    String? createdAt,
    String? completedAt,
    int? completedByMemberId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedMemberIds: assignedMemberIds ?? this.assignedMemberIds,
      dueDate: dueDate ?? this.dueDate,
      reminderTime: reminderTime ?? this.reminderTime,
      repeatType: repeatType ?? this.repeatType,
      repeatDays: repeatDays ?? this.repeatDays,
      points: points ?? this.points,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      completedByMemberId: completedByMemberId ?? this.completedByMemberId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'priority': priority.index,
      'status': status.index,
      'assignedMemberIds': assignedMemberIds.join(','),
      'dueDate': dueDate?.toIso8601String(),
      'reminderTime': reminderTime,
      'repeatType': repeatType.index,
      'repeatDays': repeatDays.join(','),
      'points': points,
      'imagePath': imagePath,
      'createdAt': createdAt ?? DateTime.now().toIso8601String(),
      'completedAt': completedAt,
      'completedByMemberId': completedByMemberId,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      note: map['note'],
      priority: TaskPriority.values[map['priority'] ?? 1],
      status: TaskStatus.values[map['status'] ?? 0],
      assignedMemberIds: map['assignedMemberIds'] != null && map['assignedMemberIds'].toString().isNotEmpty
          ? map['assignedMemberIds'].toString().split(',').map((e) => int.parse(e)).toList()
          : [],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      reminderTime: map['reminderTime'],
      repeatType: RepeatType.values[map['repeatType'] ?? 0],
      repeatDays: map['repeatDays'] != null && map['repeatDays'].toString().isNotEmpty
          ? map['repeatDays'].toString().split(',').map((e) => int.parse(e)).toList()
          : [],
      points: map['points'] ?? 10,
      imagePath: map['imagePath'],
      createdAt: map['createdAt'],
      completedAt: map['completedAt'],
      completedByMemberId: map['completedByMemberId'],
    );
  }

  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.completed) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year && dueDate!.month == now.month && dueDate!.day == now.day;
  }
}
