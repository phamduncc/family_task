import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/member.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icon.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Thành Viên'),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add),
                onPressed: () => _showMemberForm(context, provider),
              ),
            ],
          ),
          body: provider.members.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgIcon(AppIcons.father, size: 80),
                      const SizedBox(height: 16),
                      const Text('Chưa có thành viên nào',
                          style: TextStyle(
                              fontSize: 16, color: AppTheme.textSecondary)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showMemberForm(context, provider),
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm Thành Viên'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.members.length,
                  itemBuilder: (context, index) {
                    final member = provider.members[index];
                    final memberTasks = provider.tasks
                        .where((t) => t.assignedMemberIds.contains(member.id))
                        .toList();
                    final completedCount = memberTasks
                        .where((t) => t.status == TaskStatus.completed)
                        .length;
                    final pendingCount = memberTasks
                        .where((t) => t.status != TaskStatus.completed)
                        .length;
                    final badges = provider.getBadgesForMember(member.id!);

                    return _MemberCard(
                      member: member,
                      completedCount: completedCount,
                      pendingCount: pendingCount,
                      badgeCount: badges.length,
                      onEdit: () =>
                          _showMemberForm(context, provider, member: member),
                      onDelete: () => _confirmDelete(context, provider, member),
                      onTap: () => _showMemberDetail(context, provider, member),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showMemberForm(context, provider),
            child: const Icon(Icons.person_add),
          ),
        );
      },
    );
  }

  void _showMemberForm(BuildContext context, AppProvider provider,
      {Member? member}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _MemberForm(member: member, provider: provider),
    );
  }

  void _confirmDelete(
      BuildContext context, AppProvider provider, Member member) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa thành viên?'),
        content: Text(
            'Bạn muốn xóa "${member.name}"?\nCác công việc đã giao sẽ không bị xóa.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              provider.deleteMember(member.id!);
              Navigator.pop(context);
            },
            child: const Text('Xóa',
                style: TextStyle(color: AppTheme.dangerColor)),
          ),
        ],
      ),
    );
  }

  void _showMemberDetail(
      BuildContext context, AppProvider provider, Member member) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MemberDetailScreen(member: member)),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final Member member;
  final int completedCount;
  final int pendingCount;
  final int badgeCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _MemberCard({
    required this.member,
    required this.completedCount,
    required this.pendingCount,
    required this.badgeCount,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgIcon.fromKey(member.avatarEmoji, size: 56),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member.name,
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold)),
                        Text(member.role,
                            style: const TextStyle(
                                fontSize: 13, color: AppTheme.textSecondary)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            SvgIcon(AppIcons.star,
                                size: 14, color: AppTheme.warningColor),
                            Text(' ${member.totalPoints} điểm',
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                            if (member.streakDays > 0) ...[
                              const SizedBox(width: 10),
                              const Icon(Icons.local_fire_department,
                                  size: 14, color: AppTheme.dangerColor),
                              Text(' ${member.streakDays} ngày',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.dangerColor)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') onEdit();
                      if (v == 'delete') onDelete();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                          value: 'edit',
                          child: Row(children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Chỉnh sửa')
                          ])),
                      const PopupMenuItem(
                          value: 'delete',
                          child: Row(children: [
                            Icon(Icons.delete,
                                size: 18, color: AppTheme.dangerColor),
                            SizedBox(width: 8),
                            Text('Xóa',
                                style: TextStyle(color: AppTheme.dangerColor))
                          ])),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatBadge(
                      label: 'Đã xong',
                      value: '$completedCount',
                      color: AppTheme.successColor),
                  const SizedBox(width: 8),
                  _StatBadge(
                      label: 'Chờ làm',
                      value: '$pendingCount',
                      color: AppTheme.accentColor),
                  const SizedBox(width: 8),
                  _StatBadge(
                      label: 'Huy hiệu',
                      value: '$badgeCount',
                      color: AppTheme.warningColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatBadge(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _MemberForm extends StatefulWidget {
  final Member? member;
  final AppProvider provider;
  const _MemberForm({this.member, required this.provider});

  @override
  State<_MemberForm> createState() => _MemberFormState();
}

class _MemberFormState extends State<_MemberForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _roleController;
  String _selectedEmoji = 'father';

  final List<String> _avatarKeys = AppIcons.memberAvatarKeys;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member?.name ?? '');
    _roleController = TextEditingController(text: widget.member?.role ?? '');
    _selectedEmoji = widget.member?.avatarEmoji ?? 'father';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.member == null
                  ? 'Thêm Thành Viên'
                  : 'Chỉnh Sửa Thành Viên',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Chọn Avatar:',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _avatarKeys.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final key = _avatarKeys[i];
                  final isSelected = _selectedEmoji == key;
                  final label = AppIcons.memberAvatarLabels[key] ?? key;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedEmoji = key),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppTheme.primaryColor.withOpacity(0.15)
                                : Colors.grey.withOpacity(0.1),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: SvgIcon.fromKey(key),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Tên thành viên',
                prefixIcon: const Icon(Icons.person),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Vui lòng nhập tên' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _roleController,
              decoration: InputDecoration(
                labelText: 'Vai trò (Bố, Mẹ, Con...)',
                prefixIcon: const Icon(Icons.family_restroom),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Vui lòng nhập vai trò'
                  : null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final m = Member(
                    id: widget.member?.id,
                    name: _nameController.text.trim(),
                    role: _roleController.text.trim(),
                    avatarEmoji: _selectedEmoji,
                    totalPoints: widget.member?.totalPoints ?? 0,
                    streakDays: widget.member?.streakDays ?? 0,
                  );
                  if (widget.member == null) {
                    await widget.provider.addMember(m);
                  } else {
                    await widget.provider.updateMember(m);
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(
                    widget.member == null ? 'Thêm Thành Viên' : 'Lưu Thay Đổi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MemberDetailScreen extends StatelessWidget {
  final Member member;
  const MemberDetailScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final memberTasks = provider.tasks
            .where((t) => t.assignedMemberIds.contains(member.id))
            .toList();
        final completed =
            memberTasks.where((t) => t.status == TaskStatus.completed).toList();
        final pending =
            memberTasks.where((t) => t.status != TaskStatus.completed).toList();
        final memberBadges = provider.getBadgesForMember(member.id!);

        return Scaffold(
          appBar: AppBar(
              title: Row(children: [
            SvgIcon.fromKey(member.avatarEmoji, size: 32),
            const SizedBox(width: 10),
            Text(member.name),
          ])),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ProfileHeader(member: member),
              const SizedBox(height: 20),
              _StatsRow(
                  completedCount: completed.length,
                  pendingCount: pending.length,
                  points: member.totalPoints),
              const SizedBox(height: 20),
              if (memberBadges.isNotEmpty) ...[
                Row(children: [
                  SvgIcon(AppIcons.medal, size: 18),
                  const SizedBox(width: 6),
                  const Text('Huy Hiệu Đạt Được',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 10),
                _BadgesRow(memberBadges: memberBadges, provider: provider),
                const SizedBox(height: 20),
              ],
              Row(children: [
                SvgIcon(AppIcons.task, size: 18),
                const SizedBox(width: 6),
                const Text('Công Việc Đang Chờ',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 10),
              if (pending.isEmpty)
                const Center(
                    child: Text('Không có việc chờ!',
                        style: TextStyle(color: AppTheme.textSecondary)))
              else
                ...pending.take(5).map((t) => _SimpleTaskTile(task: t)),
              const SizedBox(height: 20),
              Row(children: [
                SvgIcon(AppIcons.check, size: 18),
                const SizedBox(width: 6),
                const Text('Đã Hoàn Thành',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 10),
              if (completed.isEmpty)
                const Center(
                    child: Text('Chưa hoàn thành việc nào',
                        style: TextStyle(color: AppTheme.textSecondary)))
              else
                ...completed
                    .take(5)
                    .map((t) => _SimpleTaskTile(task: t, isDone: true)),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final Member member;
  const _ProfileHeader({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SvgIcon.fromKey(member.avatarEmoji, size: 72),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(member.name,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Text(member.role,
                  style: const TextStyle(fontSize: 14, color: Colors.white70)),
              const SizedBox(height: 8),
              Row(children: [
                SvgIcon(AppIcons.star, size: 16, color: AppTheme.warningColor),
                Text(' ${member.totalPoints} điểm',
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ]),
              if (member.streakDays > 0)
                Row(children: [
                  const Icon(Icons.local_fire_department,
                      size: 14, color: Colors.white70),
                  Text(' ${member.streakDays} ngày liên tiếp',
                      style:
                          const TextStyle(fontSize: 13, color: Colors.white70)),
                ]),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int completedCount;
  final int pendingCount;
  final int points;
  const _StatsRow(
      {required this.completedCount,
      required this.pendingCount,
      required this.points});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatItem(
            icon:
                SvgIcon(AppIcons.check, size: 22, color: AppTheme.successColor),
            label: 'Đã xong',
            value: '$completedCount'),
        _StatItem(
            icon: SvgIcon(AppIcons.hourglass,
                size: 22, color: AppTheme.accentColor),
            label: 'Chờ làm',
            value: '$pendingCount'),
        _StatItem(
            icon:
                SvgIcon(AppIcons.star, size: 22, color: AppTheme.warningColor),
            label: 'Điểm',
            value: '$points'),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final String value;
  const _StatItem(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)
          ],
        ),
        child: Column(
          children: [
            icon,
            const SizedBox(height: 4),
            Text(value,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _BadgesRow extends StatelessWidget {
  final List memberBadges;
  final AppProvider provider;
  const _BadgesRow({required this.memberBadges, required this.provider});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: memberBadges.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final mb = memberBadges[i];
          final badge =
              provider.badges.where((b) => b.id == mb.badgeId).firstOrNull;
          if (badge == null) return const SizedBox.shrink();
          return Container(
            width: 70,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.warningColor.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgIcon.auto(badge.emoji, size: 24),
                Text(badge.name,
                    style: const TextStyle(
                        fontSize: 9, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    maxLines: 2),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SimpleTaskTile extends StatelessWidget {
  final dynamic task;
  final bool isDone;
  const _SimpleTaskTile({required this.task, this.isDone = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)
        ],
      ),
      child: Row(
        children: [
          Icon(isDone ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isDone ? AppTheme.successColor : AppTheme.textSecondary,
              size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                decoration: isDone ? TextDecoration.lineThrough : null,
                color: isDone ? AppTheme.textSecondary : null,
              ),
            ),
          ),
          Row(mainAxisSize: MainAxisSize.min, children: [
            SvgIcon(AppIcons.star, size: 11, color: AppTheme.warningColor),
            Text('${task.points}',
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.warningColor)),
          ]),
        ],
      ),
    );
  }
}
