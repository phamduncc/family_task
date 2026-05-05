import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;
  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _noteController;
  late TextEditingController _pointsController;

  TaskPriority _priority = TaskPriority.medium;
  RepeatType _repeatType = RepeatType.none;
  List<int> _repeatDays = [];
  List<int> _assignedMemberIds = [];
  DateTime? _dueDate;
  TimeOfDay? _reminderTime;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleController = TextEditingController(text: t?.title ?? '');
    _noteController = TextEditingController(text: t?.note ?? '');
    _pointsController = TextEditingController(text: '${t?.points ?? 10}');
    if (t != null) {
      _priority = t.priority;
      _repeatType = t.repeatType;
      _repeatDays = List.from(t.repeatDays);
      _assignedMemberIds = List.from(t.assignedMemberIds);
      _dueDate = t.dueDate;
      if (t.reminderTime != null) {
        final parts = t.reminderTime!.split(':');
        _reminderTime =
            TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
      locale: const Locale('vi', 'VN'),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: _dueDate != null
            ? TimeOfDay(hour: _dueDate!.hour, minute: _dueDate!.minute)
            : TimeOfDay.now(),
      );
      setState(() {
        _dueDate = DateTime(
          date.year,
          date.month,
          date.day,
          time?.hour ?? 0,
          time?.minute ?? 0,
        );
      });
    }
  }

  Future<void> _pickReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _reminderTime = time);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AppProvider>();
    final task = Task(
      id: widget.task?.id,
      title: _titleController.text.trim(),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      priority: _priority,
      status: widget.task?.status ?? TaskStatus.pending,
      assignedMemberIds: _assignedMemberIds,
      dueDate: _dueDate,
      reminderTime: _reminderTime != null
          ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
          : null,
      repeatType: _repeatType,
      repeatDays: _repeatDays,
      points: int.tryParse(_pointsController.text) ?? 10,
      imagePath: widget.task?.imagePath,
      createdAt: widget.task?.createdAt,
      completedAt: widget.task?.completedAt,
      completedByMemberId: widget.task?.completedByMemberId,
    );

    if (_isEditing) {
      await provider.updateTask(task);
    } else {
      await provider.addTask(task);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh Sửa Việc' : 'Thêm Việc Mới'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Lưu',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection('📝 Tên Công Việc', [
              TextFormField(
                controller: _titleController,
                decoration:
                    _inputDeco('Ví dụ: Lau nhà, Rửa bát...', Icons.title),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Vui lòng nhập tên' : null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection('📋 Ghi Chú', [
              TextFormField(
                controller: _noteController,
                decoration: _inputDeco('Thêm ghi chú chi tiết...', Icons.notes),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection('🎯 Mức Độ Ưu Tiên', [
              Row(
                children: TaskPriority.values.map((p) {
                  final labels = ['Thấp', 'Trung bình', 'Cao'];
                  final colors = [
                    AppTheme.priorityLow,
                    AppTheme.priorityMedium,
                    AppTheme.priorityHigh
                  ];
                  final emojis = ['🟢', '🟡', '🔴'];
                  final isSelected = _priority == p;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _priority = p),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors[p.index].withOpacity(0.15)
                                : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? colors[p.index]
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(emojis[p.index],
                                  style: const TextStyle(fontSize: 20)),
                              const SizedBox(height: 4),
                              Text(
                                labels[p.index],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? colors[p.index]
                                      : AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection('👨‍👩‍👧‍👦 Giao Cho', [
              if (provider.members.isEmpty)
                const Text(
                    'Chưa có thành viên. Vui lòng thêm thành viên trước.',
                    style: TextStyle(color: AppTheme.textSecondary))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: provider.members.map((m) {
                    final isSelected = _assignedMemberIds.contains(m.id);
                    return GestureDetector(
                      onTap: () => setState(() {
                        if (isSelected) {
                          _assignedMemberIds.remove(m.id);
                        } else {
                          _assignedMemberIds.add(m.id!);
                        }
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.accentColor.withOpacity(0.15)
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.accentColor
                                : Colors.grey.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(m.avatarEmoji),
                            const SizedBox(width: 6),
                            Text(m.name,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color:
                                      isSelected ? AppTheme.accentColor : null,
                                )),
                            if (isSelected) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.check_circle,
                                  size: 16, color: AppTheme.accentColor),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ]),
            const SizedBox(height: 16),
            _buildSection('📅 Thời Hạn', [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today,
                    color: AppTheme.primaryColor),
                title: Text(
                  _dueDate != null
                      ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year} '
                          '${_dueDate!.hour.toString().padLeft(2, '0')}:${_dueDate!.minute.toString().padLeft(2, '0')}'
                      : 'Chọn ngày & giờ',
                  style: TextStyle(
                      color: _dueDate != null ? null : AppTheme.textSecondary),
                ),
                trailing: _dueDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _dueDate = null),
                      )
                    : const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _pickDate,
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection('⏰ Nhắc Nhở', [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.alarm, color: AppTheme.primaryColor),
                title: Text(
                  _reminderTime != null
                      ? 'Nhắc lúc ${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
                      : 'Không nhắc',
                  style: TextStyle(
                      color: _reminderTime != null
                          ? null
                          : AppTheme.textSecondary),
                ),
                trailing: _reminderTime != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _reminderTime = null),
                      )
                    : const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _pickReminderTime,
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection('🔁 Lặp Lại', [
              DropdownButtonFormField<RepeatType>(
                value: _repeatType,
                decoration: _inputDeco('Chọn kiểu lặp', Icons.repeat),
                items: const [
                  DropdownMenuItem(
                      value: RepeatType.none, child: Text('Không lặp')),
                  DropdownMenuItem(
                      value: RepeatType.daily, child: Text('Hàng ngày')),
                  DropdownMenuItem(
                      value: RepeatType.weekly, child: Text('Hàng tuần')),
                  DropdownMenuItem(
                      value: RepeatType.monthly, child: Text('Hàng tháng')),
                ],
                onChanged: (v) => setState(() => _repeatType = v!),
              ),
              if (_repeatType == RepeatType.weekly) ...[
                const SizedBox(height: 10),
                const Text('Chọn ngày trong tuần:',
                    style:
                        TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 6),
                _WeekdayPicker(
                  selected: _repeatDays,
                  onChanged: (days) => setState(() => _repeatDays = days),
                ),
              ],
            ]),
            const SizedBox(height: 16),
            _buildSection('⭐ Điểm Thưởng', [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pointsController,
                      decoration: _inputDeco('Điểm khi hoàn thành', Icons.star),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n < 1) return 'Điểm phải > 0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  _PointPreset(
                    points: [5, 10, 20, 30],
                    selected: int.tryParse(_pointsController.text) ?? 10,
                    onTap: (v) => setState(() => _pointsController.text = '$v'),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _save,
              icon: Icon(_isEditing ? Icons.save : Icons.add_task),
              label: Text(_isEditing ? 'Lưu Thay Đổi' : 'Tạo Công Việc'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}

class _WeekdayPicker extends StatelessWidget {
  final List<int> selected;
  final ValueChanged<List<int>> onChanged;

  const _WeekdayPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = i + 1;
        final isSelected = selected.contains(day);
        return GestureDetector(
          onTap: () {
            final newList = List<int>.from(selected);
            if (isSelected) {
              newList.remove(day);
            } else {
              newList.add(day);
            }
            onChanged(newList);
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryColor
                    : Colors.grey.withOpacity(0.4),
              ),
            ),
            child: Center(
              child: Text(
                days[i],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _PointPreset extends StatelessWidget {
  final List<int> points;
  final int selected;
  final ValueChanged<int> onTap;

  const _PointPreset(
      {required this.points, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: points.map((p) {
        final isSelected = selected == p;
        return GestureDetector(
          onTap: () => onTap(p),
          child: Container(
            margin: const EdgeInsets.only(left: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.warningColor.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppTheme.warningColor
                    : Colors.grey.withOpacity(0.3),
              ),
            ),
            child: Text('$p',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppTheme.warningColor
                      : AppTheme.textSecondary,
                )),
          ),
        );
      }).toList(),
    );
  }
}
