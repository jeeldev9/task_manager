import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/user_preferences_view_model.dart';

class SettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access the current theme
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Watch user preferences
    final userPreferences = ref.watch(userPreferencesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title: Appearance
            Text(
              'Appearance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            SizedBox(height: 8),

            // Dark Mode Toggle
            ListTile(
              title: Text(
                'Dark Mode',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              subtitle: Text(
                'Enable dark mode for better visibility in low light.',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
              trailing: Switch(
                value: userPreferences.isDarkMode,
                onChanged: (value) {
                  ref.read(userPreferencesProvider.notifier).toggleTheme();
                },
                activeColor: theme.primaryColor,
                activeTrackColor: theme.primaryColor.withOpacity(0.5),
                inactiveThumbColor: theme.colorScheme.secondary,
                inactiveTrackColor:
                    theme.colorScheme.secondary.withOpacity(0.3),
              ),
            ),
            Divider(),

            // Section Title: Task Management
            Text(
              'Task Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            SizedBox(height: 8),

            // Default Sort Order
            ListTile(
              title: Text(
                'Default Sort Order',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              subtitle: Text(
                'Set the default order for tasks.',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
              trailing: DropdownButton<String>(
                value: userPreferences.sortOrder ??
                    'date ascending', // Ensure a default value
                onChanged: (value) {
                  ref
                      .read(userPreferencesProvider.notifier)
                      .setSortOrder(value!);
                },
                items: [
                  'date ascending',
                  'date descending',
                  'priority',
                  'status'
                ].map((option) {
                  return DropdownMenuItem<String>(
                    value: option, // Use the raw value
                    child: Text(
                      option.capitalize(), // Display capitalized text
                      style: TextStyle(color: theme.colorScheme.onBackground),
                    ),
                  );
                }).toList(),
                underline: SizedBox(), // Remove underline
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: theme.colorScheme.onBackground,
                ),
                dropdownColor: isDarkMode ? Colors.grey[900] : Colors.white,
              ),
            ),

            // Default Filter
            ListTile(
              title: Text(
                'Default Filter',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              subtitle: Text(
                'Set the default filter for tasks.',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
              trailing: DropdownButton<String>(
                value: userPreferences.defaultFilter ??
                    'all', // Ensure a default value
                onChanged: (value) {
                  ref
                      .read(userPreferencesProvider.notifier)
                      .setDefaultFilter(value!);
                },
                items: ['all', 'completed', 'pending'].map((option) {
                  return DropdownMenuItem<String>(
                    value: option, // Use the raw value
                    child: Text(
                      option.capitalize(), // Display capitalized text
                      style: TextStyle(color: theme.colorScheme.onBackground),
                    ),
                  );
                }).toList(),
                underline: SizedBox(), // Remove underline
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: theme.colorScheme.onBackground,
                ),
                dropdownColor: isDarkMode ? Colors.grey[900] : Colors.white,
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
