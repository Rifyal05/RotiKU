import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../customer/catalog/customer_main_shell.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _checkSessionAndNavigate();
      }
    });
  }

  void _checkSessionAndNavigate() {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CustomerMainShell()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCanvas,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 40),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.82,
                constraints: const BoxConstraints(maxWidth: 360),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.surfaceBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(28, 25, 23, 0.04),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCanvas,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Image.asset(
                          'assets/images/rotiku_logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.bakery_dining_rounded,
                              size: 44,
                              color: AppColors.brandAmber,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppConstants.appName,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'FRESHLY BAKED EVERY DAY',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Column(
                children: [
                  SizedBox(
                    width: 160,
                    child: LinearProgressIndicator(
                      backgroundColor: AppColors.surfaceBorder,
                      color: AppColors.brandAmber,
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'POWERED BY SUPABASE ENGINE',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: AppColors.textSecondary,
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
}