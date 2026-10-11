import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/erp_provider.dart';
import '../../models/user_role.dart';
import '../main_navigation_screen.dart';

/// Screen 3: Biometric Fingerprint Authentication Screen
/// Reproduces the circular fingerprint prompt and authentication flow.
class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;
  bool _isAuthenticating = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _triggerBiometric() async {
    if (_isAuthenticating) return;
    setState(() {
      _isAuthenticating = true;
    });

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    setState(() {
      _isSuccess = true;
    });

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    // Login as CEO Laven Lokesh
    context.read<ErpProvider>().setRole(UserRole.ceo);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Circular Fingerprint container with subtle pulse animation
              Center(
                child: GestureDetector(
                  onTap: _triggerBiometric,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isAuthenticating ? 1.0 : _pulseAnimation.value,
                        child: Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isSuccess
                                ? AppColors.statusCompletedLight
                                : const Color(0xFFF1F5F9),
                            border: Border.all(
                              color: _isSuccess
                                  ? AppColors.statusCompleted.withOpacity(0.3)
                                  : AppColors.borderLight,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: _isSuccess
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                    size: 72,
                                    color: AppColors.statusCompleted,
                                  )
                                : Icon(
                                    Icons.fingerprint_rounded,
                                    size: 84,
                                    color: _isAuthenticating
                                        ? AppColors.electricBlue
                                        : const Color(0xFF475569),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // "Authenticate" Title
              Text(
                _isSuccess
                    ? 'Authenticated'
                    : (_isAuthenticating ? 'Verifying Identity...' : 'Authenticate'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              // Subtitle
              Text(
                _isSuccess
                    ? 'Welcome back, Laven Lokesh'
                    : 'Tap fingerprint or use sensor to continue',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(flex: 3),
              // Cancel Button
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
