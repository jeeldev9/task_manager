import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task_model.dart';
import '../view_model/task_view_model.dart';

class AddEditTaskScreen extends ConsumerStatefulWidget {
  final Task? task; // Pass null for adding a new task

  const AddEditTaskScreen({Key? key, this.task}) : super(key: key);

  @override
  _AddEditTaskScreenState createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends ConsumerState<AddEditTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing task data (if editing)
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
        actions: [
          widget.task == null
              ? SizedBox()
              : IconButton(
                  onPressed: () async {
                    try {
                      await ref
                          .read(taskProvider.notifier)
                          .deleteTask(widget.task?.id ?? 0);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Task "${widget.task?.title}" deleted')),
                      );
                      if (mounted) {
                        ref.refresh(taskProvider);
                      }
                    } catch (e) {
                      debugPrint("$e");
                    }
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Field
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Description Field
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Save Button
              ElevatedButton(
                onPressed: () {
                  final title = _titleController.text.trim();
                  final description = _descriptionController.text.trim();

                  if (title.isNotEmpty) {
                    if (widget.task == null) {
                      // Add new task
                      ref.read(taskProvider.notifier).addTask(
                            Task(
                                id: DateTime.now().millisecondsSinceEpoch,
                                title: title,
                                description: description,
                                isCompleted: false),
                          );
                    } else {
                      // Update existing task
                      ref.read(taskProvider.notifier).updateTask(
                            widget.task!.id!,
                            widget.task!.copyWith(
                              title: title,
                              description: description,
                            ),
                          );
                    }
                    Navigator.pop(context); // Close the screen
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Title cannot be empty')),
                    );
                  }
                },
                child: Text(widget.task == null ? 'Add Task' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
