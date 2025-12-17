import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/request_model.dart';
import '../../providers/request_provider.dart';
import '../../widgets/app_text_field.dart';

class RequestFormScreen extends StatefulWidget {
  final String userId;
  final String type; // "leave", "exit", "att", "mission"

  const RequestFormScreen({
    super.key,
    required this.userId,
    required this.type,
  });

  @override
  State<RequestFormScreen> createState() => RequestFormScreenState();
}

// Made this class public (no underscore) to avoid library_private_types_in_public_api lint
class RequestFormScreenState extends State<RequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = now;
    _endDate = now.add(const Duration(days: 1));
    _startDateController.text = _formatDate(_startDate!);
    _endDateController.text = _formatDate(_endDate!);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day/$month/${d.year}';
  }

  String _mapType() {
    switch (widget.type) {
      case 'leave':
        return 'leave';
      case 'exit':
        return 'exit';
      case 'att':
      case 'attestation':
        return 'attestation';
      case 'mission':
      default:
        return 'mission';
    }
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (selected != null) {
      setState(() {
        _startDate = selected;
        _startDateController.text = _formatDate(selected);
        if (_endDate == null || _endDate!.isBefore(selected)) {
          _endDate = selected;
          _endDateController.text = _formatDate(selected);
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final base = _startDate ?? DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _endDate ?? base,
      firstDate: base,
      lastDate: DateTime(base.year + 2),
    );
    if (selected != null) {
      setState(() {
        _endDate = selected;
        _endDateController.text = _formatDate(selected);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final provider = Provider.of<RequestProvider>(context, listen: false);
      final uuid = const Uuid();

      final request = RequestModel(
        id: uuid.v4(),
        userId: widget.userId,
        type: _mapType(),
        title: _screenTitle,
        startDate: _startDate!,
        endDate: _endDate!,
        reason: _reasonController.text.trim(),
        createdAt: DateTime.now(),
        status: RequestStatus.pending,
        adminComment: null,
      );

      // Sending the request data to your API
      final response = await _sendRequestToAPI(request);

      if (response['success'] == true) {
        provider.addRequest(request);

        if (!mounted) return;
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request submitted successfully')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response['message']}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error while submitting: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  String get _screenTitle {
    switch (widget.type) {
      case 'leave':
        return 'Leave request';
      case 'exit':
        return 'Exit authorization';
      case 'att':
      case 'attestation':
        return 'Attestation request';
      case 'mission':
      default:
        return 'Mission request';
    }
  }

  Future<Map<String, dynamic>> _sendRequestToAPI(RequestModel request) async {
    final url = 'http://cloud.kaytechnology.com:1022/HRPERFECT/rhapi.do?do=addConges'; // Replace with your API URL

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'libelle': request.reason,
        'dateDebut': _formatDate(request.startDate),
        'dateFin': _formatDate(request.endDate),
        'ttjourneDebut': 'tout',
        'ttjourneFin': 'tout',
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Assuming success or failure data in JSON response
    } else {
      return {'success': false, 'message': 'Failed to submit request'};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF111827),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _screenTitle,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 22),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  AppTextField(
                    controller: _reasonController,
                    label: 'Reason',
                    hint: 'Describe your request briefly',
                    icon: Icons.notes_outlined,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a reason';
                      }
                      if (value.trim().length < 5) {
                        return 'Please provide a bit more detail';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _startDateController,
                          label: 'Start date',
                          hint: 'Select start date',
                          icon: Icons.calendar_today_outlined,
                          readOnly: true,
                          onTap: _pickStartDate,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          controller: _endDateController,
                          label: 'End date',
                          hint: 'Select end date',
                          icon: Icons.calendar_today_outlined,
                          readOnly: true,
                          onTap: _pickEndDate,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E5A0),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Submit request',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF00E5A0), Color(0xFF00C6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5A0).withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.send_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New request',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fill in the information below to submit your request.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}