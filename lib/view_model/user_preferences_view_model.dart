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
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      if (!Hive.isBoxOpen('userPreferences')) {
        await Hive.openBox<UserPreferences>('userPreferences');
      }
      _box = Hive.box<UserPreferences>('userPreferences');
      final preferences = _box.get('preferences') ?? UserPreferences();
      state = preferences;
    } catch (e) {
      print('Error initializing user preferences: $e');
    }
  }

  Future<void> toggleTheme() async {
    try {
      final updatedPreferences = state.copyWith(isDarkMode: !state.isDarkMode);
      state = updatedPreferences;
      await _box.put('preferences', updatedPreferences);
    } catch (e) {
      print('Error toggling theme: $e');
    }
  }

  Future<void> setSortOrder(String sortOrder) async {
    try {
      final updatedPreferences = state.copyWith(sortOrder: sortOrder);
      state = updatedPreferences;
      await _box.put('preferences', updatedPreferences);
    } catch (e) {
      print('Error setting sort order: $e');
    }
  }

  Future<void> setDefaultFilter(String filter) async {
    try {
      final updatedPreferences = state.copyWith(defaultFilter: filter);
      state = updatedPreferences;
      await _box.put('preferences', updatedPreferences);
    } catch (e) {
      print('Error setting default filter: $e');
    }
  }
}
