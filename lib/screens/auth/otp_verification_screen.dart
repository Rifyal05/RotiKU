import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/user/auth_provider.dart';
import '../customer/catalog/customer_main_shell.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({
    super.key,
    this.email = '',
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _pinController = TextEditingController();
  Timer? _countdownTimer;
  int _secondsRemaining = 59;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.email.isNotEmpty) {
        _autoSendInitialOtp();
      }
    });
  }

  Future<void> _autoSendInitialOtp() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.resendOtp(widget.email);
  }

  void _startCountdown() {
    setState(() {
      _secondsRemaining = 59;
      _canResend = false;
    });
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        _countdownTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final token = _pinController.text.trim();
    if (token.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap masukkan 6-digit kode OTP lengkap'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final emailToVerify = widget.email.isEmpty ? 'user@email.com' : widget.email;
    final success = await authProvider.verifyOtp(emailToVerify, token);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const CustomerMainShell()),
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Kode OTP tidak valid atau telah kadaluarsa.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _handleResendOtp() async {
    final authProvider = context.read<AuthProvider>();
    final emailToResend = widget.email.isEmpty ? 'user@email.com' : widget.email;

    final success = await authProvider.resendOtp(emailToResend);

    if (!mounted) return;

    if (success) {
      _startCountdown();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kode OTP baru telah dikirimkan ke email $emailToResend'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Gagal mengirimkan ulang kode OTP.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final displayEmail = widget.email.isEmpty ? 'email kamu' : widget.email;

    final defaultPinTheme = PinTheme(
      width: 48,
      height: 52,
      textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundCanvas,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: AppColors.brandAmber, width: 2),
      ),
    );

    String timerText = _secondsRemaining < 10
        ? '00:0$_secondsRemaining'
        : '00:$_secondsRemaining';

    return Scaffold(
      backgroundColor: AppColors.backgroundCanvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
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
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.oatCream,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: const Icon(
                      Icons.mark_email_read_outlined,
                      size: 32,
                      color: AppColors.brandAmber,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Verifikasi Kode OTP',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Masukkan 6-digit kode verifikasi yang telah dikirimkan ke $displayEmail',
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
                      children: [
                        Pinput(
                          length: 6,
                          controller: _pinController,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: focusedPinTheme,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          onCompleted: (pin) => _verifyOtp(),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Belum menerima kode? ',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            GestureDetector(
                              onTap: _canResend ? _handleResendOtp : null,
                              child: Text(
                                _canResend ? 'Kirim Ulang Kode' : 'Kirim Ulang ($timerText)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _canResend ? AppColors.brandAmber : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.oatCream,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline_rounded, color: AppColors.brandAmber, size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Tips: Cek folder Spam di email kamu jika kode belum muncul di Inbox Utama, atau pastikan email kamu belum pernah terdaftar sebelumnya.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textPrimary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: authProvider.isLoading ? null : _verifyOtp,
                          child: authProvider.isLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                              : const Text('Verifikasi & Aktifkan Akun'),
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