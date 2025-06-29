import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskService extends ChangeNotifier {
  final List<Task> _tasks = [];
  final _taskCollection = FirebaseFirestore.instance.collection('tasks');
  final _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Task> get tasks {
    final sortedTasks = [..._tasks];

    sortedTasks.sort((a, b) {
      // Incomplete first, then completed
      if (a.isDone != b.isDone) {
        return a.isDone ? 1 : -1;
      }
      // Within same isDone, sort by priority (high to low)
      if (a.priority != b.priority) {
        return b.priority.compareTo(a.priority);
      }
      // Then by createdAt (older first)
      return a.createdAt.compareTo(b.createdAt);
    });

    return sortedTasks;
  }

  TaskService() {
    _auth.userChanges().listen((user) {
      if (user != null) loadTasks(); // Reload when user logs in/out
    });
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    final user = _auth.currentUser;
    if (user == null) {
      _tasks.clear();
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final snapshot = await _taskCollection
          .where('userId', isEqualTo: user.uid)
          .get();

      _tasks.clear();
      _tasks.addAll(
        snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Task.fromMap(data);
        }),
      );
    } catch (e) {
      print('Error loading tasks: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await _taskCollection.doc(task.id).set(task.toMap());
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
    await _taskCollection.doc(id).delete();
    notifyListeners();
  }

  Future<void> updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      await _taskCollection.doc(updatedTask.id).update(updatedTask.toMap());
      notifyListeners();
    }
  }

  Future<void> toggleTaskStatus(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index].isDone = !_tasks[index].isDone;
      notifyListeners(); // Instant UI feedback

      try {
        await _taskCollection.doc(id).update({'isDone': _tasks[index].isDone});
      } catch (e) {
        //  Revert if update fails
        _tasks[index].isDone = !_tasks[index].isDone;
        notifyListeners();
        // print('Error toggling task status: $e');
      }
    }
  }
}
