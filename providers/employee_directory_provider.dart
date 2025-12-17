import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Employee User Model for Directory
class EmployeeUser {
  final String id;
  final String name;
  final String email;
  final String department;
  final String password; // Insecure for demo apps, hash passwords in real apps

  EmployeeUser({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.password,
  });

  /// Convert EmployeeUser to JSON for storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'department': department,
        'password': password,
      };

  /// Create EmployeeUser from JSON
  factory EmployeeUser.fromJson(Map<String, dynamic> json) => EmployeeUser(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        department: json['department'] as String? ?? '',
        password: json['password'] as String? ?? '',
      );
}

class EmployeeDirectoryProvider extends ChangeNotifier {
  static const _storageKey = 'employees_directory'; // Key to store the list in SharedPreferences

  final List<EmployeeUser> _employees = [];

  List<EmployeeUser> get employees => List.unmodifiable(_employees);

  // Constructor to load data on initialization
  EmployeeDirectoryProvider() {
    _load();
  }

  /// Load employee data from SharedPreferences
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;

    try {
      final List<dynamic> data = json.decode(raw);
      _employees.clear();
      _employees.addAll(
        data.map((e) => EmployeeUser.fromJson(e as Map<String, dynamic>)),
      );
      notifyListeners();
    } catch (_) {
      // Ignore parse errors, e.g., malformed data
    }
  }

  /// Save employee data to SharedPreferences
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(_employees.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  /// Add a new employee to the directory
  Future<void> addEmployee({
    required String name,
    required String email,
    required String department,
    required String password,
  }) async {
    final user = EmployeeUser(
      id: const Uuid().v4(),
      name: name.trim(),
      email: email.trim(),
      department: department.trim(),
      password: password, // Make sure to hash this password in production apps
    );
    _employees.add(user);
    await _save();
    notifyListeners();
  }

  /// Remove an employee from the directory by ID
  Future<void> removeEmployee(String id) async {
    _employees.removeWhere((e) => e.id == id);
    await _save();
    notifyListeners();
  }

  /// Check if an employee already exists by email (ignores case and spaces)
  bool existsByEmail(String email) {
    final lower = email.toLowerCase().trim();
    return _employees.any(
      (e) => e.email.toLowerCase().trim() == lower,
    );
  }

  /// Validate employee credentials (email and password match)
  bool validateCredentials(String email, String password) {
    final lower = email.toLowerCase().trim();
    return _employees.any(
      (e) =>
          e.email.toLowerCase().trim() == lower &&
          e.password == password,  // In production, hash passwords for security
    );
  }

  /// Fetch employee by ID
  /// Fetch employee by ID
EmployeeUser? getEmployeeById(String id) {
  // If employee not found, return null or throw an exception
  return _employees.firstWhere(
    (e) => e.id == id,
    orElse: () => throw Exception('Employee not found'),
  );
}

}