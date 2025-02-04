import 'package:hive/hive.dart';
import 'package:intl/intl.dart'; // For formatting dates

part 'task_model.g.dart'; // Generated file for Hive adapter

@HiveType(typeId: 1) // Unique typeId for Task
class Task {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final bool isCompleted;

  @HiveField(4) // Add this field for priority (1 = High, 2 = Medium, 3 = Low)
  final int priority;

  @HiveField(5) // Add this field for due date
  final DateTime dueDate;

  Task({
    this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.priority = 3, // Default priority is "Low"
    required this.dueDate, // Due date is required
  });

  // Convert Task object to a Map (for SQLite or Hive serialization)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0, // SQLite stores booleans as integers
      'priority': priority, // Add priority to the map
      'dueDate': dueDate.toIso8601String(), // Store due date as ISO string
    };
  }

  // Create a Task object from a Map (for SQLite or Hive deserialization)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1, // Convert integer back to boolean
      priority: map['priority'], // Extract priority
      dueDate: DateTime.parse(map['dueDate']), // Parse due date from ISO string
    );
  }

  // CopyWith Method
  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    int? priority, // Add priority to copyWith
    DateTime? dueDate, // Add dueDate to copyWith
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority, // Update priority
      dueDate: dueDate ?? this.dueDate, // Update dueDate
    );
  }

  // Helper method to format due date for display
  String get formattedDueDate {
    return DateFormat('dd/MM/yyyy').format(dueDate); // Format as "DD/MM/YYYY"
  }
}
