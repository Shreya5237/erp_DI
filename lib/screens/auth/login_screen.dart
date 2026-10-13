import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/erp_provider.dart';
import '../../models/user_role.dart';
import '../main_navigation_screen.dart';
import '../employee/employee_navigation_screen.dart';
import '../sales/sales_navigation_screen.dart';
import '../finance/finance_navigation_screen.dart';
import '../hr/hr_navigation_screen.dart';

/// Screen 1: Login & Demonstration Accounts Access Screen adhering to Section 2 of ERP PRD
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'arjun.sharma@digitalinertia.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleCustomLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final erp = context.read<ErpProvider>();

    try {
      await erp.loginWithApi(email, password);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF059669),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Live Backend Connected: ${erp.currentUserName} (${erp.currentRole.label})'),
              ),
            ],
          ),
        ),
      );
      if (erp.currentRole == UserRole.sales) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SalesNavigationScreen()),
        );
      } else if (erp.currentRole == UserRole.finance) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const FinanceNavigationScreen()),
        );
      } else if (erp.currentRole == UserRole.hr) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HrNavigationScreen()),
        );
      } else if (erp.currentRole == UserRole.employee || erp.currentRole == UserRole.poc) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const EmployeeNavigationScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE9ECEF)),
          ),
          title: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Color(0xFFE03131), size: 22),
              SizedBox(width: 8),
              Text('Connection / Auth Failed', style: TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                e.toString().replaceFirst('ApiException (HTTP 401): ', '').replaceFirst('Exception: ', ''),
                style: const TextStyle(color: Color(0xFF495057), fontSize: 13.5),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: const Text(
                  'Backend Target: http://10.0.2.2:8080/api/v1/auth/login\n\nNote: In Phase 1, to explore offline demo data without a running backend, select one of the Demo Account cards below.',
                  style: TextStyle(color: Color(0xFF6C757D), fontSize: 11),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK', style: TextStyle(color: Color(0xFF212529), fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    }
  }

  void _loginAsDemo(UserRole role) async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final erp = context.read<ErpProvider>();
    erp.switchToDemoMode();
    erp.setRole(role);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFD97706),
        content: Text('Operating in Offline Demo Mode as ${erp.currentUserName}'),
      ),
    );

    if (role == UserRole.sales) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesNavigationScreen()),
      );
    } else if (role == UserRole.finance) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const FinanceNavigationScreen()),
      );
    } else if (role == UserRole.hr) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HrNavigationScreen()),
      );
    } else if (role == UserRole.employee || role == UserRole.poc) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const EmployeeNavigationScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _StarryWavePainter(),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),

                  // Brand Badge
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF212529),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF212529).withOpacity(0.18),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Di',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    'DIGITAL INERTIA',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF212529),
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Corporate Operations ERP Platform',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6C757D),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // SECTION 2: DEMONSTRATION ACCOUNTS QUICK LOGIN CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE9ECEF)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF212529).withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.badge_rounded, color: Color(0xFF212529), size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Instant Demonstration Accounts',
                              style: TextStyle(
                                color: Color(0xFF212529),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Test the ERP from 5 role perspectives adhering to PRD:',
                          style: TextStyle(color: Color(0xFF6C757D), fontSize: 11),
                        ),
                        const SizedBox(height: 12),

                        // CEO Demo Button
                        _buildDemoLoginTile(
                          icon: Icons.shield_rounded,
                          color: const Color(0xFF212529),
                          title: 'CEO / Administrator',
                          name: 'Laven Lokesh',
                          email: 'laven@digitalinertia.com',
                          badge: 'Full Admin',
                          onTap: () => _loginAsDemo(UserRole.ceo),
                        ),
                        const SizedBox(height: 8),

                        // Technical Employee Demo Button
                        _buildDemoLoginTile(
                          icon: Icons.terminal_rounded,
                          color: const Color(0xFF495057),
                          title: 'Technical Employee',
                          name: 'Arjun Sharma',
                          email: 'arjun.sharma@digitalinertia.com',
                          badge: 'Agile & Code',
                          onTap: () => _loginAsDemo(UserRole.employee),
                        ),
                        const SizedBox(height: 8),

                        // Sales Employee Demo Button
                        _buildDemoLoginTile(
                          icon: Icons.trending_up_rounded,
                          color: const Color(0xFF2F9E44),
                          title: 'Sales & BD Personnel',
                          name: 'Rajesh Kumar',
                          email: 'rajesh.kumar@digitalinertia.com',
                          badge: 'Pipeline CRM',
                          onTap: () => _loginAsDemo(UserRole.sales),
                        ),
                        const SizedBox(height: 8),

                        // Finance Personnel Demo Button
                        _buildDemoLoginTile(
                          icon: Icons.account_balance_wallet_rounded,
                          color: const Color(0xFF1971C2),
                          title: 'Finance Personnel',
                          name: 'Siddharth Roy',
                          email: 'siddharth.roy@digitalinertia.com',
                          badge: 'Budgets & Ops',
                          onTap: () => _loginAsDemo(UserRole.finance),
                        ),
                        const SizedBox(height: 8),

                        // HR Personnel Demo Button
                        _buildDemoLoginTile(
                          icon: Icons.people_alt_rounded,
                          color: const Color(0xFF7048E8),
                          title: 'HR & People Operations',
                          name: 'Meera Joshi',
                          email: 'meera.joshi@digitalinertia.com',
                          badge: 'Talent & Ops',
                          onTap: () => _loginAsDemo(UserRole.hr),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Custom Credential Login Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE9ECEF)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF212529).withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sign in with Credentials',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _emailController,
                          style: const TextStyle(color: Color(0xFF212529), fontSize: 13.5),
                          decoration: InputDecoration(
                            hintText: 'Work Email',
                            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFADB5BD)),
                            prefixIcon: const Icon(Icons.email_outlined, size: 18, color: Color(0xFF6C757D)),
                            filled: true,
                            fillColor: const Color(0xFFF5F6F7),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE9ECEF))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE9ECEF))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF212529), width: 1.5)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Color(0xFF212529), fontSize: 13.5),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFADB5BD)),
                            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: Color(0xFF6C757D)),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: const Color(0xFF6C757D)),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF5F6F7),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE9ECEF))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE9ECEF))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF212529), width: 1.5)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleCustomLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF212529),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isLoading
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Sign In', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoLoginTile({
    required IconData icon,
    required Color color,
    required String title,
    required String name,
    required String email,
    required String badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE9ECEF)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(color: Color(0xFF212529), fontSize: 12.5, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(badge, style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  Text('$name • $email', style: const TextStyle(color: Color(0xFF6C757D), fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFADB5BD), size: 12),
          ],
        ),
      ),
    );
  }
}

class _StarryWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF212529).withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < 4; i++) {
      final path = Path();
      final yOffset = size.height * (0.35 + i * 0.08);
      path.moveTo(0, yOffset);
      path.cubicTo(
        size.width * 0.3,
        yOffset - 30,
        size.width * 0.7,
        yOffset + 40,
        size.width,
        yOffset - 20,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

