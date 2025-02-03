import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../views/add_edit_task_view.dart';
import '../views/setting_view.dart';
import '../views/task_list_view.dart';

final appRoutes = {
  '/': (context) => TaskListScreen(),
  '/add-task': (context) => AddEditTaskScreen(),
  '/edit-task': (context) => AddEditTaskScreen(
      task: ModalRoute.of(context)!.settings.arguments as Task),
  '/settings': (context) => SettingsScreen(),
};
