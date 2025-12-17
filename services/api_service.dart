import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://cloud.kaytechnology.com:1022/HRPERFECT/'; // Your base URL

  // Login API
  Future<bool> login(String email, String password) async {
    final apiUrl = Uri.parse('$baseUrl/rhapi.do?do=authentificationMobile');
    
    try {
      final response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'login': email, 'pwd': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['MSG'] == 'Identifiant ou mot de passe invalide !!') {
          return false;  // Invalid credentials
        } else {
          // Successfully logged in
          return true;
        }
      } else {
        // Handle non-200 status codes
        return false;
      }
    } catch (e) {
      print('Error during login: $e');
      return false;
    }
  }

  // Fetching the list of requests (for notifications)
  Future<List<dynamic>> fetchRequests(String userId) async {
    final apiUrl = Uri.parse('$baseUrl/rhapi.do?do=mesConges'); // Example API for fetching requests (you can change based on your needs)
    
    try {
      final response = await http.get(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;  // Returns the list of requests
      } else {
        return [];  // Returns an empty list if the request fails
      }
    } catch (e) {
      print('Error fetching requests: $e');
      return [];  // Returns an empty list in case of an error
    }
  }

  // Sending a request (e.g., applying for leave)
  Future<bool> sendRequest(String type, DateTime startDate, DateTime endDate, String reason) async {
    final apiUrl = Uri.parse('$baseUrl/rhapi.do?do=addConges'); // Modify according to your endpoint
    try {
      final response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'libelle': reason,
          'dateDebut': startDate.toIso8601String(),
          'dateFin': endDate.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['MSG'] == 'Demande de congé ajouté.') {
          return true;  // Request successfully sent
        } else {
          return false;  // If the request was not successful
        }
      } else {
        return false;  // Handle non-200 status codes
      }
    } catch (e) {
      print('Error sending request: $e');
      return false;  // Error occurred
    }
  }

  // Fetch notifications
  Future<List<dynamic>> fetchNotifications(String userId) async {
    final apiUrl = Uri.parse('$baseUrl/rhapi.do?do=mesConges'); // Change based on actual notifications endpoint
    try {
      final response = await http.get(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;  // Return notifications data
      } else {
        return [];  // Return empty list if error occurs
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];  // Return empty list in case of an error
    }
  }

  // Fetch additional data, for example, leave types
  Future<List<dynamic>> fetchLeaveTypes() async {
    final apiUrl = Uri.parse('$baseUrl/rhapi.do?do=getTypesAttestations');
    try {
      final response = await http.get(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;  // Return leave types
      } else {
        return [];  // Return empty list if error occurs
      }
    } catch (e) {
      print('Error fetching leave types: $e');
      return [];  // Return empty list in case of an error
    }
  }
}
