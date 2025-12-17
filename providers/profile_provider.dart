import 'package:flutter/foundation.dart';

/// Simple model for the logged-in employee profile.
class EmployeeProfile {
  final String userId;
  final String name;
  final String email;
  final String? phone;
  final String? department;
  final String? imagePath; // Optional local path to avatar

  EmployeeProfile({
    required this.userId,
    required this.name,
    required this.email,
    this.phone,
    this.department,
    this.imagePath,
  });

  // Copy method for creating a modified copy of the profile.
  EmployeeProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? department,
    String? imagePath,
  }) {
    return EmployeeProfile(
      userId: userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

/// Holds the profile of the **current logged-in employee**
class ProfileProvider extends ChangeNotifier {
  EmployeeProfile? _profile;

  /// Get the profile for the current user (we ignore userId because the app manages only one at a time)
  EmployeeProfile? getProfile() => _profile;

  /// Optionally set the initial profile (e.g., after login)
  void setInitialProfile(EmployeeProfile profile) {
    _profile = profile;
    notifyListeners();
  }

  /// Update or create the profile for the current user
  void updateProfile({
    required String userId,
    required String name,
    required String email,
    String? phone,
    String? department,
    String? imagePath,
  }) {
    final existing = _profile;

    // If no profile exists, create a new one.
    if (existing == null) {
      _profile = EmployeeProfile(
        userId: userId,
        name: name,
        email: email,
        phone: phone,
        department: department,
        imagePath: imagePath,
      );
    } else {
      // Update existing profile with the new data.
      _profile = existing.copyWith(
        name: name,
        email: email,
        phone: phone,
        department: department,
        imagePath: imagePath ?? existing.imagePath,
      );
    }

    // Notify listeners to trigger UI updates
    notifyListeners();
  }

  // Method to clear the current profile (e.g., on logout)
  void clearProfile() {
    _profile = null;
    notifyListeners();
  }
}