import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/erp_provider.dart';
import '../../auth/login_screen.dart';

/// Page 6 — Profile (Employee information, leave details, and settings)
class SalesProfilePage extends StatefulWidget {
  const SalesProfilePage({super.key});

  @override
  State<SalesProfilePage> createState() => _SalesProfilePageState();
}

class _SalesProfilePageState extends State<SalesProfilePage> {
  String _phone = '+91 98450 88112';
  String _deskLocation = 'Sales Bay 3F, Executive Tower';

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

            // Available Leave Balance Breakdown
            _buildLeaveBalanceSection(),
            const SizedBox(height: 16),

            // Company & Employment Details (Locked / Read-only)
            _buildCompanyDetailsSection(erp),
            const SizedBox(height: 16),

            // Contact Information (Permitted Editable)
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
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'RK',
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
                        'Sales BD',
                        style: TextStyle(color: Color(0xFF34D399), fontSize: 9.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                const Text(
                  'Senior Sales & BD Associate',
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
                    style: TextStyle(color: Color(0xFF212529), fontSize: 13.5, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '20 Days Total',
                  style: TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildLeaveBox('Annual Leave', '14', const Color(0xFF38BDF8)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildLeaveBox('Sick Leave', '4', const Color(0xFF34D399)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildLeaveBox('Casual Leave', '2', const Color(0xFFFBBF24)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveBox(String label, String days, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF212529),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(days, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10), textAlign: TextAlign.center),
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
          Row(
            children: [
              const Icon(Icons.lock_outline_rounded, color: Color(0xFF64748B), size: 16),
              const SizedBox(width: 8),
              const Text(
                'Employment Details (Company Managed)',
                style: TextStyle(color: Color(0xFF212529), fontSize: 13.5, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildReadOnlyRow('Employee ID', erp.currentUserId),
          _buildReadOnlyRow('Designation', 'Senior Sales & BD Associate'),
          _buildReadOnlyRow('Department', 'Corporate Growth & Sales'),
          _buildReadOnlyRow('Reporting Manager', 'Laven Lokesh (CEO) / Priya Nair (GM)'),
          _buildReadOnlyRow('Employment Type', 'Permanent Full-time'),
          _buildReadOnlyRow('Joining Date', '15 Jan 2024'),
        ],
      ),
    );
  }

  Widget _buildReadOnlyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5)),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
                const Icon(Icons.lock_rounded, size: 12, color: Color(0xFF475569)),
              ],
            ),
          ),
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
                  Icon(Icons.edit_note_rounded, color: Color(0xFF60A5FA), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Contact Information (Editable)',
                    style: TextStyle(color: Color(0xFF212529), fontSize: 13.5, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              InkWell(
                onTap: _showEditContactDialog,
                child: const Text(
                  'Edit',
                  style: TextStyle(color: Color(0xFF60A5FA), fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildContactRow('Work Email', erp.currentUserEmail, Icons.email_outlined),
          _buildContactRow('Mobile Number', _phone, Icons.phone_outlined),
          _buildContactRow('Desk Location', _deskLocation, Icons.location_on_outlined),
        ],
      ),
    );
  }

  Widget _buildContactRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 15, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditContactDialog() {
    final phoneCtrl = TextEditingController(text: _phone);
    final deskCtrl = TextEditingController(text: _deskLocation);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Contact Info', style: TextStyle(color: Color(0xFF212529), fontSize: 15, fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: phoneCtrl,
                style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  filled: true,
                  fillColor: const Color(0xFFF5F6F7),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: deskCtrl,
                style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Desk Location',
                  labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  filled: true,
                  fillColor: const Color(0xFFF5F6F7),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF212529),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              setState(() {
                _phone = phoneCtrl.text.trim();
                _deskLocation = deskCtrl.text.trim();
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Color(0xFF10B981),
                  content: Text('Contact information updated.'),
                ),
              );
            },
            child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, ErpProvider erp) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: Colors.white, title: const Text('Sign Out', style: TextStyle(color: Color(0xFF212529), fontSize: 16)),
              content: const Text(
                'Are you sure you want to sign out of the Sales Portal?',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    erp.switchToDemoMode();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 18),
        label: const Text('Sign Out of Sales Portal', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFEF4444)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
