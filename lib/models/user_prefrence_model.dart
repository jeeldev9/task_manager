import 'package:hive/hive.dart';

// Declare the part file for the generated adapter
part 'user_prefrence_model.g.dart'; // This will be generated

@HiveType(typeId: 0) // Unique typeId for this model
class UserPreferences {
  @HiveField(0)
  final bool isDarkMode;

  @HiveField(1)
  final String sortOrder;

  UserPreferences({
    this.isDarkMode = false,
    this.sortOrder = 'date', // Default sort order
  });

  // Factory constructor for Hive deserialization
  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      isDarkMode: map['isDarkMode'] ?? false,
      sortOrder: map['sortOrder'] ?? 'date',
    );
  }

  // Convert to Map for Hive serialization
  Map<String, dynamic> toMap() {
    return {
      'isDarkMode': isDarkMode,
      'sortOrder': sortOrder,
    };
  }

  // CopyWith Method
  UserPreferences copyWith({
    bool? isDarkMode,
    String? sortOrder,
  }) {
    return UserPreferences(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
