import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:hr_perfect/screens/employee/explore_screen.dart';
import 'package:hr_perfect/screens/employee/shop_screen.dart';
import 'package:hr_perfect/screens/notification_screen.dart';

import '../../models/request_model.dart';
import '../../providers/request_provider.dart';
import 'request_form_screen.dart';
import 'request_history_screen.dart';
import 'employee_profile_screen.dart';

class EmployeeHome extends StatefulWidget {
  final String userId; // usually the email
  const EmployeeHome({super.key, required this.userId});

  @override
  State<EmployeeHome> createState() => _EmployeeHomeState();
}

class _EmployeeHomeState extends State<EmployeeHome> {
  int _index = 0;

  String _formatDisplayName(String rawId) {
    String base = rawId.trim();

    if (base.contains('@')) {
      base = base.split('@').first;
    }

    final parts = base.split(RegExp(r'[._\-]+'));
    final cleaned = parts.where((p) => p.trim().isNotEmpty).toList();
    if (cleaned.isEmpty) return rawId;

    return cleaned
        .map((p) => p[0].toUpperCase() + p.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final requests =
        context.watch<RequestProvider>().forUser(widget.userId);

    final int total = requests.length;
    final int pending =
        requests.where((r) => r.status == RequestStatus.pending).length;
    final int approved =
        requests.where((r) => r.status == RequestStatus.approved).length;

    final pages = [
      _dashboard(context, total, pending, approved),
      RequestHistoryScreen(userId: widget.userId),
      EmployeeProfileScreen(userId: widget.userId),
      const ExploreScreen(),
      const ShopScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: const Color(0xFF00C6FF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.dashboard_outlined,
              color: _index == 0 ? const Color(0xFF00C6FF) : Colors.grey,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.history,
              color: _index == 1 ? const Color(0xFF00C6FF) : Colors.grey,
            ),
            label: "Requests",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
              color: _index == 2 ? const Color(0xFF00C6FF) : Colors.grey,
            ),
            label: "Profile",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.explore,
              color: _index == 3 ? const Color(0xFF00C6FF) : Colors.grey,
            ),
            label: "Explore",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.shopping_cart_outlined,
              color: _index == 4 ? const Color(0xFF00C6FF) : Colors.grey,
            ),
            label: "Shop",
          ),
        ],
      ),
    );
  }

  Widget _dashboard(
    BuildContext context,
    int total,
    int pending,
    int approved,
  ) {
    final displayName = _formatDisplayName(widget.userId);

    return Stack(
      children: [
        // Top gradient wave (same style philosophy as Login / Request form)
        Align(
          alignment: Alignment.topCenter,
          child: ClipPath(
            clipper: _TopWaveClipper(),
            child: Container(
              height: 220,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00E5A0), Color(0xFF00C6FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ),

        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: greeting + notification icon (sitting on the gradient)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome back,",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            displayName,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // White stats card "floating" under the gradient
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _statPill(
                        label: "Total",
                        value: total.toString(),
                        color: const Color(0xFF0072FF),
                      ),
                      _statPill(
                        label: "Pending",
                        value: pending.toString(),
                        color: const Color(0xFFFFA726),
                      ),
                      _statPill(
                        label: "Approved",
                        value: approved.toString(),
                        color: const Color(0xFF43A047),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),
                Text(
                  "Quick requests",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: const Color(0xFF2F3A4C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // Quick actions grid (same concept but more “fluid” animation)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.1,
                  children: [
                    _quickAction(
                      context,
                      title: "Leave",
                      icon: Icons.calendar_month,
                      color1: const Color(0xFFFF8A5C),
                      color2: const Color(0xFFFF5E62),
                      type: "leave",
                    ),
                    _quickAction(
                      context,
                      title: "Exit",
                      icon: Icons.exit_to_app,
                      color1: const Color(0xFF00C6FF),
                      color2: const Color(0xFF0072FF),
                      type: "exit",
                    ),
                    _quickAction(
                      context,
                      title: "Attestation",
                      icon: Icons.description_outlined,
                      color1: const Color(0xFF7C4DFF),
                      color2: const Color(0xFF536DFE),
                      type: "att",
                    ),
                    _quickAction(
                      context,
                      title: "Mission",
                      icon: Icons.work_outline,
                      color1: const Color(0xFF00E5A0),
                      color2: const Color(0xFF00C6FF),
                      type: "mission",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statPill({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickAction(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color1,
    required Color color2,
    required String type,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RequestFormScreen(
              userId: widget.userId,
              type: type,
            ),
          ),
        );
      },
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 350),
        tween: Tween(begin: 0.96, end: 1),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: [color1, color2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color2.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -18,
                bottom: -18,
                child: Icon(
                  Icons.circle,
                  size: 80,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Tap to create",
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Same wave style as on the LoginScreen / RequestForm-style headers
class _TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.6,
      size.height - 70,
    );
    path.quadraticBezierTo(
      size.width * 0.85,
      size.height - 110,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_TopWaveClipper oldClipper) => false;
}