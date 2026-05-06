import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/member.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'app_icon.dart';
import '../screens/task_form_screen.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onChanged;

  const TaskCard({super.key, required this.task, this.onChanged});

  Color get _priorityColor {
    switch (task.priority) {
      case TaskPriority.low:
        return AppTheme.priorityLow;
      case TaskPriority.medium:
        return AppTheme.priorityMedium;
      case TaskPriority.high:
        return AppTheme.priorityHigh;
    }
  }

  String get _priorityLabel {
    switch (task.priority) {
      case TaskPriority.low:
        return 'Thấp';
      case TaskPriority.medium:
        return 'TB';
      case TaskPriority.high:
        return 'Cao';
    }
  }

  String get _repeatLabel {
    switch (task.repeatType) {
      case RepeatType.daily:
        return 'Hàng ngày';
      case RepeatType.weekly:
        return 'Hàng tuần';
      case RepeatType.monthly:
        return 'Hàng tháng';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final isDone = task.status == TaskStatus.completed;
    final isOverdue = task.isOverdue;

    return Dismissible(
      key: Key('task_${task.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.dangerColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Xóa công việc?'),
            content: Text('Bạn muốn xóa "${task.title}"?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Hủy')),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Xóa',
                    style: TextStyle(color: AppTheme.dangerColor)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        provider.deleteTask(task.id!);
        onChanged?.call();
      },
      child: GestureDetector(
        onTap: () => Navigator.of(context)
            .push(
              MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
            )
            .then((_) => onChanged?.call()),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isOverdue && !isDone
                  ? AppTheme.dangerColor.withOpacity(0.4)
                  : isDone
                      ? AppTheme.successColor.withOpacity(0.3)
                      : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _CompleteButton(task: task, onChanged: onChanged),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                decoration:
                                    isDone ? TextDecoration.lineThrough : null,
                                color: isDone ? AppTheme.textSecondary : null,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _priorityColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _priorityLabel,
                              style: TextStyle(
                                fontSize: 11,
                                color: _priorityColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (task.note != null && task.note!.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          task.note!,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (task.dueDate != null)
                            _InfoChip(
                              icon: Icons.access_time,
                              label: _formatDueDate(task.dueDate!),
                              color: isOverdue && !isDone
                                  ? AppTheme.dangerColor
                                  : AppTheme.textSecondary,
                            ),
                          if (_repeatLabel.isNotEmpty)
                            _InfoChip(
                              label: _repeatLabel,
                              color: AppTheme.accentColor,
                              icon: Icons.repeat,
                            ),
                          ..._buildAssigneeChips(context, provider),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  SvgIcon(AppIcons.star,
                      size: 12, color: AppTheme.warningColor),
                  Text('${task.points}',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.warningColor)),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAssigneeChips(BuildContext context, AppProvider provider) {
    return task.assignedMemberIds.take(2).map((id) {
      final member = provider.getMemberById(id);
      if (member == null) return const SizedBox.shrink();
      return _MemberChip(member: member);
    }).toList();
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _CompleteButton extends StatelessWidget {
  final Task task;
  final VoidCallback? onChanged;

  const _CompleteButton({required this.task, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final isDone = task.status == TaskStatus.completed;

    return GestureDetector(
      onTap: () async {
        if (isDone) return;
        final members = provider.members;
        if (members.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chưa có thành viên nào!')),
          );
          return;
        }

        Member? selected;
        if (task.assignedMemberIds.length == 1) {
          selected = provider.getMemberById(task.assignedMemberIds.first);
        }

        if (selected == null) {
          selected = await showDialog<Member>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Ai hoàn thành?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: members
                    .map((m) => ListTile(
                          leading:
                              MemberAvatar(avatarKey: m.avatarEmoji, size: 32),
                          title: Text(m.name),
                          onTap: () => Navigator.pop(context, m),
                        ))
                    .toList(),
              ),
            ),
          );
        }

        if (selected != null) {
          await provider.completeTask(task.id!, selected.id!);
          onChanged?.call();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '${selected.name} hoàn thành "${task.title}" +${task.points} điểm'),
                backgroundColor: AppTheme.successColor,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDone ? AppTheme.successColor : Colors.transparent,
          border: Border.all(
            color: isDone
                ? AppTheme.successColor
                : AppTheme.textSecondary.withOpacity(0.4),
            width: 2,
          ),
        ),
        child: isDone
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : null,
      ),
    );
  }
}

class _MemberChip extends StatelessWidget {
  final Member member;
  const _MemberChip({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MemberAvatar(
              avatarKey: member.avatarEmoji,
              size: 14,
              backgroundColor: Colors.transparent),
          const SizedBox(width: 3),
          Text(member.name,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.accentColor,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _InfoChip({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
          ],
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
