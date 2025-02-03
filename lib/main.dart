import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/services/hive_integration.dart';
import 'package:task_manager/view_model/user_preferences_view_model.dart';

import 'app/routes.dart';
import 'app/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeHive(); // Initialize Hive
  runApp(
    ProviderScope(
      // Wrap your app with ProviderScope
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the user preferences state
    final userPreferences = ref.watch(userPreferencesProvider);

    return MaterialApp(
      title: 'Task Manager',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: userPreferences.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      routes: appRoutes,
    );
  }
}
