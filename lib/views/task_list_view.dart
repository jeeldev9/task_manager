import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view_model/task_view_model.dart';

class TaskListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings), // Settings icon
            onPressed: () {
              Navigator.pushNamed(
                  context, '/settings'); // Navigate to Settings Screen
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Dismissible(
            key: Key(task.id.toString()), // Unique key for each task
            direction: DismissDirection.endToStart, // Swipe to delete
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              child: Icon(Icons.delete, color: Colors.white),
            ),

            child: ListTile(
              title: Text(task.title),
              subtitle: Text(task.description),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Checkbox for toggling completion status
                  Checkbox(
                    value: task.isCompleted,
                    onChanged: (value) {
                      ref
                          .read(taskProvider.notifier)
                          .toggleCompletion(task.id!);
                    },
                  ),
                  // Edit button
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/edit-task',
                        arguments: task, // Pass the task to edit
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-task');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
