import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/task_bloc.dart';
import '../models/task.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/priority_chip.dart';
import '../constants/app_constants.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();

  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _selectedPriority = widget.task!.priority;
      _selectedDate = widget.task!.dueDate;
      _dueDateController.text = DateFormat('MMM dd, yyyy').format(_selectedDate!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dueDateController.text = DateFormat('MMM dd, yyyy').format(picked);
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;

      if (widget.task != null) {
        // Update existing task
        final updatedTask = widget.task!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dueDate: _selectedDate!,
          priority: _selectedPriority,
        );
        context.read<TaskBloc>().add(TaskUpdateRequested(task: updatedTask));
      } else {
        // Create new task
        final newTask = Task(
          id: '', // Firestore will generate this
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dueDate: _selectedDate!,
          priority: _selectedPriority,
          status: TaskStatus.pending,
          userId: user.id,
          createdAt: DateTime.now(),
        );
        context.read<TaskBloc>().add(TaskAddRequested(task: newTask));
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? AppStrings.editTask : AppStrings.addTask,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: Text(
              'Save',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: BlocListener<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task Title
                CustomTextField(
                  label: AppStrings.taskTitle,
                  hintText: 'Enter task title',
                  controller: _titleController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a task title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Task Description
                CustomTextField(
                  label: AppStrings.description,
                  hintText: 'Enter task description',
                  controller: _descriptionController,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                // Due Date
                CustomTextField(
                  label: AppStrings.dueDate,
                  hintText: 'Select due date',
                  controller: _dueDateController,
                  readOnly: true,
                  onTap: _selectDate,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a due date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Priority Section
                const Text(
                  AppStrings.priority,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: TaskPriority.values.map((priority) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: PriorityChip(
                        priority: priority,
                        isSelected: _selectedPriority == priority,
                        onTap: () {
                          setState(() {
                            _selectedPriority = priority;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),

                // Save Button (Alternative to AppBar save)
                CustomButton(
                  text: isEditing ? 'Update Task' : 'Create Task',
                  onPressed: _saveTask,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}