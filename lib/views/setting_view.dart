import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view_model/user_preferences_view_model.dart';

class SettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPreferences = ref.watch(userPreferencesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Toggle
            ListTile(
              title: Text('Dark Mode'),
              trailing: Switch(
                value: userPreferences.isDarkMode,
                onChanged: (value) {
                  ref.read(userPreferencesProvider.notifier).toggleTheme();
                },
              ),
            ),

            // Divider
            Divider(),

            // Sort Order Dropdown
            Text(
              'Default Sort Order',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButton<String>(
              value: userPreferences.sortOrder,
              isExpanded: true,
              items: ['date', 'priority', 'title']
                  .map((order) => DropdownMenuItem(
                        value: order,
                        child: Text(order.capitalize()),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(userPreferencesProvider.notifier)
                      .setSortOrder(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
