import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> notifications = [
      // {
      //   'title': 'Pesanan Sedang Dikirim',
      //   'body': 'Pesanan #RK-20260729-001 sedang dalam perjalanan ke rumah kamu oleh kurir RotiKu.',
      //   'time': '10 Menit Lalu',
      //   'type': 'shipping',
      // },
      // {
      //   'title': 'Pembayaran Berhasil Terverifikasi',
      //   'body': 'Bukti transfer kamu untuk pesanan #RK-20260729-001 berhasil diverifikasi. Roti sedang disiapkan!',
      //   'time': '1 Jam Lalu',
      //   'type': 'payment',
      // },
      // {
      //   'title': 'Promo Spesial Croissant',
      //   'body': 'Cobain menu baru Croissant Butter Almond yang dipanggang segar pagi ini menggunakan mentega murni Prancis!',
      //   'time': '1 Hari Lalu',
      //   'type': 'promo',
      // }
    ];

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
        title: const Text(
          'Notifikasi',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: notifications.isEmpty
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.oatCream,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_off_outlined,
                    color: AppColors.brandAmber,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tidak Ada Notifikasi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Semua pemberitahuan status pesanan dan penawaran spesial RotiKu akan muncul di sini.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        )
            : ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final notif = notifications[index];
            IconData icon = Icons.notifications_none_rounded;
            Color iconColor = AppColors.brandAmber;

            if (notif['type'] == 'shipping') {
              icon = Icons.local_shipping_outlined;
              iconColor = const Color(0xFF0284C7);
            } else if (notif['type'] == 'payment') {
              icon = Icons.check_circle_outline_rounded;
              iconColor = AppColors.success;
            } else if (notif['type'] == 'promo') {
              icon = Icons.star_outline_rounded;
              iconColor = AppColors.brandAmber;
            }

            return Container(
              padding: const EdgeInsets.all(16),
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCanvas,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              notif['title']!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              notif['time']!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notif['body']!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}