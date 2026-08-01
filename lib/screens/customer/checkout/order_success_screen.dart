import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../catalog/customer_main_shell.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCanvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.oatCream,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.brandAmber.withAlpha(51)),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      size: 40,
                      color: AppColors.brandAmber,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Pesanan Berhasil Dibuat!',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Terima kasih telah memesan di RotiKu. Pesanan kamu sedang diverifikasi dan diproses oleh tim kami.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
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
                        Text(
                          'Rincian Transaksi',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 15),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Divider(color: AppColors.surfaceBorder),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Nomor Pesanan', style: Theme.of(context).textTheme.bodySmall),
                            Text('#RK-SUCCESS', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Pembayaran', style: Theme.of(context).textTheme.bodySmall),
                            const Text(
                              'Rp 80.000',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.brandAmber),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Metode Bayar', style: Theme.of(context).textTheme.bodySmall),
                            Text('Metode Terpilih', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Status Saat Ini', style: Theme.of(context).textTheme.bodySmall),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.oatCream,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.hourglass_empty_rounded, size: 12, color: AppColors.brandAmber),
                                  SizedBox(width: 4),
                                  Text(
                                    'Menunggu Verifikasi',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.brandAmber,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const CustomerMainShell(initialIndex: 2)),
                            (route) => false,
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Lihat Status Pesanan'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const CustomerMainShell(initialIndex: 0)),
                            (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.surfaceWhite,
                      minimumSize: const Size.fromHeight(52),
                      side: const BorderSide(color: AppColors.surfaceBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Kembali ke Beranda',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}