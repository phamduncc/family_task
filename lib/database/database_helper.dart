import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';
import '../models/member.dart';
import '../models/badge_model.dart';
import '../models/reward.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('family_task.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        avatarEmoji TEXT NOT NULL,
        totalPoints INTEGER DEFAULT 0,
        streakDays INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        note TEXT,
        priority INTEGER DEFAULT 1,
        status INTEGER DEFAULT 0,
        assignedMemberIds TEXT DEFAULT '',
        dueDate TEXT,
        reminderTime TEXT,
        repeatType INTEGER DEFAULT 0,
        repeatDays TEXT DEFAULT '',
        points INTEGER DEFAULT 10,
        imagePath TEXT,
        createdAt TEXT NOT NULL,
        completedAt TEXT,
        completedByMemberId INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE badges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        emoji TEXT NOT NULL,
        condition TEXT NOT NULL,
        requiredValue INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE member_badges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        memberId INTEGER NOT NULL,
        badgeId INTEGER NOT NULL,
        earnedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE rewards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        emoji TEXT NOT NULL,
        pointCost INTEGER NOT NULL,
        isRedeemed INTEGER DEFAULT 0,
        redeemedByMemberId INTEGER,
        redeemedAt TEXT
      )
    ''');

    await _seedData(db);
  }

  Future _seedData(Database db) async {
    await db.insert('members', {
      'name': 'Bố',
      'role': 'Bố',
      'avatarEmoji': '👨',
      'totalPoints': 0,
      'streakDays': 0,
      'createdAt': DateTime.now().toIso8601String(),
    });
    await db.insert('members', {
      'name': 'Mẹ',
      'role': 'Mẹ',
      'avatarEmoji': '👩',
      'totalPoints': 0,
      'streakDays': 0,
      'createdAt': DateTime.now().toIso8601String(),
    });
    await db.insert('members', {
      'name': 'Con',
      'role': 'Con',
      'avatarEmoji': '🧒',
      'totalPoints': 0,
      'streakDays': 0,
      'createdAt': DateTime.now().toIso8601String(),
    });

    final badgesList = [
      {
        'name': 'Chăm Chỉ',
        'description': 'Hoàn thành việc 7 ngày liên tiếp',
        'emoji': '🔥',
        'condition': 'streak',
        'requiredValue': 7
      },
      {
        'name': 'Siêu Nhân Việc Nhà',
        'description': 'Hoàn thành 50 công việc',
        'emoji': '🦸',
        'condition': 'total_tasks',
        'requiredValue': 50
      },
      {
        'name': 'Khởi Đầu Tốt',
        'description': 'Hoàn thành công việc đầu tiên',
        'emoji': '⭐',
        'condition': 'total_tasks',
        'requiredValue': 1
      },
      {
        'name': 'Thành Viên Tích Cực',
        'description': 'Hoàn thành 10 công việc',
        'emoji': '🏅',
        'condition': 'total_tasks',
        'requiredValue': 10
      },
      {
        'name': 'Vô Địch Điểm Số',
        'description': 'Đạt 500 điểm',
        'emoji': '🏆',
        'condition': 'points',
        'requiredValue': 500
      },
      {
        'name': 'Nhà Vô Địch',
        'description': 'Đạt 1000 điểm',
        'emoji': '👑',
        'condition': 'points',
        'requiredValue': 1000
      },
    ];
    for (final badge in badgesList) {
      await db.insert('badges', badge);
    }

    final rewardsList = [
      {
        'name': 'Xem Phim',
        'description': 'Được chọn phim để cả nhà cùng xem',
        'emoji': '🎬',
        'pointCost': 100,
        'isRedeemed': 0
      },
      {
        'name': 'Đi Chơi',
        'description': 'Được chọn địa điểm vui chơi cuối tuần',
        'emoji': '🎡',
        'pointCost': 200,
        'isRedeemed': 0
      },
      {
        'name': 'Mua Đồ Chơi',
        'description': 'Được mua một món đồ chơi yêu thích',
        'emoji': '🎮',
        'pointCost': 300,
        'isRedeemed': 0
      },
      {
        'name': 'Ăn Ngoài',
        'description': 'Được chọn nhà hàng ăn tối',
        'emoji': '🍕',
        'pointCost': 150,
        'isRedeemed': 0
      },
      {
        'name': 'Không Làm Việc Một Ngày',
        'description': 'Được nghỉ việc nhà một ngày',
        'emoji': '🛋️',
        'pointCost': 250,
        'isRedeemed': 0
      },
    ];
    for (final reward in rewardsList) {
      await db.insert('rewards', reward);
    }

    final now = DateTime.now();
    final sampleTasks = [
      {
        'title': 'Đổ rác buổi sáng',
        'note': 'Nhớ phân loại rác trước khi đổ',
        'priority': 1,
        'status': 0,
        'assignedMemberIds': '1',
        'dueDate':
            DateTime(now.year, now.month, now.day, 7, 0).toIso8601String(),
        'repeatType': 1,
        'repeatDays': '',
        'points': 10,
        'createdAt': now.toIso8601String(),
      },
      {
        'title': 'Rửa bát sau bữa tối',
        'note': null,
        'priority': 1,
        'status': 0,
        'assignedMemberIds': '2',
        'dueDate':
            DateTime(now.year, now.month, now.day, 19, 30).toIso8601String(),
        'repeatType': 1,
        'repeatDays': '',
        'points': 10,
        'createdAt': now.toIso8601String(),
      },
      {
        'title': 'Lau nhà phòng khách',
        'note': 'Dùng nước lau sàn thơm',
        'priority': 2,
        'status': 0,
        'assignedMemberIds': '1,2',
        'dueDate': DateTime(now.year, now.month, now.day + 1).toIso8601String(),
        'repeatType': 2,
        'repeatDays': '6',
        'points': 20,
        'createdAt': now.toIso8601String(),
      },
      {
        'title': 'Đi chợ mua thực phẩm',
        'note': 'Cần mua: rau, thịt, cá, trái cây',
        'priority': 2,
        'status': 0,
        'assignedMemberIds': '2',
        'dueDate':
            DateTime(now.year, now.month, now.day, 8, 0).toIso8601String(),
        'repeatType': 0,
        'repeatDays': '',
        'points': 15,
        'createdAt': now.toIso8601String(),
      },
      {
        'title': 'Tưới cây trong vườn',
        'note': null,
        'priority': 0,
        'status': 0,
        'assignedMemberIds': '3',
        'dueDate':
            DateTime(now.year, now.month, now.day, 17, 0).toIso8601String(),
        'repeatType': 1,
        'repeatDays': '',
        'points': 5,
        'createdAt': now.toIso8601String(),
      },
    ];
    for (final task in sampleTasks) {
      await db.insert('tasks', task);
    }
  }

  // Members CRUD
  Future<List<Member>> getAllMembers() async {
    final db = await database;
    final maps = await db.query('members', orderBy: 'id ASC');
    return maps.map((m) => Member.fromMap(m)).toList();
  }

  Future<Member?> getMemberById(int id) async {
    final db = await database;
    final maps = await db.query('members', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Member.fromMap(maps.first);
  }

  Future<int> insertMember(Member member) async {
    final db = await database;
    return await db.insert('members', member.toMap());
  }

  Future<int> updateMember(Member member) async {
    final db = await database;
    return await db.update('members', member.toMap(),
        where: 'id = ?', whereArgs: [member.id]);
  }

  Future<int> deleteMember(int id) async {
    final db = await database;
    return await db.delete('members', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addPointsToMember(int memberId, int points) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE members SET totalPoints = totalPoints + ? WHERE id = ?',
      [points, memberId],
    );
  }

  // Tasks CRUD
  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final maps = await db.query('tasks', orderBy: 'dueDate ASC, priority DESC');
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  Future<List<Task>> getTasksByDate(DateTime date) async {
    final db = await database;
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final maps = await db.query(
      'tasks',
      where: "dueDate LIKE ?",
      whereArgs: ['$dateStr%'],
      orderBy: 'priority DESC',
    );
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  Future<List<Task>> getTasksByMember(int memberId) async {
    final db = await database;
    final maps = await db.query('tasks', orderBy: 'dueDate ASC');
    return maps
        .map((m) => Task.fromMap(m))
        .where((t) => t.assignedMemberIds.contains(memberId))
        .toList();
  }

  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db
        .update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> completeTask(int taskId, int memberId, int points) async {
    final db = await database;
    await addPointsToMember(memberId, points);
    return await db.update(
      'tasks',
      {
        'status': TaskStatus.completed.index,
        'completedAt': DateTime.now().toIso8601String(),
        'completedByMemberId': memberId,
      },
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  // Badges
  Future<List<TaskBadge>> getAllBadges() async {
    final db = await database;
    final maps = await db.query('badges');
    return maps.map((m) => TaskBadge.fromMap(m)).toList();
  }

  Future<List<MemberBadge>> getBadgesForMember(int memberId) async {
    final db = await database;
    final maps = await db
        .query('member_badges', where: 'memberId = ?', whereArgs: [memberId]);
    return maps.map((m) => MemberBadge.fromMap(m)).toList();
  }

  Future<int> awardBadge(int memberId, int badgeId) async {
    final db = await database;
    final existing = await db.query(
      'member_badges',
      where: 'memberId = ? AND badgeId = ?',
      whereArgs: [memberId, badgeId],
    );
    if (existing.isNotEmpty) return 0;
    return await db.insert('member_badges', {
      'memberId': memberId,
      'badgeId': badgeId,
      'earnedAt': DateTime.now().toIso8601String(),
    });
  }

  // Rewards
  Future<List<Reward>> getAllRewards() async {
    final db = await database;
    final maps = await db.query('rewards', orderBy: 'pointCost ASC');
    return maps.map((m) => Reward.fromMap(m)).toList();
  }

  Future<int> insertReward(Reward reward) async {
    final db = await database;
    return await db.insert('rewards', reward.toMap());
  }

  Future<int> redeemReward(int rewardId, int memberId) async {
    final db = await database;
    return await db.update(
      'rewards',
      {
        'isRedeemed': 1,
        'redeemedByMemberId': memberId,
        'redeemedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [rewardId],
    );
  }

  Future<int> deleteReward(int id) async {
    final db = await database;
    return await db.delete('rewards', where: 'id = ?', whereArgs: [id]);
  }

  // Statistics
  Future<Map<String, dynamic>> getMemberStats(int memberId) async {
    final db = await database;
    final allTasks = await db.query('tasks',
        where: 'completedByMemberId = ?', whereArgs: [memberId]);
    final completedTasks =
        allTasks.where((t) => t['status'] == TaskStatus.completed.index).length;
    final onTimeTasks = allTasks.where((t) {
      if (t['completedAt'] == null || t['dueDate'] == null) return false;
      final completed = DateTime.parse(t['completedAt'] as String);
      final due = DateTime.parse(t['dueDate'] as String);
      return completed.isBefore(due) || completed.isAtSameMomentAs(due);
    }).length;
    final member = await getMemberById(memberId);
    return {
      'completedTasks': completedTasks,
      'onTimeTasks': onTimeTasks,
      'onTimeRate':
          completedTasks > 0 ? (onTimeTasks / completedTasks * 100).round() : 0,
      'totalPoints': member?.totalPoints ?? 0,
      'streakDays': member?.streakDays ?? 0,
    };
  }
}
