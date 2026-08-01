import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/catalog/cart_provider.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  String _formatRupiah(int number) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(number);
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: AppColors.backgroundCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCanvas,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: canPop
            ? Padding(
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
        )
            : null,
        title: Text(
          'Keranjang Belanja',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: SafeArea(
        child: cartProvider.items.isEmpty
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.oatCream,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shopping_cart_outlined, color: AppColors.brandAmber, size: 40),
                ),
                const SizedBox(height: 16),
                Text(
                  'Keranjang Belanja Kosong',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Kamu belum menambahkan roti ke keranjang. Yuk cari roti favoritmu!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daftar Pesanan (${cartProvider.totalItemsCount} Item)',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      cartProvider.clearCart();
                    },
                    child: const Text(
                      'Hapus Semua',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cartProvider.items.length,
                itemBuilder: (context, index) {
                  final item = cartProvider.items[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceBorder),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(28, 25, 23, 0.04),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item.imageUrl,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 72,
                                height: 72,
                                color: AppColors.oatCream,
                                child: const Icon(Icons.bakery_dining, color: AppColors.brandAmber),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      cartProvider.removeItem(item.id);
                                    },
                                    child: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: AppColors.textSecondary,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_formatRupiah(item.price)} / pcs',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatRupiah(item.subtotal),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.brandAmber,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceWhite,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.surfaceBorder),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            cartProvider.decrementQuantity(item.id);
                                          },
                                          child: const Icon(Icons.remove, size: 18, color: AppColors.textPrimary),
                                        ),
                                        SizedBox(
                                          width: 32,
                                          child: Text(
                                            '${item.quantity}',
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 15),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            cartProvider.incrementQuantity(item.id);
                                          },
                                          child: const Icon(Icons.add, size: 18, color: AppColors.textPrimary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surfaceBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(28, 25, 23, 0.04),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.receipt_long_rounded, color: AppColors.brandAmber, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Ringkasan Pembayaran',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 18, color: AppColors.textSecondary),
                            SizedBox(width: 8),
                            Text('Total Barang', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          ],
                        ),
                        Text('${cartProvider.totalItemsCount} Item', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.payments_outlined, size: 18, color: AppColors.textSecondary),
                            SizedBox(width: 8),
                            Text('Subtotal Produk', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          ],
                        ),
                        Text(_formatRupiah(cartProvider.subtotalPrice), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(color: AppColors.surfaceBorder),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Pembayaran', style: Theme.of(context).textTheme.bodyLarge),
                          Text(
                            _formatRupiah(cartProvider.subtotalPrice),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.brandAmber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                  );
                },
                child: const Text('Lanjut ke Checkout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}