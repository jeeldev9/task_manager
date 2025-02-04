import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/task_model.dart';

final taskProvider =
    StateNotifierProvider.autoDispose<TaskViewModel, List<Task>>((ref) {
  return TaskViewModel();
});

class TaskViewModel extends StateNotifier<List<Task>> {
  late final Box<Task> _box;

  TaskViewModel() : super([]) {
    _initialize();
  }

  // Initialize Hive box
  Future<void> _initialize() async {
    try {
      if (!Hive.isBoxOpen('tasks')) {
        await Hive.openBox<Task>('tasks');
      }
      _box = Hive.box<Task>('tasks');
      state = _box.values.toList();
    } catch (e) {
      print('Error initializing Hive: $e');
    }
  }

  // Add a new task
  Future<void> addTask(Task task) async {
    try {
      await _box.add(task);
      state = [...state, task];
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  // Update an existing task
  Future<void> updateTask(int taskId, Task updatedTask) async {
    try {
      final index = state.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        await _box.putAt(index, updatedTask);
        _updateState(taskId, updatedTask);
      }
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  // Delete a task
  Future<void> deleteTask(int taskId) async {
    try {
      final index = state.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        await _box.deleteAt(index);
        _removeFromState(taskId);
      }
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  // Toggle task completion status
  Future<void> toggleCompletion(int taskId) async {
    try {
      final taskToUpdate = state.firstWhere((task) => task.id == taskId);
      final updatedTask =
          taskToUpdate.copyWith(isCompleted: !taskToUpdate.isCompleted);

      final index = state.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        await _box.putAt(index, updatedTask);
        _updateState(taskId, updatedTask);
      }
    } catch (e) {
      print('Error toggling task completion: $e');
    }
  }

  // Helper method to update the state with a modified task
  void _updateState(int taskId, Task updatedTask) {
    state = [
      for (final task in state)
        if (task.id == taskId) updatedTask else task,
    ];
  }

  // Helper method to remove a task from the state
  void _removeFromState(int taskId) {
    state = [
      for (final task in state)
        if (task.id != taskId) task,
    ];
  }
}
