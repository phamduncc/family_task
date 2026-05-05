import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

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
        final all = provider.tasks;
        final pending = all.where((t) => t.status == TaskStatus.pending || t.status == TaskStatus.inProgress).toList();
        final completed = all.where((t) => t.status == TaskStatus.completed).toList();
        final overdue = all.where((t) => t.isOverdue).toList();

        List<Task> _filterSearch(List<Task> list) {
          if (_searchQuery.isEmpty) return list;
          return list
              .where((t) => t.title.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('📋 Danh Sách Việc'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm công việc...',
                        hintStyle: const TextStyle(color: Colors.white60),
                        prefixIcon: const Icon(Icons.search, color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (v) => setState(() => _searchQuery = v),
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    indicatorColor: Colors.white,
                    tabs: [
                      Tab(text: 'Chờ (${pending.length})'),
                      Tab(text: 'Xong (${completed.length})'),
                      Tab(text: 'Quá hạn (${overdue.length})'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          body: Column(
            children: [
              _FilterBar(provider: provider),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _TaskList(tasks: _filterSearch(pending), provider: provider),
                    _TaskList(tasks: _filterSearch(completed), provider: provider),
                    _TaskList(tasks: _filterSearch(overdue), provider: provider, emptyMessage: '🎉 Không có việc quá hạn!'),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TaskFormScreen()),
            ),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

class _FilterBar extends StatelessWidget {
  final AppProvider provider;
  const _FilterBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          _FilterChip(
            label: 'Tất cả',
            isSelected: provider.selectedMemberFilter == null,
            onTap: () => provider.setMemberFilter(null),
          ),
          ...provider.members.map((m) => _FilterChip(
            label: '${m.avatarEmoji} ${m.name}',
            isSelected: provider.selectedMemberFilter == m.id,
            onTap: () => provider.setMemberFilter(
              provider.selectedMemberFilter == m.id ? null : m.id,
            ),
          )),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<Task> tasks;
  final AppProvider provider;
  final String emptyMessage;

  const _TaskList({
    required this.tasks,
    required this.provider,
    this.emptyMessage = 'Không có công việc nào',
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📭', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(emptyMessage, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, i) => TaskCard(
        task: tasks[i],
        onChanged: () => provider.loadTasks(),
      ),
    );
  }
}
