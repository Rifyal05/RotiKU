import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/user/auth_provider.dart';
import 'login_screen.dart';

class ForgotPasswordResetScreen extends StatefulWidget {
  const ForgotPasswordResetScreen({super.key});

  @override
  State<ForgotPasswordResetScreen> createState() => _ForgotPasswordResetScreenState();
}

class _ForgotPasswordResetScreenState extends State<ForgotPasswordResetScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isPasswordStrong(String password) {
    if (password.length < 6) return false;
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasDigit = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecial = RegExp(r'[^a-zA-Z0-9\s]').hasMatch(password);
    return hasUppercase && hasLowercase && hasDigit && hasSpecial;
  }

  Future<void> _handleUpdatePassword() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi semua kolom sandi baru'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (!_isPasswordStrong(newPassword)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sandi wajib minimal 6 karakter, mengandung huruf besar, kecil, angka, dan simbol'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi kata sandi baru tidak cocok'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updatePassword(newPassword);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi Anda berhasil diperbarui! Silakan login kembali.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Gagal memperbarui kata sandi.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCanvas,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Atur Sandi Baru',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.oatCream,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.brandAmber.withAlpha(51)),
                    ),
                    child: const Icon(
                      Icons.vpn_key_rounded,
                      size: 40,
                      color: AppColors.brandAmber,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Kata Sandi Baru',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Silakan buat kata sandi baru yang kuat untuk akun Anda',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(20),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kata Sandi Baru',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _newPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: 'Minimal 6 karakter',
                            prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary, size: 20),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Konfirmasi Kata Sandi Baru',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: 'Ulangi kata sandi baru',
                            prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary, size: 20),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: authProvider.isLoading ? null : _handleUpdatePassword,
                          child: authProvider.isLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                              : const Text('Simpan & Login Kembali'),
                        ),
                      ],
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