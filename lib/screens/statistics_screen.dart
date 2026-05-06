import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icon.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final total = provider.tasks.length;
        final completed = provider.completedTasks.length;
        final pending = provider.pendingTasks.length;
        final overdue = provider.overdueTasks.length;
        final rate = total > 0 ? (completed / total * 100).round() : 0;

        return Scaffold(
          appBar: AppBar(title: const Text('Thống Kê & Báo Cáo')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _OverallStats(
                total: total,
                completed: completed,
                pending: pending,
                overdue: overdue,
                rate: rate,
              ),
              const SizedBox(height: 20),
              if (total > 0) ...[
                _PieChartCard(
                    completed: completed, pending: pending, overdue: overdue),
                const SizedBox(height: 20),
              ],
              _MemberRankings(provider: provider),
              const SizedBox(height: 20),
              _PriorityBreakdown(tasks: provider.tasks),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
}

class _OverallStats extends StatelessWidget {
  final int total, completed, pending, overdue, rate;
  const _OverallStats({
    required this.total,
    required this.completed,
    required this.pending,
    required this.overdue,
    required this.rate,
  });

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tổng Quan',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 6),
          Text('$rate% hoàn thành',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: total > 0 ? completed / total : 0,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _OverallItem(
                  label: 'Tổng',
                  value: '$total',
                  icon: SvgIcon(AppIcons.task, size: 22, color: Colors.white)),
              _OverallItem(
                  label: 'Hoàn thành',
                  value: '$completed',
                  icon: SvgIcon(AppIcons.check, size: 22, color: Colors.white)),
              _OverallItem(
                  label: 'Chờ làm',
                  value: '$pending',
                  icon: SvgIcon(AppIcons.hourglass,
                      size: 22, color: Colors.white)),
              _OverallItem(
                  label: 'Quá hạn',
                  value: '$overdue',
                  icon: const Icon(Icons.warning_amber_rounded,
                      size: 22, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverallItem extends StatelessWidget {
  final String label, value;
  final Widget icon;
  const _OverallItem(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        icon,
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }
}

class _PieChartCard extends StatefulWidget {
  final int completed, pending, overdue;
  const _PieChartCard(
      {required this.completed, required this.pending, required this.overdue});

  @override
  State<_PieChartCard> createState() => _PieChartCardState();
}

class _PieChartCardState extends State<_PieChartCard> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final sections = <PieChartSectionData>[
      PieChartSectionData(
        color: AppTheme.successColor,
        value: widget.completed.toDouble(),
        title: widget.completed > 0 ? '${widget.completed}' : '',
        radius: _touchedIndex == 0 ? 65 : 55,
        titleStyle: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
      ),
      PieChartSectionData(
        color: AppTheme.accentColor,
        value: widget.pending.toDouble(),
        title: widget.pending > 0 ? '${widget.pending}' : '',
        radius: _touchedIndex == 1 ? 65 : 55,
        titleStyle: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
      ),
      PieChartSectionData(
        color: AppTheme.dangerColor,
        value: widget.overdue.toDouble(),
        title: widget.overdue > 0 ? '${widget.overdue}' : '',
        radius: _touchedIndex == 2 ? 65 : 55,
        titleStyle: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    ].where((s) => s.value > 0).toList();

    if (sections.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Phân Bố Công Việc',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                response == null ||
                                response.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex =
                                response.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      sections: sections,
                      centerSpaceRadius: 40,
                      sectionsSpace: 3,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Legend(color: AppTheme.successColor, label: 'Hoàn thành'),
                    const SizedBox(height: 8),
                    _Legend(color: AppTheme.accentColor, label: 'Chờ làm'),
                    const SizedBox(height: 8),
                    _Legend(color: AppTheme.dangerColor, label: 'Quá hạn'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

class _MemberRankings extends StatelessWidget {
  final AppProvider provider;
  const _MemberRankings({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.members.isEmpty) return const SizedBox.shrink();

    final ranked = List.from(provider.members)
      ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            SvgIcon(AppIcons.trophy, size: 18),
            const SizedBox(width: 6),
            const Text('Bảng Xếp Hạng',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 14),
          ...ranked.asMap().entries.map((entry) {
            final rank = entry.key;
            final member = entry.value;
            final memberTasks = provider.tasks
                .where((t) => t.assignedMemberIds.contains(member.id))
                .toList();
            final completedCount = memberTasks
                .where((t) => t.status == TaskStatus.completed)
                .length;
            final total = memberTasks.length;
            final rate = total > 0 ? (completedCount / total * 100).round() : 0;
            final rankSvgs = [
              AppIcons.medal,
              AppIcons.medalSilver,
              AppIcons.medalBronze
            ];
            final rankWidget = rank < 3
                ? SvgIcon(rankSvgs[rank], size: 22)
                : Text('${rank + 1}.',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold));

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: rank == 0
                    ? AppTheme.warningColor.withOpacity(0.08)
                    : Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: rank == 0
                      ? AppTheme.warningColor.withOpacity(0.3)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  rankWidget,
                  const SizedBox(width: 10),
                  MemberAvatar(avatarKey: member.avatarEmoji, size: 32),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('$completedCount/$total việc · $rate% đúng hạn',
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.textSecondary)),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: total > 0 ? completedCount / total : 0,
                            backgroundColor:
                                AppTheme.accentColor.withOpacity(0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              rank == 0
                                  ? AppTheme.warningColor
                                  : AppTheme.accentColor,
                            ),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    children: [
                      SvgIcon(AppIcons.star,
                          size: 16, color: AppTheme.warningColor),
                      Text('${member.totalPoints}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PriorityBreakdown extends StatelessWidget {
  final List<Task> tasks;
  const _PriorityBreakdown({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final high = tasks.where((t) => t.priority == TaskPriority.high).length;
    final medium = tasks.where((t) => t.priority == TaskPriority.medium).length;
    final low = tasks.where((t) => t.priority == TaskPriority.low).length;
    final total = tasks.length;

    if (total == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.tune_rounded, size: 18),
            const SizedBox(width: 6),
            const Text('Phân Loại Ưu Tiên',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 14),
          _PriorityBar(
              label: 'Cao',
              count: high,
              total: total,
              color: AppTheme.priorityHigh),
          const SizedBox(height: 8),
          _PriorityBar(
              label: 'Trung bình',
              count: medium,
              total: total,
              color: AppTheme.priorityMedium),
          const SizedBox(height: 8),
          _PriorityBar(
              label: 'Thấp',
              count: low,
              total: total,
              color: AppTheme.priorityLow),
        ],
      ),
    );
  }
}

class _PriorityBar extends StatelessWidget {
  final String label;
  final int count, total;
  final Color color;
  const _PriorityBar(
      {required this.label,
      required this.count,
      required this.total,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final ratio = total > 0 ? count / total : 0.0;
    return Row(
      children: [
        SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontSize: 13))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('$count',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: color, fontSize: 13)),
      ],
    );
  }
}
