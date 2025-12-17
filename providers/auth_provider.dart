import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

/// Types of auth errors we want to distinguish in the UI.
enum AuthErrorType {
  timeout,
  network,
  invalidCredentials,
  unknown,
}

/// Custom exception used by AuthProvider.
class AuthException implements Exception {
  final AuthErrorType type;
  final String message;

  const AuthException(this.type, this.message);

  @override
  String toString() => 'AuthException($type, $message)';
}

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  String _userId = '';

  bool get isAuthenticated => _isAuthenticated;
  String get userId => _userId;
  String? get token => _token;

  static const String baseUrl = 'http://cloud.kaytechnology.com:1022/HRPERFECT';

  final Logger _logger = Logger();

  Future<bool> login(String login, String password) async {
    final url = Uri.parse('$baseUrl/rhapi.do?do=authentificationMobile');

    _logger.i('💡 Attempting to login with email/username: $login');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'login': login,
              'pwd': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      _logger.i('🔁 Login status: ${response.statusCode}');
      _logger.i('🔁 Login body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Adjust this depending on your real API response structure
        final success =
            data['success'] == true || data['statut'] == 'OK' || data['ok'] == true;

        if (!success) {
          _setLoggedOut();
          throw const AuthException(
            AuthErrorType.invalidCredentials,
            'Invalid login or password',
          );
        }

        _userId = (data['matricule'] ?? '').toString();
        _token = data['token']?.toString();

        _isAuthenticated = true;
        notifyListeners();
        return true;
      }

      if (response.statusCode == 401) {
        _setLoggedOut();
        throw const AuthException(
          AuthErrorType.invalidCredentials,
          'Invalid login or password',
        );
      }

      _setLoggedOut();
      throw AuthException(
        AuthErrorType.unknown,
        'Server error: ${response.statusCode}',
      );
    } on TimeoutException catch (e) {
      _logger.e('⛔ Login timeout: $e');
      _setLoggedOut();
      throw const AuthException(
        AuthErrorType.timeout,
        'Login request timed out',
      );
    } on SocketException catch (e) {
      _logger.e('🌐 Network error: $e');
      _setLoggedOut();
      throw const AuthException(
        AuthErrorType.network,
        'Network error. Please check your internet connection or firewall settings.',
      );
    } catch (e) {
      _logger.e('❌ Unexpected login error: $e');
      _setLoggedOut();
      throw AuthException(
        AuthErrorType.unknown,
        'Unexpected login error: $e',
      );
    }
  }

  void _setLoggedOut() {
    _isAuthenticated = false;
    _token = null;
    _userId = '';
    notifyListeners();
  }

  void logout() => _setLoggedOut();
}
