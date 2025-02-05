import 'package:hive/hive.dart';
part 'user_prefrence_model.g.dart';

@HiveType(typeId: 0)
class UserPreferences {
  @HiveField(0)
  final bool isDarkMode;

  @HiveField(1)
  final String sortOrder;

  @HiveField(2)
  final String defaultFilter;

  UserPreferences({
    this.isDarkMode = false,
    this.sortOrder = 'Date (Ascending)', // Default sort order
    this.defaultFilter = 'all', // Default filter
  });

  Map<String, dynamic> toMap() {
    return {
      'isDarkMode': isDarkMode,
      'sortOrder': sortOrder,
      'defaultFilter': defaultFilter,
    };
  }

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      isDarkMode: map['isDarkMode'] ?? false,
      sortOrder: map['sortOrder'] ?? 'Date (Ascending)',
      defaultFilter: map['defaultFilter'] ?? 'all',
    );
  }

  UserPreferences copyWith({
    bool? isDarkMode,
    String? sortOrder,
    String? defaultFilter,
  }) {
    return UserPreferences(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      sortOrder: sortOrder ?? this.sortOrder,
      defaultFilter: defaultFilter ?? this.defaultFilter,
    );
  }
}
