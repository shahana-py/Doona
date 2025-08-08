import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/task.dart';
import '../services/task_service.dart';

// Events
abstract class TaskEvent extends Equatable {
  const TaskEvent();
  @override
  List<Object?> get props => [];
}

class TasksLoadRequested extends TaskEvent {
  final String userId;
  const TasksLoadRequested({required this.userId});
  @override
  List<Object> get props => [userId];
}

class TaskAddRequested extends TaskEvent {
  final Task task;
  const TaskAddRequested({required this.task});
  @override
  List<Object> get props => [task];
}

class TaskUpdateRequested extends TaskEvent {
  final Task task;
  const TaskUpdateRequested({required this.task});
  @override
  List<Object> get props => [task];
}

class TaskDeleteRequested extends TaskEvent {
  final String taskId;
  const TaskDeleteRequested({required this.taskId});
  @override
  List<Object> get props => [taskId];
}

class TasksFilterChanged extends TaskEvent {
  final TaskPriority? priority;
  final TaskStatus? status;
  const TasksFilterChanged({this.priority, this.status});
  @override
  List<Object?> get props => [priority, status];
}

// States
abstract class TaskState extends Equatable {
  const TaskState();
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> tasks;
  final List<Task> filteredTasks;
  final TaskPriority? priorityFilter;
  final TaskStatus? statusFilter;

  const TaskLoaded({
    required this.tasks,
    required this.filteredTasks,
    this.priorityFilter,
    this.statusFilter,
  });

  @override
  List<Object?> get props => [tasks, filteredTasks, priorityFilter, statusFilter];

  TaskLoaded copyWith({
    List<Task>? tasks,
    List<Task>? filteredTasks,
    TaskPriority? priorityFilter,
    TaskStatus? statusFilter,
  }) {
    return TaskLoaded(
      tasks: tasks ?? this.tasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      priorityFilter: priorityFilter,
      statusFilter: statusFilter,
    );
  }
}

class TaskError extends TaskState {
  final String message;
  const TaskError({required this.message});
  @override
  List<Object> get props => [message];
}

// BLoC
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskService _taskService;

  TaskBloc(this._taskService) : super(TaskInitial()) {
    on<TasksLoadRequested>(_onTasksLoadRequested);
    on<TaskAddRequested>(_onTaskAddRequested);
    on<TaskUpdateRequested>(_onTaskUpdateRequested);
    on<TaskDeleteRequested>(_onTaskDeleteRequested);
    on<TasksFilterChanged>(_onTasksFilterChanged);
  }

  Future<void> _onTasksLoadRequested(
      TasksLoadRequested event,
      Emitter<TaskState> emit,
      ) async {
    emit(TaskLoading());
    try {
      final tasks = await _taskService.getTasks(event.userId);
      emit(TaskLoaded(tasks: tasks, filteredTasks: tasks));
    } catch (e) {
      emit(TaskError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onTaskAddRequested(
      TaskAddRequested event,
      Emitter<TaskState> emit,
      ) async {
    if (state is TaskLoaded) {
      try {
        await _taskService.addTask(event.task);
        final currentState = state as TaskLoaded;
        final updatedTasks = await _taskService.getTasks(event.task.userId);
        final filteredTasks = _filterTasks(
          updatedTasks,
          currentState.priorityFilter,
          currentState.statusFilter,
        );
        emit(currentState.copyWith(
          tasks: updatedTasks,
          filteredTasks: filteredTasks,
        ));
      } catch (e) {
        emit(TaskError(message: e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  Future<void> _onTaskUpdateRequested(
      TaskUpdateRequested event,
      Emitter<TaskState> emit,
      ) async {
    if (state is TaskLoaded) {
      try {
        await _taskService.updateTask(event.task);
        final currentState = state as TaskLoaded;
        final updatedTasks = await _taskService.getTasks(event.task.userId);
        final filteredTasks = _filterTasks(
          updatedTasks,
          currentState.priorityFilter,
          currentState.statusFilter,
        );
        emit(currentState.copyWith(
          tasks: updatedTasks,
          filteredTasks: filteredTasks,
        ));
      } catch (e) {
        emit(TaskError(message: e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  Future<void> _onTaskDeleteRequested(
      TaskDeleteRequested event,
      Emitter<TaskState> emit,
      ) async {
    if (state is TaskLoaded) {
      try {
        await _taskService.deleteTask(event.taskId);
        final currentState = state as TaskLoaded;
        final updatedTasks = currentState.tasks
            .where((task) => task.id != event.taskId)
            .toList();
        final filteredTasks = _filterTasks(
          updatedTasks,
          currentState.priorityFilter,
          currentState.statusFilter,
        );
        emit(currentState.copyWith(
          tasks: updatedTasks,
          filteredTasks: filteredTasks,
        ));
      } catch (e) {
        emit(TaskError(message: e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  void _onTasksFilterChanged(
      TasksFilterChanged event,
      Emitter<TaskState> emit,
      ) {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      final filteredTasks = _filterTasks(
        currentState.tasks,
        event.priority,
        event.status,
      );
      emit(currentState.copyWith(
        filteredTasks: filteredTasks,
        priorityFilter: event.priority,
        statusFilter: event.status,
      ));
    }
  }

  List<Task> _filterTasks(
      List<Task> tasks,
      TaskPriority? priority,
      TaskStatus? status,
      ) {
    var filtered = tasks;

    if (priority != null) {
      filtered = filtered.where((task) => task.priority == priority).toList();
    }

    if (status != null) {
      filtered = filtered.where((task) => task.status == status).toList();
    }

    return filtered;
  }
}