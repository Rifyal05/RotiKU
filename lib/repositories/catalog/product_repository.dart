import '../../core/services/supabase_service.dart';
import '../../models/catalog/product_model.dart';

class ProductRepository {
  final SupabaseService _supabaseService;

  ProductRepository({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService();

  Future<List<ProductModel>> getActiveProducts() async {
    final rawList = await _supabaseService.fetchActiveProducts();
    return rawList.map((json) => ProductModel.fromJson(json)).toList();
  }
}