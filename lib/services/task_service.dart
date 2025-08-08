import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Task>> getTasks(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .orderBy('dueDate')
          .get();

      return querySnapshot.docs
          .map((doc) => Task.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get tasks: $e');
    }
  }

  Future<void> addTask(Task task) async {
    try {
      await _firestore.collection('tasks').add(task.toMap());
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _firestore.collection('tasks').doc(task.id).update(task.toMap());
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  Stream<List<Task>> getTasksStream(String userId) {
    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Task.fromMap(doc.id, doc.data()))
        .toList());
  }
}