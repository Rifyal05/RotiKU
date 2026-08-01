import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';

class CartItem {
  final String id;
  final String productId;
  final String name;
  final int price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  int get subtotal => price * quantity;
}

class CartProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  List<CartItem> _items = [];
  bool _isLoading = false;

  CartProvider() {
    fetchCartFromDatabase();
  }

  List<CartItem> get items => List.unmodifiable(_items);

  bool get isLoading => _isLoading;

  int get totalItemsCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  int get subtotalPrice {
    return _items.fold(0, (sum, item) => sum + item.subtotal);
  }

  int get shippingFee => _items.isEmpty ? 0 : 10000;

  int get grandTotalPrice => subtotalPrice + shippingFee;

  Future<void> fetchCartFromDatabase() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final data = await _supabaseService.fetchCartItems(userId);
      _items = data.map((item) {
        final product = item['products'] as Map<String, dynamic>? ?? {};
        return CartItem(
          id: item['id']?.toString() ?? '',
          productId: item['product_id']?.toString() ?? '',
          name: product['name'] ?? 'Roti',
          price: (product['price'] as num?)?.toInt() ?? 0,
          imageUrl: product['image_url'] ?? '',
          quantity: (item['quantity'] as num?)?.toInt() ?? 1,
        );
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (_) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem({
    required String id,
    required String name,
    required int price,
    required String imageUrl,
    int quantity = 1,
  }) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final existingIndex = _items.indexWhere((item) => item.productId == id);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
      if (userId != null) {
        await _supabaseService.upsertCartItem(
          userId,
          id,
          _items[existingIndex].quantity,
        );
      }
    } else {
      _items.add(CartItem(
        id: id,
        productId: id,
        name: name,
        price: price,
        imageUrl: imageUrl,
        quantity: quantity,
      ));
      if (userId != null) {
        await _supabaseService.upsertCartItem(userId, id, quantity);
      }
    }
    notifyListeners();
  }

  Future<void> incrementQuantity(String productId) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
      if (userId != null) {
        await _supabaseService.upsertCartItem(
          userId,
          productId,
          _items[index].quantity,
        );
      }
    }
  }

  Future<void> decrementQuantity(String productId) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
        notifyListeners();
        if (userId != null) {
          await _supabaseService.upsertCartItem(
            userId,
            productId,
            _items[index].quantity,
          );
        }
      } else {
        final removedItem = _items.removeAt(index);
        notifyListeners();
        if (userId != null) {
          await _supabaseService.removeCartItem(userId, removedItem.productId);
        }
      }
    }
  }

  Future<void> removeItem(String productId) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
    if (userId != null) {
      await _supabaseService.removeCartItem(userId, productId);
    }
  }

  Future<void> clearCart() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    _items.clear();
    notifyListeners();
    if (userId != null) {
      await _supabaseService.clearCart(userId);
    }
  }
}