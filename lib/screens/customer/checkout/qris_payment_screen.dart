import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/catalog/cart_provider.dart';
import '../../../providers/checkout/checkout_provider.dart';
import 'order_success_screen.dart';

class QrisPaymentScreen extends StatefulWidget {
  const QrisPaymentScreen({super.key});

  @override
  State<QrisPaymentScreen> createState() => _QrisPaymentScreenState();
}

class _QrisPaymentScreenState extends State<QrisPaymentScreen> {
  Future<void> _submitQrisOrder() async {
    final checkoutProvider = context.read<CheckoutProvider>();
    final cartProvider = context.read<CartProvider>();
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    final cartItemsJson = cartProvider.items.map((item) => {
      'id': item.productId,
      'name': item.name,
      'price': item.price,
      'quantity': item.quantity,
      'subtotal': item.subtotal,
      'imageUrl': item.imageUrl,
    }).toList();

    final success = await checkoutProvider.submitOrder(
      customerId: userId,
      cartItemsJson: cartItemsJson,
      totalPrice: cartProvider.grandTotalPrice.toDouble(),
    );

    if (!mounted) return;

    if (success) {
      cartProvider.clearCart();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(checkoutProvider.errorMessage ?? 'Gagal membuat pesanan'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkoutProvider = context.watch<CheckoutProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCanvas,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
            ),
          ),
        ),
        title: Text(
          'Pembayaran QRIS Instant',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  children: [
                    Text('Total Pembayaran', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    const Text(
                      'Rp 80.000',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brandAmber,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.oatCream,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Masa Berlaku QRIS: 09:58',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brandAmber,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.oatCream),
                      ),
                      child: Image.asset(
                        'assets/images/qris_code.png',
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.qr_code_2_rounded, size: 180, color: AppColors.textPrimary);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Scan QRIS di atas menggunakan GoPay, OVO, ShopeePay, DANA, atau Mobile Banking',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.oatCream),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.brandAmber,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Memeriksa Status Pembayaran...',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brandAmber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sistem akan otomatis mengalihkan halaman setelah pembayaran berhasil terdeteksi.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: checkoutProvider.isLoading ? null : _submitQrisOrder,
                child: checkoutProvider.isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Text('Cek Status Pembayaran Manual'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}