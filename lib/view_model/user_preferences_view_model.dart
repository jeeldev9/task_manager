import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/user_prefrence_model.dart';

final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesViewModel, UserPreferences>((ref) {
  return UserPreferencesViewModel();
});

class UserPreferencesViewModel extends StateNotifier<UserPreferences> {
  late final Box<UserPreferences> _box;

  UserPreferencesViewModel() : super(UserPreferences()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _box = Hive.box<UserPreferences>('userPreferences');
    final preferences = _box.get('preferences') ?? UserPreferences();
    state = preferences;
  }

  Future<void> toggleTheme() async {
    final updatedPreferences = state.copyWith(isDarkMode: !state.isDarkMode);
    state = updatedPreferences;
    await _box.put('preferences', updatedPreferences);
  }

  Future<void> setSortOrder(String sortOrder) async {
    final updatedPreferences = state.copyWith(sortOrder: sortOrder);
    state = updatedPreferences;
    await _box.put('preferences', updatedPreferences);
  }
}
