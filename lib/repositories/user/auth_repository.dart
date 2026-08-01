import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';

class AuthRepository {
  final SupabaseService _supabaseService;

  AuthRepository({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService();

  User? get currentUser => _supabaseService.currentUser;

  bool get isAuthenticated => _supabaseService.currentSession != null;

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await _supabaseService.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return await _supabaseService.signUp(
      email: email,
      password: password,
      fullName: fullName,
    );
  }

  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
  }) async {
    return await _supabaseService.verifyOtp(
      email: email,
      token: token,
    );
  }

  Future<void> resendOtp(String email) async {
    await Supabase.instance.client.auth.resend(
      type: OtpType.signup,
      email: email,
    );
  }

  Future<void> logout() async {
    await _supabaseService.signOut();
  }

  Future<String> getCurrentUserRole() async {
    final user = currentUser;
    if (user == null) return 'customer';
    return await _supabaseService.getUserRole(user.id) ?? 'customer';
  }
}