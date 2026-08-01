import '../../core/services/supabase_service.dart';

class ProductRepository {
  final SupabaseService _supabaseService;

  ProductRepository({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService();

  Future<List<Map<String, dynamic>>> getActiveProducts() async {
    return await _supabaseService.fetchActiveProducts();
  }
}