import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';

class CatalogProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _allProducts = [];
  int _selectedCategoryIndex = 0;
  int _currentPage = 0;
  static const int _pageSize = 10;

  final List<String> categories = [
    'Semua',
    'Roti Manis',
    'Roti Tawar',
    'Kue Basah',
    'Pastry'
  ];

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;
  String? get errorMessage => _errorMessage;
  int get selectedCategoryIndex => _selectedCategoryIndex;

  List<Map<String, dynamic>> get allProducts => List.unmodifiable(_allProducts);

  List<Map<String, dynamic>> get filteredProducts {
    if (_selectedCategoryIndex == 0) {
      return _allProducts;
    }
    final selectedCat = categories[_selectedCategoryIndex];
    return _allProducts
        .where((item) => item['category'] == selectedCat)
        .toList();
  }

  void selectCategory(int index) {
    _selectedCategoryIndex = index;
    notifyListeners();
  }

  Future<void> fetchProducts({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        _currentPage = 0;
        _hasMoreData = true;
        _allProducts.clear();
      }

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _client
          .from(AppConstants.tableProducts)
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .range(0, _pageSize - 1);

      _allProducts = List<Map<String, dynamic>>.from(response);
      _hasMoreData = _allProducts.length >= _pageSize;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMoreProducts() async {
    if (_isLoadingMore || !_hasMoreData) return;

    try {
      _isLoadingMore = true;
      notifyListeners();

      _currentPage++;
      final from = _currentPage * _pageSize;
      final to = from + _pageSize - 1;

      final response = await _client
          .from(AppConstants.tableProducts)
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .range(from, to);

      final newProducts = List<Map<String, dynamic>>.from(response);

      if (newProducts.length < _pageSize) {
        _hasMoreData = false;
      }

      _allProducts.addAll(newProducts);
      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      await fetchProducts(isRefresh: true);
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _client
          .from(AppConstants.tableProducts)
          .select()
          .eq('is_active', true)
          .ilike('name', '%${query.trim()}%')
          .order('created_at', ascending: false);

      _allProducts = List<Map<String, dynamic>>.from(response);
      _hasMoreData = false;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}