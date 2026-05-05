import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import '../models/member.dart';
import '../models/badge_model.dart';
import '../models/reward.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Task> _tasks = [];
  List<Member> _members = [];
  List<TaskBadge> _badges = [];
  List<Reward> _rewards = [];
  Map<int, List<MemberBadge>> _memberBadges = {};
  bool _isLoading = false;
  int? _selectedMemberFilter;
  TaskStatus? _statusFilter;
  bool _isDarkMode = false;

  List<Task> get tasks => _tasks;
  List<Member> get members => _members;
  List<TaskBadge> get badges => _badges;
  List<Reward> get rewards => _rewards;
  bool get isLoading => _isLoading;
  int? get selectedMemberFilter => _selectedMemberFilter;
  TaskStatus? get statusFilter => _statusFilter;
  bool get isDarkMode => _isDarkMode;

  List<Task> get filteredTasks {
    var result = List<Task>.from(_tasks);
    if (_selectedMemberFilter != null) {
      result = result
          .where((t) => t.assignedMemberIds.contains(_selectedMemberFilter))
          .toList();
    }
    if (_statusFilter != null) {
      result = result.where((t) => t.status == _statusFilter).toList();
    }
    return result;
  }

  List<Task> get todayTasks {
    final now = DateTime.now();
    return _tasks.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.year == now.year &&
          t.dueDate!.month == now.month &&
          t.dueDate!.day == now.day;
    }).toList();
  }

  List<Task> get pendingTasks =>
      _tasks.where((t) => t.status != TaskStatus.completed).toList();
  List<Task> get completedTasks =>
      _tasks.where((t) => t.status == TaskStatus.completed).toList();
  List<Task> get overdueTasks => _tasks.where((t) => t.isOverdue).toList();

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    _tasks = await _db.getAllTasks();
    _members = await _db.getAllMembers();
    _badges = await _db.getAllBadges();
    _rewards = await _db.getAllRewards();
    for (final m in _members) {
      _memberBadges[m.id!] = await _db.getBadgesForMember(m.id!);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadTasks() async {
    _tasks = await _db.getAllTasks();
    notifyListeners();
  }

  Future<void> loadMembers() async {
    _members = await _db.getAllMembers();
    for (final m in _members) {
      _memberBadges[m.id!] = await _db.getBadgesForMember(m.id!);
    }
    notifyListeners();
  }

  Future<void> loadRewards() async {
    _rewards = await _db.getAllRewards();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    final id = await _db.insertTask(task);
    final newTask = task.copyWith(id: id);
    _tasks.add(newTask);
    _tasks.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await _db.updateTask(task);
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) _tasks[idx] = task;
    notifyListeners();
  }

  Future<void> deleteTask(int id) async {
    await _db.deleteTask(id);
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<void> completeTask(int taskId, int memberId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    await _db.completeTask(taskId, memberId, task.points);
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _tasks[idx] = task.copyWith(
        status: TaskStatus.completed,
        completedAt: DateTime.now().toIso8601String(),
        completedByMemberId: memberId,
      );
    }
    final mIdx = _members.indexWhere((m) => m.id == memberId);
    if (mIdx != -1) {
      _members[mIdx] = _members[mIdx].copyWith(
        totalPoints: _members[mIdx].totalPoints + task.points,
      );
    }
    await _checkAndAwardBadges(memberId);

    if (task.repeatType != RepeatType.none) {
      await _createNextRepeatTask(task);
    }
    notifyListeners();
  }

  Future<void> _createNextRepeatTask(Task completedTask) async {
    DateTime? nextDue;
    if (completedTask.dueDate != null) {
      switch (completedTask.repeatType) {
        case RepeatType.daily:
          nextDue = completedTask.dueDate!.add(const Duration(days: 1));
          break;
        case RepeatType.weekly:
          nextDue = completedTask.dueDate!.add(const Duration(days: 7));
          break;
        case RepeatType.monthly:
          nextDue = DateTime(
            completedTask.dueDate!.year,
            completedTask.dueDate!.month + 1,
            completedTask.dueDate!.day,
            completedTask.dueDate!.hour,
            completedTask.dueDate!.minute,
          );
          break;
        default:
          return;
      }
    }
    final newTask = Task(
      id: null,
      title: completedTask.title,
      note: completedTask.note,
      priority: completedTask.priority,
      status: TaskStatus.pending,
      assignedMemberIds: completedTask.assignedMemberIds,
      dueDate: nextDue,
      reminderTime: completedTask.reminderTime,
      repeatType: completedTask.repeatType,
      repeatDays: completedTask.repeatDays,
      points: completedTask.points,
      imagePath: completedTask.imagePath,
      createdAt: DateTime.now().toIso8601String(),
      completedAt: null,
      completedByMemberId: null,
    );
    await addTask(newTask);
  }

  Future<void> _checkAndAwardBadges(int memberId) async {
    final member = _members.firstWhere((m) => m.id == memberId);
    final completedByMember = _tasks
        .where((t) =>
            t.status == TaskStatus.completed &&
            t.completedByMemberId == memberId)
        .length;

    for (final badge in _badges) {
      bool earned = false;
      switch (badge.condition) {
        case 'total_tasks':
          earned = completedByMember >= badge.requiredValue;
          break;
        case 'points':
          earned = member.totalPoints >= badge.requiredValue;
          break;
        case 'streak':
          earned = member.streakDays >= badge.requiredValue;
          break;
      }
      if (earned) {
        await _db.awardBadge(memberId, badge.id!);
      }
    }
    _memberBadges[memberId] = await _db.getBadgesForMember(memberId);
  }

  Future<void> addMember(Member member) async {
    final id = await _db.insertMember(member);
    _members.add(member.copyWith(id: id));
    _memberBadges[id] = [];
    notifyListeners();
  }

  Future<void> updateMember(Member member) async {
    await _db.updateMember(member);
    final idx = _members.indexWhere((m) => m.id == member.id);
    if (idx != -1) _members[idx] = member;
    notifyListeners();
  }

  Future<void> deleteMember(int id) async {
    await _db.deleteMember(id);
    _members.removeWhere((m) => m.id == id);
    _memberBadges.remove(id);
    notifyListeners();
  }

  Future<void> redeemReward(int rewardId, int memberId) async {
    final reward = _rewards.firstWhere((r) => r.id == rewardId);
    final member = _members.firstWhere((m) => m.id == memberId);
    if (member.totalPoints < reward.pointCost) return;
    await _db.redeemReward(rewardId, memberId);
    await _db.addPointsToMember(memberId, -reward.pointCost);
    final rIdx = _rewards.indexWhere((r) => r.id == rewardId);
    if (rIdx != -1) {
      _rewards[rIdx] = reward.copyWith(
        isRedeemed: true,
        redeemedByMemberId: memberId,
        redeemedAt: DateTime.now().toIso8601String(),
      );
    }
    final mIdx = _members.indexWhere((m) => m.id == memberId);
    if (mIdx != -1) {
      _members[mIdx] = _members[mIdx].copyWith(
        totalPoints: _members[mIdx].totalPoints - reward.pointCost,
      );
    }
    notifyListeners();
  }

  Future<void> addReward(Reward reward) async {
    final id = await _db.insertReward(reward);
    _rewards.add(reward.copyWith(id: id));
    notifyListeners();
  }

  Future<void> deleteReward(int id) async {
    await _db.deleteReward(id);
    _rewards.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  List<MemberBadge> getBadgesForMember(int memberId) {
    return _memberBadges[memberId] ?? [];
  }

  Future<Map<String, dynamic>> getMemberStats(int memberId) async {
    return await _db.getMemberStats(memberId);
  }

  List<Task> getTasksForDate(DateTime date) {
    return _tasks.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.year == date.year &&
          t.dueDate!.month == date.month &&
          t.dueDate!.day == date.day;
    }).toList();
  }

  void setMemberFilter(int? memberId) {
    _selectedMemberFilter = memberId;
    notifyListeners();
  }

  void setStatusFilter(TaskStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  Member? getMemberById(int id) {
    try {
      return _members.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}
