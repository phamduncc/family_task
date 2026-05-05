import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/reward.dart';
import '../theme/app_theme.dart';

class GamificationScreen extends StatefulWidget {
  const GamificationScreen({super.key});

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('🎮 Gamification'),
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: Colors.white,
              tabs: const [
                Tab(text: '🏆 Điểm'),
                Tab(text: '🏅 Huy Hiệu'),
                Tab(text: '🎁 Phần Thưởng'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _PointsTab(provider: provider),
              _BadgesTab(provider: provider),
              _RewardsTab(provider: provider),
            ],
          ),
        );
      },
    );
  }
}

class _PointsTab extends StatelessWidget {
  final AppProvider provider;
  const _PointsTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final ranked = List.from(provider.members)
      ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Text('🏆 Bảng Xếp Hạng', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              const Text('Ai chăm chỉ nhất tháng này?', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 16),
              if (ranked.isNotEmpty) _TopPodium(ranked: ranked),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('📊 Chi Tiết Điểm',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...ranked.asMap().entries.map((entry) {
          final rank = entry.key + 1;
          final member = entry.value;
          final rankEmoji = rank == 1 ? '🥇' : rank == 2 ? '🥈' : rank == 3 ? '🥉' : '$rank.';
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
            ),
            child: Row(
              children: [
                Text(rankEmoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Text(member.avatarEmoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(member.role,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      if (member.streakDays > 0)
                        Text('🔥 ${member.streakDays} ngày liên tiếp',
                            style: const TextStyle(fontSize: 12, color: AppTheme.dangerColor)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${member.totalPoints}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: rank == 1 ? AppTheme.warningColor : AppTheme.textPrimary,
                      ),
                    ),
                    const Text('điểm', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _TopPodium extends StatelessWidget {
  final List ranked;
  const _TopPodium({required this.ranked});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (ranked.length > 1) _PodiumItem(member: ranked[1], rank: 2, height: 70),
        const SizedBox(width: 8),
        _PodiumItem(member: ranked[0], rank: 1, height: 90),
        const SizedBox(width: 8),
        if (ranked.length > 2) _PodiumItem(member: ranked[2], rank: 3, height: 55),
      ],
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final dynamic member;
  final int rank;
  final double height;
  const _PodiumItem({required this.member, required this.rank, required this.height});

  @override
  Widget build(BuildContext context) {
    final rankEmoji = rank == 1 ? '🥇' : rank == 2 ? '🥈' : '🥉';
    return Column(
      children: [
        Text(member.avatarEmoji, style: const TextStyle(fontSize: 28)),
        Text(member.name,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        Text('${member.totalPoints}⭐',
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 4),
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(rankEmoji, style: const TextStyle(fontSize: 24)),
              Text('$rank', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
}

class _BadgesTab extends StatelessWidget {
  final AppProvider provider;
  const _BadgesTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...provider.members.map((member) {
          final memberBadges = provider.getBadgesForMember(member.id!);
          final earnedBadgeIds = memberBadges.map((mb) => mb.badgeId).toSet();

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(member.avatarEmoji, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 10),
                    Text(member.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${memberBadges.length}/${provider.badges.length} huy hiệu',
                        style: const TextStyle(fontSize: 12, color: AppTheme.warningColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: provider.badges.map((badge) {
                    final isEarned = earnedBadgeIds.contains(badge.id);
                    return Tooltip(
                      message: badge.description,
                      child: Container(
                        width: 70,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isEarned
                              ? AppTheme.warningColor.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isEarned
                                ? AppTheme.warningColor.withOpacity(0.4)
                                : Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            ColorFiltered(
                              colorFilter: isEarned
                                  ? const ColorFilter.mode(Colors.transparent, BlendMode.saturation)
                                  : const ColorFilter.matrix([
                                      0.2126, 0.7152, 0.0722, 0, 0,
                                      0.2126, 0.7152, 0.0722, 0, 0,
                                      0.2126, 0.7152, 0.0722, 0, 0,
                                      0, 0, 0, 0.3, 0,
                                    ]),
                              child: Text(badge.emoji, style: const TextStyle(fontSize: 26)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              badge.name,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isEarned ? AppTheme.textPrimary : AppTheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('📖 Tất Cả Huy Hiệu',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...provider.badges.map((badge) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Text(badge.emoji, style: const TextStyle(fontSize: 28)),
                title: Text(badge.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(badge.description,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              )),
            ],
          ),
        ),
      ],
    );
  }
}

class _RewardsTab extends StatefulWidget {
  final AppProvider provider;
  const _RewardsTab({required this.provider});

  @override
  State<_RewardsTab> createState() => _RewardsTabState();
}

class _RewardsTabState extends State<_RewardsTab> {
  void _showAddRewardDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final pointCtrl = TextEditingController(text: '100');
    String emoji = '🎁';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Thêm Phần Thưởng'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 8,
                  children: ['🎁', '🎬', '🎡', '🎮', '🍕', '🛋️', '🎂', '✈️', '🎯', '🏖️']
                      .map((e) => GestureDetector(
                            onTap: () => setDialogState(() => emoji = e),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: emoji == e ? AppTheme.primaryColor.withOpacity(0.15) : null,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: emoji == e ? AppTheme.primaryColor : Colors.transparent,
                                ),
                              ),
                              child: Text(e, style: const TextStyle(fontSize: 24)),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Tên phần thưởng', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Mô tả', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: pointCtrl,
                  decoration: const InputDecoration(labelText: 'Điểm cần thiết', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                widget.provider.addReward(Reward(
                  name: nameCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  emoji: emoji,
                  pointCost: int.tryParse(pointCtrl.text) ?? 100,
                ));
                Navigator.pop(context);
              },
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRedeemDialog(BuildContext context, Reward reward) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${reward.emoji} ${reward.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reward.description),
            const SizedBox(height: 8),
            Text('Cần: ${reward.pointCost} ⭐ điểm',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Chọn thành viên đổi thưởng:',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ...widget.provider.members.map((m) => ElevatedButton(
                onPressed: m.totalPoints >= reward.pointCost
                    ? () {
                        widget.provider.redeemReward(reward.id!, m.id!);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('${m.name} đã đổi "${reward.name}" 🎉'),
                          backgroundColor: AppTheme.successColor,
                        ));
                      }
                    : null,
                child: Text('${m.avatarEmoji} ${m.name}\n(${m.totalPoints}⭐)'),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rewards = widget.provider.rewards;
    final available = rewards.where((r) => !r.isRedeemed).toList();
    final redeemed = rewards.where((r) => r.isRedeemed).toList();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text('🎁', style: TextStyle(fontSize: 40)),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cửa Hàng Phần Thưởng',
                          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                      Text('Dùng điểm để đổi phần thưởng!',
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Có sẵn (${available.length})',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () => _showAddRewardDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Thêm'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (available.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Chưa có phần thưởng nào',
                    style: TextStyle(color: AppTheme.textSecondary)),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: available.length,
              itemBuilder: (context, i) {
                final reward = available[i];
                return GestureDetector(
                  onTap: () => _showRedeemDialog(context, reward),
                  onLongPress: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Xóa phần thưởng?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                        TextButton(
                          onPressed: () {
                            widget.provider.deleteReward(reward.id!);
                            Navigator.pop(context);
                          },
                          child: const Text('Xóa', style: TextStyle(color: AppTheme.dangerColor)),
                        ),
                      ],
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(reward.emoji, style: const TextStyle(fontSize: 36)),
                        const SizedBox(height: 6),
                        Text(reward.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '⭐ ${reward.pointCost} điểm',
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.warningColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          if (redeemed.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('✅ Đã Đổi (${redeemed.length})',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...redeemed.map((reward) {
              final member = reward.redeemedByMemberId != null
                  ? widget.provider.getMemberById(reward.redeemedByMemberId!)
                  : null;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.successColor.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Text(reward.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(reward.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (member != null)
                            Text('Đổi bởi: ${member.avatarEmoji} ${member.name}',
                                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle, color: AppTheme.successColor),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
