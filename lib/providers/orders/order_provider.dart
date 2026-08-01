import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/supabase_service.dart';

class OrderProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchOrdersDirectly(String customerId) async {
    try {
      final response = await _client
          .from(AppConstants.tableOrders)
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> getCustomerOrdersStream(String customerId) {
    return _supabaseService.streamCustomerOrders(customerId);
  }
}