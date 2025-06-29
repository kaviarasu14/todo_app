import 'package:flutter/material.dart';

enum TaskFilter { all, completed, incomplete }

class TaskFilterDropdown extends StatelessWidget {
  final TaskFilter selectedFilter;
  final ValueChanged<TaskFilter> onChanged;

  const TaskFilterDropdown({
    super.key,
    required this.selectedFilter,
    required this.onChanged,
  });

  String _label(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.completed:
        return 'Completed';
      case TaskFilter.incomplete:
        return 'Incomplete';
      case TaskFilter.all:
        return 'All';
    }
  }

  IconData _icon(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.completed:
        return Icons.check_circle_outline;
      case TaskFilter.incomplete:
        return Icons.radio_button_unchecked;
      case TaskFilter.all:
        return Icons.list_alt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.deepPurple.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TaskFilter>(
          value: selectedFilter,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.deepPurple,
          ),
          borderRadius: BorderRadius.circular(16),
          dropdownColor: Colors.white,
          style: const TextStyle(color: Colors.black87),
          items: TaskFilter.values.map((filter) {
            return DropdownMenuItem(
              value: filter,
              child: Row(
                children: [
                  Icon(_icon(filter), color: Colors.deepPurple, size: 18),
                  const SizedBox(width: 8),
                  Text(_label(filter)),
                ],
              ),
            );
          }).toList(),
          onChanged: (TaskFilter? value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }
}
