import 'package:hive_flutter/hive_flutter.dart';

import '../models/task_model.dart';
import '../models/user_prefrence_model.dart';

Future<void> initializeHive() async {
  await Hive.initFlutter(); // Initialize Hive
// Register adapters
  Hive.registerAdapter(TaskAdapter());

  // Open the required boxes
  await Hive.openBox<Task>('tasks');
  // Register the adapter
  Hive.registerAdapter(UserPreferencesAdapter());

  // Open the box
  await Hive.openBox<UserPreferences>('userPreferences');
}
