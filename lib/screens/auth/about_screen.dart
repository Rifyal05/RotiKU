import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCanvas,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
            ),
          ),
        ),
        title: const Text(
          'Tentang RotiKu',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 100,
                height: 100,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.oatCream,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Image.asset(
                  'assets/images/rotiku_logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.bakery_dining_rounded,
                      size: 48,
                      color: AppColors.brandAmber,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 4),
              const Text(
                'Version 1.0.0 (Stable Release)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
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
                child: Text(
                  'Didirikan dengan kecintaan mendalam pada seni pembuatan adonan roti klasik, RotiKu adalah rumah bagi roti dan pastry artisan premium yang dipanggang segar setiap pagi. Kami menggabungkan metode fermentasi lambat tradisional dengan bahan-bahan terbaik dunia. Mulai dari mentega Prancis murni hingga ragi liar alami tanpa menggunakan bahan pengawet buatan. Setiap gigitan RotiKu adalah perpaduan kehangatan, kelembutan, dan cita rasa autentik yang siap menemani momen berharga Anda.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.6,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                '© 2026 PT RotiKu Indonesia.\nAll Rights Reserved.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}