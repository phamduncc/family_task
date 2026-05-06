import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/app_provider.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../widgets/task_card.dart';
import '../widgets/app_icon.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final selectedTasks = provider.getTasksForDate(_selectedDay);

        List<Task> _getEventsForDay(DateTime day) {
          return provider.getTasksForDate(day);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Lịch Công Việc'),
            actions: [
              IconButton(
                icon: const Icon(Icons.today),
                onPressed: () => setState(() {
                  _focusedDay = DateTime.now();
                  _selectedDay = DateTime.now();
                }),
              ),
            ],
          ),
          body: Column(
            children: [
              TableCalendar<Task>(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2027, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                eventLoader: _getEventsForDay,
                startingDayOfWeek: StartingDayOfWeek.monday,
                locale: 'vi_VN',
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: AppTheme.accentColor,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 3,
                  todayTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                  selectedTextStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                headerStyle: HeaderStyle(
                  formatButtonDecoration: BoxDecoration(
                    border: Border.all(color: AppTheme.primaryColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  formatButtonTextStyle:
                      const TextStyle(color: AppTheme.primaryColor),
                  titleCentered: true,
                  titleTextStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                  });
                },
                onFormatChanged: (format) =>
                    setState(() => _calendarFormat = format),
                onPageChanged: (focused) =>
                    setState(() => _focusedDay = focused),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    _DayStatusChips(tasks: selectedTasks),
                  ],
                ),
              ),
              Expanded(
                child: selectedTasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgIcon(AppIcons.calendar, size: 48),
                            const SizedBox(height: 8),
                            const Text('Không có việc trong ngày này',
                                style:
                                    TextStyle(color: AppTheme.textSecondary)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: selectedTasks.length,
                        itemBuilder: (context, index) => TaskCard(
                          task: selectedTasks[index],
                          onChanged: () => provider.loadTasks(),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DayStatusChips extends StatelessWidget {
  final List<Task> tasks;
  const _DayStatusChips({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final done = tasks.where((t) => t.status == TaskStatus.completed).length;
    final total = tasks.length;
    if (total == 0) return const SizedBox.shrink();
    return Row(
      children: [
        _Chip(
            label: '$done/$total',
            color: AppTheme.successColor,
            icon: Icons.check_circle_outline),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _Chip({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
