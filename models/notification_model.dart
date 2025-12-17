enum NotificationStatus { pending, approved, rejected }

class NotificationModel {
  final String employeeId;
  final String employeeName;
  final String profileImageUrl;
  final String requestType;
  final DateTime submissionTime;
  final NotificationStatus status; // Status as enum

  NotificationModel({
    required this.employeeId,
    required this.employeeName,
    required this.profileImageUrl,
    required this.requestType,
    required this.submissionTime,
    required this.status,
  });

  // Convert JSON to NotificationModel
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Safely parse the status from the string
    NotificationStatus status = NotificationStatus.pending;
    if (json['status'] != null) {
      try {
        status = NotificationStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'],
          orElse: () => NotificationStatus.pending, // Default to 'pending'
        );
      } catch (e) {
        status = NotificationStatus.pending; // Default to 'pending' if error occurs
      }
    }

    return NotificationModel(
      employeeId: json['employeeId'],
      employeeName: json['employeeName'],
      profileImageUrl: json['profileImageUrl'],
      requestType: json['requestType'],
      submissionTime: DateTime.parse(json['submissionTime']),
      status: status,
    );
  }

  // Convert NotificationModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'employeeName': employeeName,
      'profileImageUrl': profileImageUrl,
      'requestType': requestType,
      'submissionTime': submissionTime.toIso8601String(),
      'status': status.toString().split('.').last, // Convert status to string
    };
  }
}
