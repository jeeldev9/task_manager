import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';
import '../models/user_prefrence_model.dart';

/// Initializes Hive and sets up adapters and boxes.
Future<void> initializeHive() async {
  try {
    // Initialize Hive
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(UserPreferencesAdapter());

    // Open the required boxes
    await Hive.openBox<Task>('tasks');
    await Hive.openBox<UserPreferences>('userPreferences');

    print('Hive initialized successfully.');
  } catch (e) {
    // Handle initialization errors
    print('Error initializing Hive: $e');
  }
}
