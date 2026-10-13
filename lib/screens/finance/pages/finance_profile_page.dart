import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_role.dart';
import '../../../providers/erp_provider.dart';
import '../../auth/login_screen.dart';

/// Page 6: Finance Profile
/// Personal employee information for Siddharth Roy, synchronized central leave management, and contact details
class FinanceProfilePage extends StatefulWidget {
  const FinanceProfilePage({super.key});

  @override
  State<FinanceProfilePage> createState() => _FinanceProfilePageState();
}

class _FinanceProfilePageState extends State<FinanceProfilePage> {
  String _phone = '+91 98300 88710';
  String _deskLocation = 'Finance Bay 3F, Corporate Tower';

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          children: [
            // Header Profile Card
            _buildProfileHeader(erp),
            const SizedBox(height: 16),

            // Available Leave Balance Section (Synchronized with Central Leave System)
            _buildLeaveBalanceSection(),
            const SizedBox(height: 16),

            // Company & Employment Details (Locked / Central HR Synced)
            _buildCompanyDetailsSection(erp),
            const SizedBox(height: 16),

            // Contact Information (Editable by employee)
            _buildContactSection(erp),
            const SizedBox(height: 24),

            // Sign Out Button
            _buildSignOutButton(context, erp),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ErpProvider erp) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'SR',
                style: TextStyle(
                  color: Color(0xFF212529),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        erp.currentUserName,
                        style: const TextStyle(
                          color: Color(0xFF212529),
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Finance',
                        style: TextStyle(color: Color(0xFF34D399), fontSize: 9.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                const Text(
                  'Finance / Accounts Lead (Senior Financial Analyst)',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${erp.currentUserId} • Permanent Full-Time',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveBalanceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.beach_access_rounded, color: Color(0xFF38BDF8), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Available Leave Balance',
                    style: TextStyle(color: Color(0xFF212529), fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.sync_rounded, color: Color(0xFF10B981), size: 11),
                    SizedBox(width: 4),
                    Text(
                      'Synced with Central HR',
                      style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Total leave days highlighted
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF212529),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Available Leaves', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                    SizedBox(height: 4),
                    Text(
                      '18 Days',
                      style: TextStyle(color: Color(0xFF212529), fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Leave portal: Central HR synchronization active (0 pending leaves)'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 14),
                  label: const Text('Apply Leave', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Breakdown pills
          Row(
            children: [
              Expanded(
                child: _buildLeaveTypePill('Annual / Earned', '12 Days', const Color(0xFF38BDF8)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildLeaveTypePill('Sick Leave', '4 Days', const Color(0xFF10B981)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildLeaveTypePill('Casual Leave', '2 Days', const Color(0xFFF59E0B)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveTypePill(String type, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(type, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(count, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildCompanyDetailsSection(ErpProvider erp) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.badge_rounded, color: Color(0xFFF59E0B), size: 18),
              SizedBox(width: 8),
              Text(
                'Company & Employment Records',
                style: TextStyle(color: Color(0xFF212529), fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Employee ID', erp.currentUserId, isLocked: true),
          _buildInfoRow('Department', 'Finance & Accounts', isLocked: true),
          _buildInfoRow('Team', 'Financial & Business Ops', isLocked: true),
          _buildInfoRow('Designation', 'Finance / Accounts Lead', isLocked: true),
          _buildInfoRow('Reporting Manager', 'Laven Lokesh (CEO)', isLocked: true),
          _buildInfoRow('Employment Type', 'Permanent Full-Time', isLocked: true),
          _buildInfoRow('Joining Date', '15 March 2022', isLocked: true),
        ],
      ),
    );
  }

  Widget _buildContactSection(ErpProvider erp) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.contact_phone_rounded, color: Color(0xFF10B981), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Contact Information',
                    style: TextStyle(color: Color(0xFF212529), fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Color(0xFF38BDF8), size: 18),
                onPressed: _showEditContactDialog,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Work Email', erp.currentUserEmail, isLocked: true),
          _buildInfoRow('Phone', _phone),
          _buildInfoRow('Office Location', _deskLocation),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLocked = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              if (isLocked) ...[
                const SizedBox(width: 6),
                const Icon(Icons.lock_rounded, color: Color(0xFF64748B), size: 12),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showEditContactDialog() {
    final phoneCtrl = TextEditingController(text: _phone);
    final locationCtrl = TextEditingController(text: _deskLocation);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Contact Information', style: TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: phoneCtrl,
                style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Phone',
                  labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  filled: true,
                  fillColor: const Color(0xFFF5F6F7),
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationCtrl,
                style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Desk Location',
                  labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  filled: true,
                  fillColor: const Color(0xFFF5F6F7),
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _phone = phoneCtrl.text.trim();
                _deskLocation = locationCtrl.text.trim();
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contact information updated')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF212529),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, ErpProvider erp) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () {
          erp.setRole(UserRole.ceo);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        },
        icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 18),
        label: const Text('Sign Out of Finance Portal', style: TextStyle(color: Color(0xFFEF4444), fontSize: 13, fontWeight: FontWeight.w700)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFEF4444)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
