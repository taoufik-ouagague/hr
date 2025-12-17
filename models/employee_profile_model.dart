class EmployeeProfile {
  String name;
  String email;
  String phone;
  String department;
  String position;
  String? photoPath; // Optional path for the profile image

  EmployeeProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.department,
    required this.position,
    this.photoPath,
  });

  // Convert the EmployeeProfile object to JSON
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "phone": phone,
      "department": department,
      "position": position,
      "photoPath": photoPath, // Can be null
    };
  }

  // Create an EmployeeProfile object from JSON
  factory EmployeeProfile.fromJson(Map<String, dynamic> json) {
    return EmployeeProfile(
      name: json["name"] ?? "", // Default to empty string if null
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      department: json["department"] ?? "",
      position: json["position"] ?? "",
      photoPath: json["photoPath"], // This can be null
    );
  }
}
