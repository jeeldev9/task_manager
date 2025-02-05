import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../view_model/task_view_model.dart';
import '../view_model/user_preferences_view_model.dart'; // Import user preferences

// Define filter and sort options
enum TaskFilter { all, completed, pending }

enum TaskSort { dateAsc, dateDesc, priority, status }

class TaskListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access the current theme
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Watch user preferences
    final userPreferences = ref.watch(userPreferencesProvider);

    // Initialize taskFilterProvider with defaultFilter from userPreferences
    ref.listen(
      userPreferencesProvider,
      (previous, next) {
        ref.read(taskFilterProvider.notifier).state =
            _mapDefaultFilterToTaskFilter(next.defaultFilter);
        ref.read(taskSortProvider.notifier).state =
            _mapLabelToSort(next.sortOrder);
      },
    );

    // Watch selected filter and sort states
    final selectedFilter = ref.watch(taskFilterProvider);
    final selectedSort = ref.watch(taskSortProvider);
    final tasks = ref.watch(taskProvider);

    // Apply filter logic
    List<Task> filteredTasks = [];
    switch (selectedFilter) {
      case TaskFilter.all:
        filteredTasks = tasks;
        break;
      case TaskFilter.completed:
        filteredTasks = tasks.where((task) => task.isCompleted).toList();
        break;
      case TaskFilter.pending:
        filteredTasks = tasks.where((task) => !task.isCompleted).toList();
        break;
    }

    // Apply sort logic
    switch (selectedSort) {
      case TaskSort.dateAsc:
        filteredTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
      case TaskSort.dateDesc:
        filteredTasks.sort((b, a) => a.dueDate.compareTo(b.dueDate));
        break;
      case TaskSort.priority:
        filteredTasks.sort((a, b) =>
            b.priority.compareTo(a.priority)); // Higher priority first
        break;
      case TaskSort.status:
        filteredTasks.sort((a, b) => a.isCompleted ? 1 : -1); // Completed last
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tasks',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              _showFilterSortModal(context, ref);
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: filteredTasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/vectors/no_task_vector.png', // Replace with your own image asset
                    width: 250,
                    height: 250,
                    color: isDarkMode ? Colors.white.withOpacity(0.6) : null,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No tasks found',
                    style: TextStyle(
                        fontSize: 18, color: theme.colorScheme.onBackground),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                return _buildTaskCard(task, ref, context, theme);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-task');
        },
        child: Icon(Icons.add),
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 6,
      ),
    );
  }

  // Build a single task card
  Widget _buildTaskCard(
      Task task, WidgetRef ref, BuildContext context, ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.cardColor,
      child: InkWell(
        onTap: () {
          ref.read(taskProvider.notifier).toggleCompletion(task.id!);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                color: task.isCompleted
                    ? Colors.green
                    : theme.colorScheme.onSurface.withOpacity(0.6),
                size: 30,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16,
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.6)),
                        SizedBox(width: 4),
                        Text(
                          '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                          style: TextStyle(
                              fontSize: 12,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6)),
                        ),
                        SizedBox(width: 12),
                        Icon(Icons.flag,
                            size: 16, color: _getPriorityColor(task.priority)),
                        SizedBox(width: 4),
                        Text(
                          _getPriorityText(task.priority),
                          style: TextStyle(
                              fontSize: 12,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Delete Task',
                        style: TextStyle(color: Colors.black),
                      ),
                      content:
                          Text('Are you sure you want to delete this task?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel',
                              style: TextStyle(
                                  color: theme.colorScheme.onSurface)),
                        ),
                        TextButton(
                          onPressed: () {
                            ref
                                .read(taskProvider.notifier)
                                .deleteTask(task.id!);
                            Navigator.pop(context);
                          },
                          child: Text('Delete',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show filter and sort modal bottom sheet
  void _showFilterSortModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: TaskFilter.values.map((filter) {
                  final isSelected = ref.watch(taskFilterProvider) == filter;
                  return FilterChip(
                    label: Text(
                      _getFilterLabel(filter),
                      style: TextStyle(color: theme.colorScheme.onBackground),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      ref.read(taskFilterProvider.notifier).state = filter;
                      Navigator.pop(context);
                    },
                    selectedColor: theme.primaryColor.withOpacity(0.2),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              Text(
                'Sort',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: TaskSort.values.map((sort) {
                  final isSelected = ref.watch(taskSortProvider) == sort;
                  return FilterChip(
                    label: Text(
                      _getSortLabel(sort),
                      style: TextStyle(color: theme.colorScheme.onBackground),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      ref.read(taskSortProvider.notifier).state = sort;
                      print(sort.name);
                      Navigator.pop(context);
                    },
                    selectedColor: theme.primaryColor.withOpacity(0.2),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  TaskSort _mapLabelToSort(String label) {
    switch (label) {
      case 'Date (Ascending)':
        return TaskSort.dateAsc;
      case 'Date (Descending)':
        return TaskSort.dateDesc;
      case 'Priority':
        return TaskSort.priority;
      case 'Status':
        return TaskSort.status;
      default:
        return TaskSort.dateAsc; // Default value
    }
  }

  // Helper method to map defaultFilter to TaskFilter
  TaskFilter _mapDefaultFilterToTaskFilter(String defaultFilter) {
    switch (defaultFilter) {
      case 'all':
        return TaskFilter.all;
      case 'completed':
        return TaskFilter.completed;
      case 'pending':
        return TaskFilter.pending;
      default:
        return TaskFilter.all; // Default to 'All' if no match
    }
  }

  // Helper method to get filter label
  String _getFilterLabel(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return 'All';
      case TaskFilter.completed:
        return 'Completed';
      case TaskFilter.pending:
        return 'Pending';
    }
  }

  // Helper method to get sort label
  String _getSortLabel(TaskSort sort) {
    switch (sort) {
      case TaskSort.dateAsc:
        return 'Date (Ascending)';
      case TaskSort.dateDesc:
        return 'Date (Descending)';
      case TaskSort.priority:
        return 'Priority';
      case TaskSort.status:
        return 'Status';
    }
  }

  // Helper method to get priority color
  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red; // High priority
      case 2:
        return Colors.orange; // Medium priority
      case 3:
        return Colors.green; // Low priority
      default:
        return Colors.grey;
    }
  }

  // Helper method to get priority text
  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'High';
      case 2:
        return 'Medium';
      case 3:
        return 'Low';
      default:
        return 'Unknown';
    }
  }
}

// Riverpod providers for managing filter and sort states
final taskFilterProvider = StateProvider((ref) => _mapDefaultFilterToTaskFilter(
    ref.watch(userPreferencesProvider).defaultFilter));
final taskSortProvider = StateProvider((ref) =>
    _mapDefaultSortToTaskSort(ref.watch(userPreferencesProvider).sortOrder));

// Helper method to map defaultFilter to TaskFilter
TaskFilter _mapDefaultFilterToTaskFilter(String defaultFilter) {
  switch (defaultFilter) {
    case 'all':
      return TaskFilter.all;
    case 'completed':
      return TaskFilter.completed;
    case 'pending':
      return TaskFilter.pending;
    default:
      return TaskFilter.all; // Default to 'All' if no match
  }
}

// Helper method to map sortOrder to TaskSort
TaskSort _mapDefaultSortToTaskSort(String sortOrder) {
  switch (sortOrder) {
    case 'Date (Ascending)':
      return TaskSort.dateAsc;
    case 'Date (Descending)':
      return TaskSort.dateDesc;
    case 'Priority':
      return TaskSort.priority;
    case 'Status':
      return TaskSort.status;
    default:
      return TaskSort.dateAsc; // Default to 'Date Ascending' if no match
  }
}
