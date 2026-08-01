import 'dart:io';
import '../../core/services/supabase_service.dart';

class CheckoutRepository {
  final SupabaseService _supabaseService;

  CheckoutRepository({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService();

  Future<String> uploadProof(File imageFile, String orderId) async {
    return await _supabaseService.uploadPaymentProof(imageFile, orderId);
  }

  Future<Map<String, dynamic>> submitOrder(Map<String, dynamic> orderPayload) async {
    return await _supabaseService.createOrder(orderPayload);
  }
}