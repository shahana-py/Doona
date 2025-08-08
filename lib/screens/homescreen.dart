
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/task_bloc.dart';
import '../models/task.dart';
import '../constants/app_constants.dart';
import '../widgets/task_item.dart';
import '../widgets/priority_chip.dart';
import 'add_edit_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TaskPriority? _selectedPriority;
  TaskStatus? _selectedStatus;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;
    context.read<TaskBloc>().add(TasksLoadRequested(userId: user.id));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  List<Task> _filterTasksBySearch(List<Task> tasks) {
    if (_searchQuery.isEmpty) return tasks;

    return tasks.where((task) {
      return task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (task.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Tasks',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Priority',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  GestureDetector(
                    onTap: () => setState(() {
                      _selectedPriority = null;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _selectedPriority == null
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Text(
                        'All',
                        style: TextStyle(
                          color: _selectedPriority == null
                              ? Colors.white
                              : AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  ...TaskPriority.values.map((priority) => PriorityChip(
                    priority: priority,
                    isSelected: _selectedPriority == priority,
                    onTap: () => setState(() {
                      _selectedPriority = _selectedPriority == priority ? null : priority;
                    }),
                  )),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _buildStatusChip('All', _selectedStatus == null, () {
                    setState(() => _selectedStatus = null);
                  }),
                  _buildStatusChip('Pending', _selectedStatus == TaskStatus.pending, () {
                    setState(() => _selectedStatus = _selectedStatus == TaskStatus.pending ? null : TaskStatus.pending);
                  }),
                  _buildStatusChip('Completed', _selectedStatus == TaskStatus.completed, () {
                    setState(() => _selectedStatus = _selectedStatus == TaskStatus.completed ? null : TaskStatus.completed);
                  }),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedPriority = null;
                          _selectedStatus = null;
                        });
                        context.read<TaskBloc>().add(
                          const TasksFilterChanged(),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<TaskBloc>().add(
                          TasksFilterChanged(
                            priority: _selectedPriority,
                            status: _selectedStatus,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  List<Task> _getTasksForToday(List<Task> tasks) {
    final today = DateTime.now();
    return tasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.year == today.year &&
          task.dueDate!.month == today.month &&
          task.dueDate!.day == today.day;
    }).toList();
  }

  List<Task> _getTasksForTomorrow(List<Task> tasks) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return tasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.year == tomorrow.year &&
          task.dueDate!.month == tomorrow.month &&
          task.dueDate!.day == tomorrow.day;
    }).toList();
  }

  List<Task> _getTasksForThisWeek(List<Task> tasks) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return tasks.where((task) {
      if (task.dueDate == null) return false;
      final taskDate = task.dueDate!;
      return taskDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          taskDate.isBefore(endOfWeek.add(const Duration(days: 1))) &&
          !_isToday(taskDate) &&
          !_isTomorrow(taskDate);
    }).toList();
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  bool _isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  Widget _buildModernTaskItem(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              final updatedTask = task.copyWith(
                status: task.status == TaskStatus.completed
                    ? TaskStatus.pending
                    : TaskStatus.completed,
              );
              context.read<TaskBloc>().add(
                TaskUpdateRequested(task: updatedTask),
              );
            },
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: task.status == TaskStatus.completed
                      ? AppColors.primary
                      : Colors.grey[400]!,
                  width: 2,
                ),
                color: task.status == TaskStatus.completed
                    ? AppColors.primary
                    : Colors.transparent,
              ),
              child: task.status == TaskStatus.completed
                  ? const Icon(
                Icons.check,
                size: 12,
                color: Colors.white,
              )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: task.status == TaskStatus.completed
                        ? Colors.grey[400]
                        : Colors.black87,
                    decoration: task.status == TaskStatus.completed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (task.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (task.priority != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(task.priority!).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    task.priority!.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getPriorityColor(task.priority!),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditTaskScreen(task: task),
                      ),
                    );
                  } else if (value == 'delete') {
                    _showDeleteDialog(task.id);
                  }
                },
                itemBuilder: (context) => [
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
        ],
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.blue;
    }
  }

  Widget _buildTaskSection(String title, List<Task> tasks) {
    if (tasks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: tasks.map((task) => _buildModernTaskItem(task)).toList(),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;

    if (_isSearching) {
      return AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search tasks...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _isSearching = false;
                _searchQuery = '';
                _searchController.clear();
              });
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    }

    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today: ${_formatDate(DateTime.now())}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),

          const Text(
            'My tasks',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: _showFilterBottomSheet,
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.account_circle, color: Colors.white),
          onSelected: (value) {
            if (value == 'logout') {
              context.read<AuthBloc>().add(AuthLogoutRequested());
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              value: 'email',
              enabled: false,
              child: Text(
                user.email,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 18),
                  SizedBox(width: 8),
                  Text('Logout'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskError) {
            print(state.message);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TaskLoaded) {
            final allTasks = _filterTasksBySearch(state.filteredTasks);
            final todayTasks = _getTasksForToday(allTasks);
            final tomorrowTasks = _getTasksForTomorrow(allTasks);
            final thisWeekTasks = _getTasksForThisWeek(allTasks);

            if (allTasks.isEmpty && _searchQuery.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tasks found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try searching with different keywords',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            if (allTasks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tasks found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your first task to get started!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<TaskBloc>().add(TasksLoadRequested(userId: user.id));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_searchQuery.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 12),
                        child: Text(
                          'Search Results (${allTasks.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: allTasks.map((task) => _buildModernTaskItem(task)).toList(),
                        ),
                      ),
                    ] else ...[
                      _buildTaskSection('Today', todayTasks),
                      _buildTaskSection('Tomorrow', tomorrowTasks),
                      _buildTaskSection('This week', thisWeekTasks),
                    ],
                    const SizedBox(height: 100), // Extra space for floating button
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddEditTaskScreen(),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  void _showDeleteDialog(String taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskBloc>().add(TaskDeleteRequested(taskId: taskId));
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}