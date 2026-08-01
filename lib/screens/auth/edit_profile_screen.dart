import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/user/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  final ImagePicker _picker = ImagePicker();
  File? _selectedAvatarFile;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _fullNameController = TextEditingController(text: authProvider.userName);
    _emailController = TextEditingController(text: authProvider.userEmail);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatarImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _selectedAvatarFile = File(image.path);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto profil baru dipilih. Tekan Simpan Perubahan untuk mengunggah.'),
          backgroundColor: AppColors.brandAmber,
        ),
      );
    }
  }

  Future<void> _handleSave() async {
    final newName = _fullNameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama lengkap tidak boleh kosong'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updateProfile(
      newFullName: newName,
      avatarFile: _selectedAvatarFile,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perubahan profil berhasil diunggah dan disimpan!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Gagal menyimpan perubahan.'),
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
        title: Text(
          'Edit Profil',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickAvatarImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.brandAmber, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: _selectedAvatarFile != null
                              ? Image.file(
                            _selectedAvatarFile!,
                            fit: BoxFit.cover,
                          )
                              : (authProvider.userAvatarUrl != null
                              ? Image.network(
                            authProvider.userAvatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset('assets/images/rotiku_logo.png', fit: BoxFit.cover);
                            },
                          )
                              : Image.asset('assets/images/rotiku_logo.png', fit: BoxFit.cover)),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceWhite,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.surfaceBorder),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(28, 25, 23, 0.08),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.photo_camera_rounded,
                            size: 16,
                            color: AppColors.brandAmber,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Ketuk untuk ubah foto profil',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
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
                      'Nama Lengkap',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        hintText: 'Nama Anda',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Alamat Email (Tidak Dapat Diubah)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      enabled: false,
                      style: const TextStyle(color: AppColors.textSecondary),
                      decoration: InputDecoration(
                        fillColor: AppColors.disabledGrey,
                        suffixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.surfaceBorder),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.surfaceBorder),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Alamat email terikat dengan akun utama Anda.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: authProvider.isLoading ? null : _handleSave,
                child: authProvider.isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}