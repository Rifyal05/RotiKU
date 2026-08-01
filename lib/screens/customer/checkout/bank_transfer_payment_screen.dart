import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/catalog/cart_provider.dart';
import '../../../providers/checkout/checkout_provider.dart';
import 'order_success_screen.dart';

class BankTransferPaymentScreen extends StatefulWidget {
  const BankTransferPaymentScreen({super.key});

  @override
  State<BankTransferPaymentScreen> createState() => _BankTransferPaymentScreenState();
}

class _BankTransferPaymentScreenState extends State<BankTransferPaymentScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile != null && mounted) {
      context.read<CheckoutProvider>().setProofImage(File(pickedFile.path));
    }
  }

  Future<void> _submitBankOrder() async {
    final checkoutProvider = context.read<CheckoutProvider>();
    final cartProvider = context.read<CartProvider>();
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    if (checkoutProvider.selectedProofImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap unggah foto bukti transfer terlebih dahulu'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

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
          content: Text(checkoutProvider.errorMessage ?? 'Gagal mengunggah bukti pembayaran'),
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
          'Transfer Bank Manual',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00529C),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'BCA',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('Bank BCA', style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '123-456-7890',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text('a.n. PT RotiKu Indonesia', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.oatCream,
                            foregroundColor: AppColors.brandAmber,
                            minimumSize: const Size(70, 36),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          onPressed: () {
                            Clipboard.setData(const ClipboardData(text: '1234567890'));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Nomor rekening disalin!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                          child: const Text('Salin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.brandAmber),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Unggah Foto Struk Transfer', style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 12),
                      checkoutProvider.selectedProofImage != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.file(
                              checkoutProvider.selectedProofImage!,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Container(
                              height: 160,
                              color: const Color(0x33000000),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'Foto Struk Terunggah',
                                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                          : Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, color: AppColors.brandAmber, size: 36),
                            SizedBox(height: 8),
                            Text(
                              'Ketuk untuk memilih foto bukti bayar',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Format gambar .JPG/.PNG (Maksimal 5MB)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: checkoutProvider.isLoading ? null : _submitBankOrder,
                child: checkoutProvider.isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Text('Kirim Bukti Pembayaran'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}