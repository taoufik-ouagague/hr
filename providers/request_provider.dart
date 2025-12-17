import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/request_model.dart';

/// Central store for employee requests.
class RequestProvider extends ChangeNotifier {
  final List<RequestModel> _requests = [];

  /// All requests for the employee.
  List<RequestModel> get allRequests => List.unmodifiable(_requests);

  /// Requests only for a specific user (employee side).
  List<RequestModel> forUser(String userId) {
    return _requests
        .where((r) => r.userId.toLowerCase() == userId.toLowerCase())
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));  // Sort by createdAt
  }

  /// Add a new request (used in RequestFormScreen).
  Future<void> addRequest(RequestModel request) async {
    final url = Uri.parse('https://your-api-endpoint/requests');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 201) {
        _requests.add(request);
        notifyListeners();
      } else {
        throw Exception('Failed to add request');
      }
    } catch (error) {
      rethrow; // To handle errors in UI components
    }
  }

  /// Update an existing request.
  Future<void> updateRequest(RequestModel updated) async {
    final url = Uri.parse('https://your-api-endpoint/requests/${updated.id}');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updated.toJson()),
      );

      if (response.statusCode == 200) {
        final index = _requests.indexWhere((r) => r.id == updated.id);
        if (index != -1) {
          _requests[index] = updated;
          notifyListeners();
        }
      } else {
        throw Exception('Failed to update request');
      }
    } catch (error) {
      rethrow;
    }
  }

  /// Delete a request.
  Future<void> deleteRequest(String requestId) async {
    final url = Uri.parse('https://your-api-endpoint/requests/$requestId');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        _requests.removeWhere((r) => r.id == requestId);
        notifyListeners();
      } else {
        throw Exception('Failed to delete request');
      }
    } catch (error) {
      rethrow;
    }
  }

  /// Fetch all requests for the employee from the API.
  Future<void> fetchRequests(String userId) async {
    final url = Uri.parse('https://your-api-endpoint/requests?userId=$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        _requests.clear();
        _requests.addAll(
          responseData.map((data) => RequestModel.fromJson(data)).toList(),
        );
        notifyListeners();
      } else {
        throw Exception('Failed to load requests');
      }
    } catch (error) {
      rethrow;
    }
  }

  /// Example helper function for getting pending requests (optional).
  int get pendingRequests {
    return _requests.where((r) => r.status == RequestStatus.pending).length;
  }
}
