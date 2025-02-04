import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For formatting dates
import 'package:table_calendar/table_calendar.dart'; // For calendar integration
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
  DateTime _selectedDate = DateTime.now(); // Default due date
  int _selectedPriority = 3; // Default priority (Low)

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing task data (if editing)
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    if (widget.task != null) {
      _selectedDate = widget.task!.dueDate; // Set due date from existing task
      _selectedPriority =
          widget.task!.priority; // Set priority from existing task
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access the current theme
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.task == null ? 'Add Task' : 'Edit Task',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [Colors.deepPurple, Colors.purple]
                  : [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
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
                  labelStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText: _titleController.text.isEmpty
                      ? 'Title is required'
                      : null,
                  errorStyle: TextStyle(color: Colors.red),
                ),
              ),
              SizedBox(height: 16),

              // Description Field
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Due Date Picker
              Text(
                'Due Date',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface),
              ),
              SizedBox(height: 8),
              TableCalendar(
                availableGestures: AvailableGestures.none,
                focusedDay: _selectedDate,
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(Duration(days: 365)),
                calendarFormat: CalendarFormat.month,
                selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDate = selectedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: theme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle:
                      TextStyle(color: theme.colorScheme.onBackground),
                  weekendTextStyle: TextStyle(color: Colors.red),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleTextStyle: TextStyle(
                      color: theme.colorScheme.onSurface, fontSize: 16),
                  leftChevronIcon: Icon(Icons.chevron_left,
                      color: theme.colorScheme.onSurface),
                  rightChevronIcon: Icon(Icons.chevron_right,
                      color: theme.colorScheme.onSurface),
                ),
              ),
              SizedBox(height: 16),

              // Priority Selection
              Text(
                'Priority',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPriorityButton(1, 'High', Colors.red, theme),
                  _buildPriorityButton(2, 'Medium', Colors.orange, theme),
                  _buildPriorityButton(3, 'Low', Colors.green, theme),
                ],
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
                              isCompleted: false,
                              priority: _selectedPriority,
                              dueDate: _selectedDate,
                            ),
                          );
                    } else {
                      // Update existing task
                      ref.read(taskProvider.notifier).updateTask(
                            widget.task!.id!,
                            widget.task!.copyWith(
                              title: title,
                              description: description,
                              priority: _selectedPriority,
                              dueDate: _selectedDate,
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.task == null ? 'Add Task' : 'Save Changes',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build priority selection buttons
  Widget _buildPriorityButton(
      int priority, String label, Color color, ThemeData theme) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedPriority = priority;
        });
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: _selectedPriority == priority
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface,
        backgroundColor:
            _selectedPriority == priority ? color : theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label),
    );
  }
}
