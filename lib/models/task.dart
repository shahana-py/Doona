import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskPriority { low, medium, high }
enum TaskStatus { pending, completed }

class Task extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final String userId;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.status,
    required this.userId,
    required this.createdAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    String? userId,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'priority': priority.name,
      'status': status.name,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Task.fromMap(String id, Map<String, dynamic> map) {
    return Task(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      priority: TaskPriority.values.firstWhere(
            (e) => e.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
            (e) => e.name == map['status'],
        orElse: () => TaskStatus.pending,
      ),
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  @override
  List<Object> get props => [id, title, description, dueDate, priority, status, userId, createdAt];
}
