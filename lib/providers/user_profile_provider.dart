import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String name;
  final String age;
  final String bio;
  final String goal;
  final String? imagePath;

  const UserProfile({
    this.name = '',
    this.age = '',
    this.bio = '',
    this.goal = '',
    this.imagePath,
  });

  UserProfile copyWith({
    String? name,
    String? age,
    String? bio,
    String? goal,
    String? imagePath,
    bool clearImage = false,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      bio: bio ?? this.bio,
      goal: goal ?? this.goal,
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier() : super(const UserProfile()) {
    _load();
  }

  static const _keyName = 'profile_name';
  static const _keyAge = 'profile_age';
  static const _keyBio = 'profile_bio';
  static const _keyGoal = 'profile_goal';
  static const _keyImage = 'profile_image';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = UserProfile(
      name: prefs.getString(_keyName) ?? '',
      age: prefs.getString(_keyAge) ?? '',
      bio: prefs.getString(_keyBio) ?? '',
      goal: prefs.getString(_keyGoal) ?? '',
      imagePath: prefs.getString(_keyImage),
    );
  }

  Future<void> saveProfile({
    required String name,
    required String age,
    required String bio,
    required String goal,
    String? imagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyAge, age);
    await prefs.setString(_keyBio, bio);
    await prefs.setString(_keyGoal, goal);

    final finalImagePath = imagePath ?? state.imagePath;
    if (finalImagePath != null) {
      await prefs.setString(_keyImage, finalImagePath);
    }

    state = UserProfile(
      name: name,
      age: age,
      bio: bio,
      goal: goal,
      imagePath: finalImagePath,
    );
  }

  Future<void> setImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyImage, path);
    state = state.copyWith(imagePath: path);
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>(
  (ref) => UserProfileNotifier(),
);
