import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/user_role.dart';
import '../../../providers/erp_provider.dart';
import '../../auth/login_screen.dart';

/// Page 5: Finance Profile
/// Minimalist employee profile for Siddharth Roy (EMP-115)
/// Charcoal #212529, soft gray #F5F6F7, and white #FFFFFF cards.
class FinanceProfilePage extends StatefulWidget {
  const FinanceProfilePage({super.key});

  @override
  State<FinanceProfilePage> createState() => _FinanceProfilePageState();
}

class _FinanceProfilePageState extends State<FinanceProfilePage> {
  final String _phone = '+91 98300 88710';
  final String _deskLocation = 'Finance Bay 3F, Corporate Tower';

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      body: SafeArea(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          children: [
            // 1. Employee Identity Card (Squircle avatar, Name, Role, Full-time tag)
            _buildProfileHeader(erp),
            const SizedBox(height: 16),

            // 2. Dark Leave Balance Card (18 Days, Synced with Central HR, Annual, Sick, Casual)
            _buildLeaveBalanceCard(),
            const SizedBox(height: 16),

            // 3. Employment Details Card (Locked / Company Managed)
            _buildCompanyDetailsSection(erp),
            const SizedBox(height: 16),

            // 4. Contact Information Card
            _buildContactSection(erp),
            const SizedBox(height: 24),

            // 5. Sign Out Button
            _buildSignOutButton(context, erp),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// 1. Profile Header matching Image 2 squircle style
  Widget _buildProfileHeader(ErpProvider erp) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Row(
        children: [
          // Charcoal Squircle Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF212529),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              'SR',
              style: GoogleFonts.instrumentSans(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Name & Designation
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Siddharth Roy',
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFF212529),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Lead Financial Analyst & Controller',
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFF868E96),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Full-time employee',
                    style: GoogleFonts.instrumentSans(
                      color: const Color(0xFF495057),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Dark Leave Balance Card (Charcoal #212529)
  Widget _buildLeaveBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF212529),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Available Leave Balance',
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFFADB5BD),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.calendar_month_outlined, color: Colors.white, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '18 Days',
            style: GoogleFonts.instrumentSans(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Synced with Central HR',
            style: GoogleFonts.instrumentSans(
              color: const Color(0xFFADB5BD),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha: 0.12), height: 1),
          const SizedBox(height: 14),

          // Categories: Annual / Earned, Sick Leave, Casual Leave
          Row(
            children: [
              Expanded(
                child: _buildLeaveCategoryColumn('Annual / Earned', '12 days'),
              ),
              Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.12)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildLeaveCategoryColumn('Sick Leave', '4 days'),
                ),
              ),
              Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.12)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _buildLeaveCategoryColumn('Casual Leave', '2 days'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveCategoryColumn(String title, String count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96), fontSize: 10.5, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Text(
          count,
          style: GoogleFonts.instrumentSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  /// 3. Company & Employment Details Card
  Widget _buildCompanyDetailsSection(ErpProvider erp) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        children: [
          _buildDetailRow(icon: Icons.badge_outlined, label: 'EMPLOYEE ID', value: 'EMP-115'),
          const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF1F3F5)),
          _buildDetailRow(icon: Icons.work_outline_rounded, label: 'DESIGNATION', value: 'Lead Financial Analyst & Controller'),
          const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF1F3F5)),
          _buildDetailRow(icon: Icons.apartment_rounded, label: 'DEPARTMENT', value: 'Finance & Accounts'),
          const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF1F3F5)),
          _buildDetailRow(icon: Icons.supervisor_account_outlined, label: 'REPORTING MANAGER', value: 'Marcus Chen (Finance Director)'),
          const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF1F3F5)),
          _buildDetailRow(icon: Icons.mail_outline_rounded, label: 'OFFICIAL EMAIL', value: 'siddharth.roy@digitalinertia.com'),
        ],
      ),
    );
  }

  /// 4. Contact Details
  Widget _buildContactSection(ErpProvider erp) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        children: [
          _buildDetailRow(icon: Icons.phone_outlined, label: 'PHONE NUMBER', value: _phone),
          const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF1F3F5)),
          _buildDetailRow(icon: Icons.pin_drop_outlined, label: 'DESK LOCATION', value: _deskLocation),
        ],
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: const Color(0xFF212529), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFF868E96),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFF212529),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 5. Sign Out Button
  Widget _buildSignOutButton(BuildContext context, ErpProvider erp) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Sign Out', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w800)),
              content: Text(
                'Are you sure you want to sign out from the Finance Portal?',
                style: GoogleFonts.instrumentSans(fontSize: 13),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Cancel', style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96))),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    erp.setRole(UserRole.employee);
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF212529),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Sign Out', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.logout_rounded, color: Color(0xFF212529), size: 18),
        label: Text(
          'Sign Out of Finance Portal',
          style: GoogleFonts.instrumentSans(
            color: const Color(0xFF212529),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFCED4DA)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
