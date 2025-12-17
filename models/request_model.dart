enum RequestStatus { pending, approved, rejected }

class RequestModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final DateTime createdAt;
  final RequestStatus status;
  final String? adminComment;

  RequestModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.createdAt,
    required this.status,
    this.adminComment,
  });

  // Convert JSON to RequestModel
  factory RequestModel.fromJson(Map<String, dynamic> json) {
    // Safe parsing for status field
    final statusIndex = json['status'];
    RequestStatus status = RequestStatus.pending; // Default to 'pending' in case of invalid status index

    if (statusIndex != null && statusIndex >= 0 && statusIndex < RequestStatus.values.length) {
      status = RequestStatus.values[statusIndex];
    }

    return RequestModel(
      id: json['id'],
      userId: json['userId'],
      type: json['type'],
      title: json['title'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      reason: json['reason'],
      createdAt: DateTime.parse(json['createdAt']),
      status: status,
      adminComment: json['adminComment'],
    );
  }

  // Convert RequestModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'reason': reason,
      'createdAt': createdAt.toIso8601String(),
      'status': status.index, // Store the index of the status enum
      'adminComment': adminComment,
    };
  }
}