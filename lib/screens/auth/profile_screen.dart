import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/user/auth_provider.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleRealDeleteAccount(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await Supabase.instance.client.rpc('delete_user_account');
      await Supabase.instance.client.auth.signOut();

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Akun Anda telah berhasil dihapus secara permanen.'),
          backgroundColor: AppColors.danger,
        ),
      );

      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus akun: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.surfaceBorder),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.danger),
              SizedBox(width: 8),
              Text(
                'Hapus Akun Anda?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
          content: const Text(
            'Tindakan ini permanen dan tidak dapat dibatalkan. Seluruh data profil dan riwayat pesanan Anda di Supabase akan dihapus selamanya.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Batal',
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w400),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                minimumSize: const Size(120, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _handleRealDeleteAccount(context);
              },
              child: const Text('Hapus Permanen', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final canPop = Navigator.of(context).canPop();

    final String fullName = authProvider.userName;
    final String email = authProvider.userEmail;
    final String? avatarUrl = authProvider.userAvatarUrl;

    return Scaffold(
      backgroundColor: AppColors.backgroundCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCanvas,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: canPop
            ? Padding(
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
        )
            : null,
        title: Text(
          'Profil Saya',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
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
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.brandAmber, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: avatarUrl != null
                            ? Image.network(
                          avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset('assets/images/rotiku_logo.png', fit: BoxFit.cover);
                          },
                        )
                            : Image.asset('assets/images/rotiku_logo.png', fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      fullName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.oatCream,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Text(
                        authProvider.userRole == 'admin' ? 'Akun Admin' : 'Akun Pelanggan',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brandAmber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Material(
                color: AppColors.surfaceWhite,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: const BorderSide(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      context,
                      Icons.person_outline_rounded,
                      'Edit Profil',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1, color: AppColors.surfaceBorder),
                    _buildMenuItem(
                      context,
                      Icons.info_outline_rounded,
                      'Tentang Aplikasi RotiKu',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AboutScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.oatCream,
                    foregroundColor: AppColors.brandAmber,
                    elevation: 0,
                    side: const BorderSide(color: Color(0xFFFDE68A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    await authProvider.logout();
                    if (!context.mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout_rounded, color: AppColors.brandAmber, size: 20),
                  label: const Text(
                    'Keluar dari Akun',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandAmber,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEE2E2),
                    foregroundColor: AppColors.danger,
                    elevation: 0,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => _showDeleteAccountDialog(context),
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                  label: const Text(
                    'Hapus Akun Saya Permanen',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context,
      IconData icon,
      String title, {
        required VoidCallback onTap,
      }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.backgroundCanvas,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.brandAmber, size: 20),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
    );
  }
}