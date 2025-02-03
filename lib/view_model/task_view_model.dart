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

  Future<void> _initialize() async {
    if (!Hive.isBoxOpen('tasks')) {
      await Hive.openBox<Task>('tasks');
    }
    _box = Hive.box<Task>('tasks');
    state = _box.values.toList();
  }

  Future<void> addTask(Task task) async {
    await _box.add(task);
    state = [...state, task];
  }

  Future<void> updateTask(int taskId, Task updatedTask) async {
    final index = state.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      await _box.putAt(index, updatedTask);
      state = [
        for (final task in state)
          if (task.id == taskId) updatedTask else task,
      ];
    }
  }

  Future<void> deleteTask(int taskId) async {
    final index = state.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      await _box.deleteAt(index);
      state = [
        for (final task in state)
          if (task.id != taskId) task,
      ];
    }
  }

  Future<void> toggleCompletion(int taskId) async {
    final taskToUpdate = state.firstWhere((task) => task.id == taskId);
    if (taskToUpdate == null) return;

    final updatedTask =
        taskToUpdate.copyWith(isCompleted: !taskToUpdate.isCompleted);

    final index = state.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      await _box.putAt(index, updatedTask);
      state = [
        for (final task in state)
          if (task.id == taskId) updatedTask else task,
      ];
    }
  }
}
