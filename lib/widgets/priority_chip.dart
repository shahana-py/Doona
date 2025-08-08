import 'package:flutter/material.dart';
import '../models/task.dart';
import '../constants/app_constants.dart';

class PriorityChip extends StatelessWidget {
  final TaskPriority priority;
  final bool isSelected;
  final VoidCallback? onTap;

  const PriorityChip({
    super.key,
    required this.priority,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color getColor() {
      switch (priority) {
        case TaskPriority.low:
          return AppColors.lowPriority;
        case TaskPriority.medium:
          return AppColors.mediumPriority;
        case TaskPriority.high:
          return AppColors.highPriority;
      }
    }

    String getText() {
      switch (priority) {
        case TaskPriority.low:
          return AppStrings.low;
        case TaskPriority.medium:
          return AppStrings.medium;
        case TaskPriority.high:
          return AppStrings.high;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? getColor() : getColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: getColor(),
            width: 1,
          ),
        ),
        child: Text(
          getText(),
          style: TextStyle(
            color: isSelected ? Colors.white : getColor(),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}