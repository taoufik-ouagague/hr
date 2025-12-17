import 'package:flutter/material.dart';
import '../models/request_model.dart';

class StatusBadge extends StatelessWidget {
  final RequestStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    late Color c;
    late String t;

    switch (status) {
      case RequestStatus.pending:
        c = Colors.orange;
        t = "Pending";
        break;
      case RequestStatus.approved:
        c = Colors.green;
        t = "Approved";
        break;
      default:
        c = Colors.red;
        t = "Rejected";
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        t,
        style: TextStyle(color: c, fontWeight: FontWeight.bold),
      ),
    );
  }
}
