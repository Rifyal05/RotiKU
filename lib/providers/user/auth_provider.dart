import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../repositories/user/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = false;
  String? _errorMessage;
  String _userRole = 'customer';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get userRole => _userRole;
  bool get isAuthenticated => _authRepository.isAuthenticated;

  String get userName {
    final user = _authRepository.currentUser;
    if (user != null && user.userMetadata != null) {
      final meta = user.userMetadata!;
      if (meta['full_name'] != null && meta['full_name'].toString().isNotEmpty) {
        return meta['full_name'].toString();
      }
      if (meta['name'] != null && meta['name'].toString().isNotEmpty) {
        return meta['name'].toString();
      }
    }
    return 'Budi Santoso';
  }

  String get userEmail {
    return _authRepository.currentUser?.email ?? 'budi.santoso@gmail.com';
  }

  String? get userAvatarUrl {
    final user = _authRepository.currentUser;
    if (user != null && user.userMetadata != null) {
      final avatar = user.userMetadata!['avatar_url'] ?? user.userMetadata!['picture'];
      if (avatar != null && avatar.toString().isNotEmpty) {
        return avatar.toString();
      }
    }
    return null;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  String _translateAuthError(Object error) {
    if (error is AuthException) {
      final msg = error.message.toLowerCase();
      if (msg.contains('invalid login credentials') || msg.contains('invalid_credentials')) {
        return 'Alamat email atau kata sandi yang Anda masukkan salah. Silakan periksa kembali.';
      }
      if (msg.contains('email not confirmed') || msg.contains('not_confirmed')) {
        return 'Alamat email Anda belum terverifikasi.';
      }
      if (msg.contains('already exists') || msg.contains('email_exists')) {
        return 'Alamat email ini sudah terdaftar. Silakan gunakan email lain.';
      }
      if (msg.contains('different from the old') || msg.contains('same_password') || msg.contains('cannot be reused')) {
        return 'Kata sandi baru tidak boleh sama dengan kata sandi lama Anda. Silakan buat kata sandi yang berbeda.';
      }
      if (msg.contains('rate limit') || msg.contains('too many requests') || msg.contains('429')) {
        return 'Terlalu banyak batas permintaan. Silakan tunggu beberapa saat sebelum mencoba kembali.';
      }
      return error.message;
    }
    return error.toString();
  }

  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);
      await _authRepository.login(email: email, password: password);
      _userRole = await _authRepository.getCurrentUserRole();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_translateAuthError(e));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String email, String password, String fullName) async {
    try {
      _setLoading(true);
      _setError(null);
      await _authRepository.register(
        email: email,
        password: password,
        fullName: fullName,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_translateAuthError(e));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String token) async {
    try {
      _setLoading(true);
      _setError(null);
      await _authRepository.verifyOtp(email: email, token: token);
      _userRole = await _authRepository.getCurrentUserRole();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_translateAuthError(e));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resendOtp(String email) async {
    try {
      _setLoading(true);
      _setError(null);
      await _authRepository.resendOtp(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_translateAuthError(e));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> sendResetPasswordEmail(String email) async {
    try {
      _setLoading(true);
      _setError(null);
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_translateAuthError(e));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> verifyRecoveryOtp(String email, String token) async {
    try {
      _setLoading(true);
      _setError(null);
      await Supabase.instance.client.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_translateAuthError(e));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    try {
      _setLoading(true);
      _setError(null);
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      await _authRepository.logout();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_translateAuthError(e));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateProfile({
    required String newFullName,
    File? avatarFile,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      String? uploadedAvatarUrl;

      if (avatarFile != null) {
        final userId = _authRepository.currentUser?.id ?? 'user';
        final fileExt = avatarFile.path.split('.').last;
        final fileName = 'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

        await Supabase.instance.client.storage
            .from(AppConstants.bucketProductImages)
            .upload(fileName, avatarFile, fileOptions: const FileOptions(upsert: true));

        uploadedAvatarUrl = Supabase.instance.client.storage
            .from(AppConstants.bucketProductImages)
            .getPublicUrl(fileName);
      }

      final Map<String, dynamic> updatedData = {
        'full_name': newFullName,
      };

      if (uploadedAvatarUrl != null) {
        updatedData['avatar_url'] = uploadedAvatarUrl;
      }

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: updatedData),
      );

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_translateAuthError(e));
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _userRole = 'customer';
    notifyListeners();
  }
}