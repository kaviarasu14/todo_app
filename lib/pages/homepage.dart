import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../service/task_service.dart';
import '../authentication/auth_service.dart';
import '../widgets/drawer.dart';
import '../widgets/task_tile.dart';
import '../widgets/filter_button.dart';
import '../pages/task_form_page.dart';
import '../utils/notification.dart';

class Homepage extends StatefulWidget {
  Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final AuthService _authService = AuthService();
  final User? user = FirebaseAuth.instance.currentUser;

  TaskFilter _filter = TaskFilter.all;

  //filter logic
  List<Task> _filteredTasks(List<Task> allTasks) {
    List<Task> filtered;

    switch (_filter) {
      case TaskFilter.completed:
        filtered = allTasks.where((task) => task.isDone).toList();
        break;
      case TaskFilter.incomplete:
        filtered = allTasks.where((task) => !task.isDone).toList();
        break;
      case TaskFilter.all:
        filtered = allTasks;
    }

    //priority logic
    filtered.sort((a, b) {
      // Incomplete first
      if (a.isDone != b.isDone) return a.isDone ? 1 : -1;

      // Higher priority next
      if (a.priority != b.priority) return b.priority.compareTo(a.priority);

      // Older tasks first
      return a.createdAt.compareTo(b.createdAt);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final taskService = Provider.of<TaskService>(context);
    final isLoading = taskService.isLoading;
    final filteredTasks = _filteredTasks(taskService.tasks);

    return Scaffold(
      backgroundColor: Colors.grey[50],

      appBar: AppBar(
        title: const Text('Todo List', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
        elevation: 3,
      ),
      drawer: drawer(user: user, authService: _authService),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TaskFilterDropdown(
                      selectedFilter: _filter,
                      onChanged: (newFilter) {
                        setState(() {
                          _filter = newFilter;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => taskService.loadTasks(),
                      child: filteredTasks.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 250),
                                Center(
                                  child: Text(
                                    'No tasks found.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 80),
                              itemCount: filteredTasks.length,
                              itemBuilder: (context, index) {
                                final task = filteredTasks[index];
                                return TaskTile(
                                  task: task,
                                  onToggleDone: () async {
                                    await taskService.toggleTaskStatus(task.id);
                                  },
                                  onEdit: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            TaskFormPage(task: task),
                                      ),
                                    );

                                    if (result != null && result is Task) {
                                      await taskService.updateTask(result);
                                      showTopNotification(
                                        context,
                                        'Task updated successfully',
                                        Colors.blueAccent,
                                      );
                                    }
                                  },
                                  onDelete: () async {
                                    await taskService.deleteTask(task.id);
                                    showTopNotification(
                                      context,
                                      'Task deleted',
                                      Colors.redAccent,
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TaskFormPage()),
          );

          if (result != null && result is Task) {
            await taskService.addTask(result);
            showTopNotification(
              context,
              'Task added successfully',
              Colors.green,
            );
          }
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
