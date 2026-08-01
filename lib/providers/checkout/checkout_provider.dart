import 'dart:io';
import 'package:flutter/material.dart';
import '../../repositories/checkout/checkout_repository.dart';

class CheckoutProvider extends ChangeNotifier {
  final CheckoutRepository _checkoutRepository = CheckoutRepository();

  bool _isLoading = false;
  String? _errorMessage;
  double _latitude = -6.208845;
  double _longitude = 106.845612;
  String _addressText = 'Jl. M.T. Haryono No. 52, Cikoko, Kec. Pancoran, Kota Jakarta Selatan, 12770';
  int _paymentMethodIndex = 2;
  File? _selectedProofImage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get latitude => _latitude;
  double get longitude => _longitude;
  String get addressText => _addressText;
  int get paymentMethodIndex => _paymentMethodIndex;
  File? get selectedProofImage => _selectedProofImage;

  String get paymentMethodKey {
    return _paymentMethodIndex == 0 ? 'cod' : 'cashless';
  }

  void updateLocation({
    required double lat,
    required double lng,
    required String address,
  }) {
    _latitude = lat;
    _longitude = lng;
    _addressText = address;
    notifyListeners();
  }

  void selectPaymentMethod(int index) {
    _paymentMethodIndex = index;
    notifyListeners();
  }

  void setProofImage(File? image) {
    _selectedProofImage = image;
    notifyListeners();
  }

  Future<bool> submitOrder({
    required String customerId,
    required List<Map<String, dynamic>> cartItemsJson,
    required double totalPrice,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      String? proofUrl;
      final orderId = 'RK-${DateTime.now().millisecondsSinceEpoch}';

      if (_paymentMethodIndex != 0 && _selectedProofImage != null) {
        proofUrl = await _checkoutRepository.uploadProof(_selectedProofImage!, orderId);
      }

      final payload = {
        'customer_id': customerId,
        'items': cartItemsJson,
        'total_price': totalPrice,
        'payment_method': paymentMethodKey,
        'payment_proof_url': proofUrl,
        'latitude': _latitude,
        'longitude': _longitude,
        'address_text': _addressText,
        'status': 'pending',
      };

      await _checkoutRepository.submitOrder(payload);

      _isLoading = false;
      _selectedProofImage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}