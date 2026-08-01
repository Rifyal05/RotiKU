import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  SupabaseClient get client => _client;

  User? get currentUser => _client.auth.currentUser;

  Session? get currentSession => _client.auth.currentSession;

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
  }) async {
    return await _client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.signup,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<String?> getUserRole(String userId) async {
    final response = await _client
        .from(AppConstants.tableUsers)
        .select('role')
        .eq('id', userId)
        .maybeSingle();

    if (response != null && response['role'] != null) {
      return response['role'] as String;
    }
    return AppConstants.roleCustomer;
  }

  Future<List<Map<String, dynamic>>> fetchActiveProducts() async {
    final response = await _client
        .from(AppConstants.tableProducts)
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchCartItems(String userId) async {
    final response = await _client
        .from('cart_items')
        .select('id, quantity, product_id, products(*)')
        .eq('user_id', userId);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> upsertCartItem(String userId, String productId, int quantity) async {
    await _client.from('cart_items').upsert(
      {
        'user_id': userId,
        'product_id': productId,
        'quantity': quantity,
        'updated_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'user_id, product_id',
    );
  }

  Future<void> removeCartItem(String userId, String productId) async {
    await _client
        .from('cart_items')
        .delete()
        .eq('user_id', userId)
        .eq('product_id', productId);
  }

  Future<void> clearCart(String userId) async {
    await _client
        .from('cart_items')
        .delete()
        .eq('user_id', userId);
  }

  Future<String> uploadPaymentProof(File file, String orderId) async {
    final fileExt = file.path.split('.').last;
    final fileName = '${orderId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final filePath = 'proofs/$fileName';

    await _client.storage.from(AppConstants.bucketPaymentProofs).upload(
      filePath,
      file,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    );

    return _client.storage.from(AppConstants.bucketPaymentProofs).getPublicUrl(filePath);
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    final response = await _client
        .from(AppConstants.tableOrders)
        .insert(orderData)
        .select()
        .single();

    return response;
  }

  Stream<List<Map<String, dynamic>>> streamCustomerOrders(String customerId) {
    return _client
        .from(AppConstants.tableOrders)
        .stream(primaryKey: ['id'])
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);
  }
}