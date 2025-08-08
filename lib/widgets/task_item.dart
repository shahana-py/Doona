import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../constants/app_constants.dart';
import 'priority_chip.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleComplete;

  const TaskItem({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.dueDate.isBefore(DateTime.now()) &&
        task.status == TaskStatus.pending;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: onToggleComplete,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.status == TaskStatus.completed
                          ? AppColors.secondary
                          : Colors.transparent,
                      border: Border.all(
                        color: task.status == TaskStatus.completed
                            ? AppColors.secondary
                            : Colors.grey[400]!,
                        width: 2,
                      ),
                    ),
                    child: task.status == TaskStatus.completed
                        ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: task.status == TaskStatus.completed
                          ? Colors.grey[600]
                          : AppColors.onSurface,
                      decoration: task.status == TaskStatus.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                task.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  decoration: task.status == TaskStatus.completed
                      ? TextDecoration.lineThrough
                      : null,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                PriorityChip(priority: task.priority),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOverdue ? AppColors.error.withOpacity(0.1) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: isOverdue ? AppColors.error : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(task.dueDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: isOverdue ? AppColors.error : Colors.grey[600],
                          fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}