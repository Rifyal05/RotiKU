import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/catalog/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? product;

  const ProductDetailScreen({super.key, this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  String _formatRupiah(int number) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(number);
  }

  @override
  Widget build(BuildContext context) {
    final String productId = widget.product?['id']?.toString() ?? '1';
    final String name = widget.product?['name'] ?? 'Croissant Butter Almond';
    final String category = widget.product?['category'] ?? 'Artisan Pastry';
    final String description =
        widget.product?['description'] ??
        'Croissant klasik yang dipanggang dengan mentega pilihan dan taburan almond panggang premium.';
    final int unitPrice = (widget.product?['price'] as num?)?.toInt() ?? 24000;
    final int stock = (widget.product?['stock'] as num?)?.toInt() ?? 0;
    final String imageUrl =
        widget.product?['image_url'] ??
        'https://lh3.googleusercontent.com/aida/AP1WRLsp5bMzZmlhYMC-s7yLAsmFfLYwMXw8tAdrwgcFVuzOjPL4DCj0bS7OTL-Z3dGZv7Rdcl3mVTNMfRE-ekvJPspoDM7iDwcBLw_mspX7VijSaX0Hz0dd4oPdHvR0_TvwR9WxqhNI0hi63oOWTsQEtC74Au8XPbsYeC5gZh-H-_wleJoZSlgAiDpVYMi-UfPZeB4kwZhxMq_-BrXqfqpDgFux0mXeYOKxtRbEMmrNcm6nwdZo4Hl-iYP5YJ4';

    final bool isOutOfStock = stock <= 0;
    final int totalPrice = isOutOfStock ? 0 : _quantity * unitPrice;
    final cartProvider = context.read<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundCanvas,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                  child: Image.network(
                    imageUrl,
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 240,
                        color: AppColors.oatCream,
                        child: const Icon(
                          Icons.bakery_dining,
                          color: AppColors.brandAmber,
                          size: 64,
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(217),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surfaceBorder,
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.textPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(230),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          child: const Text(
                            'Detail Roti',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(24),
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.oatCream,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.brandAmber.withAlpha(51),
                            ),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.brandAmber,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isOutOfStock
                                ? AppColors.danger.withAlpha(30)
                                : AppColors.oatCream,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isOutOfStock
                                  ? AppColors.danger
                                  : AppColors.brandAmber.withAlpha(51),
                            ),
                          ),
                          child: Text(
                            isOutOfStock ? 'HABIS' : 'Stok: $stock Pcs',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isOutOfStock
                                  ? AppColors.danger
                                  : AppColors.brandAmber,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _formatRupiah(unitPrice),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.brandAmber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Deskripsi Roti',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.surfaceBorder),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(28, 25, 23, 0.08),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: isOutOfStock
                            ? null
                            : () {
                                if (_quantity > 1) {
                                  setState(() {
                                    _quantity--;
                                  });
                                }
                              },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isOutOfStock
                                  ? AppColors.surfaceBorder
                                  : AppColors.brandAmber,
                            ),
                          ),
                          child: Icon(
                            Icons.remove,
                            size: 18,
                            color: isOutOfStock
                                ? AppColors.textSecondary
                                : AppColors.brandAmber,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 36,
                        child: Text(
                          '${isOutOfStock ? 0 : _quantity}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: isOutOfStock
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                              ),
                        ),
                      ),
                      GestureDetector(
                        onTap: isOutOfStock
                            ? null
                            : () {
                                if (_quantity < stock) {
                                  setState(() {
                                    _quantity++;
                                  });
                                }
                              },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isOutOfStock
                                ? AppColors.surfaceBorder
                                : AppColors.brandAmber,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.add,
                            size: 18,
                            color: isOutOfStock
                                ? AppColors.textSecondary
                                : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text.rich(
                    TextSpan(
                      text: 'Total: ',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(fontSize: 16),
                      children: [
                        TextSpan(
                          text: _formatRupiah(totalPrice),
                          style: TextStyle(
                            color: isOutOfStock
                                ? AppColors.textSecondary
                                : AppColors.brandAmber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOutOfStock
                      ? AppColors.disabledGrey
                      : AppColors.brandAmber,
                  foregroundColor: isOutOfStock
                      ? AppColors.textSecondary
                      : Colors.white,
                  elevation: 0,
                ),
                onPressed: isOutOfStock
                    ? null
                    : () {
                        cartProvider.addItem(
                          id: productId,
                          name: name,
                          price: unitPrice,
                          imageUrl: imageUrl,
                          quantity: _quantity,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '$_quantity $name berhasil ditambahkan ke keranjang!',
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isOutOfStock
                          ? Icons.cancel_outlined
                          : Icons.shopping_basket_outlined,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(isOutOfStock ? 'Stok Habis' : 'Tambah ke Keranjang'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
