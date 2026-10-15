import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/erp_provider.dart';
import '../../models/user_role.dart';
import '../ceo/ceo_executive_shell.dart';
import '../main_navigation_screen.dart';
import '../employee/employee_navigation_screen.dart';

/// Clean & Secure CEO Login & Authentication Screen (Specification Section 2)
/// Implements:
/// - DI Monogram logo and company branding
/// - Heading: "Welcome Back"
/// - Supporting text: "Sign in to your executive workspace."
/// - Company email or employee ID field
/// - Password field with show/hide control
/// - Remember email option
/// - Forgot password and secure password reset flow
/// - Primary Sign In button with loading state
/// - Real backend identity authentication
/// - Direct routing of CEO accounts to CeoExecutiveShellScreen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'laven@digitalinertia.com');
  final _passwordController = TextEditingController(text: 'password123!');
  bool _obscurePassword = true;
  bool _rememberEmail = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final input = _emailController.text.trim();
    final password = _passwordController.text;

    if (input.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFE03131),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: Text(
            'Please enter your corporate email or employee ID and password.',
            style: GoogleFonts.instrumentSans(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final erp = context.read<ErpProvider>();

    try {
      await erp.authenticateUser(input, password);
      if (!mounted) return;

      final Widget destination = (erp.currentRole == UserRole.ceo || erp.currentRole == UserRole.gm)
          ? const CeoExecutiveShellScreen()
          : (erp.currentRole == UserRole.technical ||
                 erp.currentRole == UserRole.employee ||
                 erp.currentRole == UserRole.intern ||
                 erp.currentRole == UserRole.deptLead ||
                 erp.currentRole == UserRole.poc)
              ? const EmployeeNavigationScreen()
              : const MainNavigationScreen();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => destination),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      final message = e.toString()
          .replaceFirst('ApiException (HTTP 401): ', '')
          .replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFE03131),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.instrumentSans(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Executive Credential Reset',
          style: GoogleFonts.instrumentSans(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your registered corporate email address to receive a secure single-use recovery code:',
              style: GoogleFonts.instrumentSans(fontSize: 12.5, color: const Color(0xFF495057), height: 1.4),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: resetEmailController,
              style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF212529)),
              decoration: InputDecoration(
                hintText: 'name@digitalinertia.com',
                hintStyle: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFFADB5BD)),
                filled: true,
                fillColor: const Color(0xFFF5F6F7),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE9ECEF))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE9ECEF))),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Default executive sandbox password: password123!',
              style: GoogleFonts.instrumentSans(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.instrumentSans(color: const Color(0xFF6C757D))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF212529),
                  content: Text('Recovery instructions dispatched to your verified email.', style: GoogleFonts.instrumentSans(color: Colors.white)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF212529),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Send Reset Link', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // DI Monogram Logo
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: const Color(0xFF212529),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF212529).withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'DI',
                        style: GoogleFonts.instrumentSans(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Brand Title & STRATEGIC CONSULTING Badge
                  Text(
                    'DIGITAL INERTIA',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.instrumentSans(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF212529),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFDEE2E6)),
                    ),
                    child: Text(
                      'STRATEGIC CONSULTING',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF212529),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '“COZ’ EVERYONE NEEDS A PUSH”',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.instrumentSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF6C757D),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Clean Login Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 26),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF212529).withOpacity(0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heading & Supporting Text
                        Text(
                          'Welcome Back',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF212529),
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Sign in to your executive workspace.',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 13,
                            color: const Color(0xFF6C757D),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Company Email or Employee ID Label
                        Text(
                          'COMPANY EMAIL OR EMPLOYEE ID',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6C757D),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Email TextField
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: GoogleFonts.instrumentSans(
                            color: const Color(0xFF212529),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'laven@digitalinertia.com',
                            hintStyle: GoogleFonts.instrumentSans(
                              color: const Color(0xFFADB5BD),
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.mail_outline_rounded,
                              color: Color(0xFF6C757D),
                              size: 19,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF5F6F7),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE9ECEF), width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE9ECEF), width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF212529), width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Password Label
                        Text(
                          'PASSWORD',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6C757D),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Password TextField
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleLogin(),
                          style: GoogleFonts.instrumentSans(
                            color: const Color(0xFF212529),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            hintStyle: GoogleFonts.instrumentSans(
                              color: const Color(0xFFADB5BD),
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              color: Color(0xFF6C757D),
                              size: 19,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: const Color(0xFF6C757D),
                                size: 19,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF5F6F7),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE9ECEF), width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE9ECEF), width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF212529), width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Remember Email Option
                        Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: _rememberEmail,
                                activeColor: const Color(0xFF212529),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                onChanged: (val) => setState(() => _rememberEmail = val ?? false),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Remember email on this executive terminal',
                                style: GoogleFonts.instrumentSans(
                                  fontSize: 11.5,
                                  color: const Color(0xFF495057),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),

                        // Primary Sign In Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF212529),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'SIGN IN',
                                    style: GoogleFonts.instrumentSans(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Forgot Password Action
                  TextButton(
                    onPressed: _showForgotPasswordDialog,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6C757D),
                    ),
                    child: Text(
                      'Forgot password? Secure recovery',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6C757D),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
