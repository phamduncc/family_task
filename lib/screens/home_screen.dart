import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../widgets/task_card.dart';
import '../widgets/app_icon.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final now = DateTime.now();
        final todayTasks = provider.todayTasks;
        final pendingCount = provider.pendingTasks.length;
        final overdueCount = provider.overdueTasks.length;
        final completedToday =
            todayTasks.where((t) => t.status == TaskStatus.completed).length;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 160,
                floating: false,
                pinned: true,
                backgroundColor: AppTheme.primaryColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        SvgIcon(AppIcons.home,
                                            size: 22, color: Colors.white),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Family Task',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      DateFormat('EEEE, d MMMM yyyy', 'vi_VN')
                                          .format(now),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                Consumer<AppProvider>(
                                  builder: (context, p, _) => IconButton(
                                    icon: Icon(
                                      p.isDarkMode
                                          ? Icons.light_mode
                                          : Icons.dark_mode,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => p.toggleDarkMode(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Hôm nay: $completedToday / ${todayTasks.length} việc hoàn thành',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatCards(
                        pendingCount: pendingCount,
                        completedToday: completedToday,
                        overdueCount: overdueCount,
                        totalToday: todayTasks.length,
                      ),
                      const SizedBox(height: 20),
                      if (overdueCount > 0) ...[
                        _SectionHeader(
                          title: 'Quá Hạn ($overdueCount)',
                          color: AppTheme.dangerColor,
                          icon: const Icon(Icons.warning_amber_rounded,
                              size: 18, color: AppTheme.dangerColor),
                        ),
                        const SizedBox(height: 8),
                        ...provider.overdueTasks.take(3).map(
                              (task) => TaskCard(
                                  task: task,
                                  onChanged: () => provider.loadTasks()),
                            ),
                        const SizedBox(height: 16),
                      ],
                      _SectionHeader(
                        title: 'Hôm Nay (${todayTasks.length})',
                        color: AppTheme.primaryColor,
                        icon: SvgIcon(AppIcons.calendar,
                            size: 18, color: AppTheme.primaryColor),
                        action: TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const TaskFormScreen()),
                          ),
                          child: const Text('+ Thêm'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (todayTasks.isEmpty)
                        _EmptyState(
                            message:
                                'Không có việc nào hôm nay!\nThư giãn thôi!')
                      else
                        ...todayTasks.map(
                          (task) => TaskCard(
                              task: task,
                              onChanged: () => provider.loadTasks()),
                        ),
                      const SizedBox(height: 16),
                      _SectionHeader(
                        title: 'Thành Viên',
                        color: AppTheme.accentColor,
                        icon: SvgIcon(AppIcons.father,
                            size: 18, color: AppTheme.accentColor),
                      ),
                      const SizedBox(height: 8),
                      _MemberQuickView(provider: provider),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TaskFormScreen()),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Thêm Việc'),
          ),
        );
      },
    );
  }
}

class _StatCards extends StatelessWidget {
  final int pendingCount;
  final int completedToday;
  final int overdueCount;
  final int totalToday;

  const _StatCards({
    required this.pendingCount,
    required this.completedToday,
    required this.overdueCount,
    required this.totalToday,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: SvgIcon(AppIcons.task, size: 22, color: AppTheme.accentColor),
            label: 'Chờ làm',
            value: '$pendingCount',
            color: AppTheme.accentColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon:
                SvgIcon(AppIcons.check, size: 22, color: AppTheme.successColor),
            label: 'Hôm nay xong',
            value: '$completedToday/$totalToday',
            color: AppTheme.successColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icon(Icons.running_with_errors_rounded,
                size: 22,
                color: overdueCount > 0
                    ? AppTheme.dangerColor
                    : AppTheme.textSecondary),
            label: 'Quá hạn',
            value: '$overdueCount',
            color: overdueCount > 0
                ? AppTheme.dangerColor
                : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final Widget icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D44) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          icon,
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  final Widget? action;
  final Widget? icon;

  const _SectionHeader(
      {required this.title, required this.color, this.action, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (icon != null) ...[icon!, const SizedBox(width: 6)],
        Text(
          title,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
        const Spacer(),
        if (action != null) action!,
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.successColor.withOpacity(0.2)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
      ),
    );
  }
}

class _MemberQuickView extends StatelessWidget {
  final AppProvider provider;
  const _MemberQuickView({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.members.isEmpty) {
      return const Text('Chưa có thành viên',
          style: TextStyle(color: AppTheme.textSecondary));
    }
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: provider.members.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final member = provider.members[index];
          final taskCount = provider.tasks
              .where((t) =>
                  t.assignedMemberIds.contains(member.id) &&
                  t.status != TaskStatus.completed)
              .length;
          return Container(
            width: 80,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MemberAvatar(avatarKey: member.avatarEmoji, size: 36),
                const SizedBox(height: 2),
                Text(
                  member.name,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$taskCount việc',
                  style: const TextStyle(
                      fontSize: 10, color: AppTheme.textSecondary),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
