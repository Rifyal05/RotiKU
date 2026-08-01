import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';

class OrderDetailCustomerScreen extends StatelessWidget {
  final Map<String, dynamic>? order;

  const OrderDetailCustomerScreen({super.key, this.order});

  String _formatRupiah(num number) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(number);
  }

  String _formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '29 Jul 2026, 09:30';
    try {
      final dateTime = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    } catch (_) {
      return '29 Jul 2026, 09:30';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String rawId = order?['id']?.toString() ?? '';
    final String orderId = rawId.length >= 8 ? rawId.substring(0, 8).toUpperCase() : '20260729-001';
    final String status = order?['status'] ?? 'pending';
    final String createdAt = order?['created_at'] ?? '';
    final num totalPrice = order?['total_price'] ?? 80000;

    final String addressText = (order?['address_text'] != null && order!['address_text'].toString().trim().isNotEmpty)
        ? order!['address_text'].toString()
        : 'Jl. M.T. Haryono No. 52, Cikoko, Kec. Pancoran, Kota Jakarta Selatan, 12770';

    final double latitude = (order?['latitude'] as num?)?.toDouble() ?? -6.208845;
    final double longitude = (order?['longitude'] as num?)?.toDouble() ?? 106.845612;
    final String paymentMethod = (order?['payment_method']?.toString() ?? 'cashless').toUpperCase();
    final String? paymentProofUrl = order?['payment_proof_url'];

    final List<dynamic> rawItems = order?['items'] is List ? order!['items'] as List : [];

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
          'Detail Pesanan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Order ID', style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 2),
                            Text(
                              '#RK-$orderId',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.oatCream,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            status == 'pending' ? 'Menunggu Verifikasi' : (status == 'processed' ? 'Sedang Diproses' : status.toUpperCase()),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.brandAmber,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Divider(color: AppColors.surfaceBorder),
                    ),
                    _buildVerticalTimelineStep(
                      context,
                      icon: Icons.check_rounded,
                      title: 'Dibuat',
                      subtitle: _formatDate(createdAt),
                      isDone: true,
                      isActive: false,
                      isLast: false,
                    ),
                    _buildVerticalTimelineStep(
                      context,
                      icon: Icons.sync_rounded,
                      title: 'Diproses',
                      subtitle: status == 'processed' ? 'Saat ini' : (status == 'pending' ? null : 'Selesai'),
                      isDone: status == 'processed' || status == 'shipped' || status == 'completed',
                      isActive: status == 'processed',
                      isLast: false,
                    ),
                    _buildVerticalTimelineStep(
                      context,
                      icon: Icons.local_shipping_outlined,
                      title: 'Dikirim',
                      subtitle: status == 'shipped' ? 'Dalam perjalanan' : null,
                      isDone: status == 'shipped' || status == 'completed',
                      isActive: status == 'shipped',
                      isLast: false,
                    ),
                    _buildVerticalTimelineStep(
                      context,
                      icon: Icons.home_outlined,
                      title: 'Selesai',
                      subtitle: status == 'completed' ? 'Telah diterima' : null,
                      isDone: status == 'completed',
                      isActive: status == 'completed',
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.brandAmber,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Alamat Pengiriman (GPS)',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 140,
                        width: double.infinity,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(latitude, longitude),
                            initialZoom: 15.0,
                            interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.rotiku.app',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(latitude, longitude),
                                  width: 40,
                                  height: 40,
                                  child: const Icon(
                                    Icons.location_on_rounded,
                                    color: AppColors.danger,
                                    size: 36,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      addressText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          color: AppColors.brandAmber,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Item yang Dipesan',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (rawItems.isEmpty) ...[
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.oatCream,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.bakery_dining_rounded, color: AppColors.brandAmber, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Croissant Butter Almond', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14)),
                                Text('2x', style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          Text(_formatRupiah(48000), style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14)),
                        ],
                      ),
                    ] else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: rawItems.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = rawItems[index] as Map<String, dynamic>;
                          final itemName = item['name'] ?? 'Roti';
                          final int itemQty = (item['quantity'] as num?)?.toInt() ?? 1;
                          final int itemPrice = (item['price'] as num?)?.toInt() ?? 0;
                          final int itemSubtotal = itemPrice * itemQty;
                          final String itemImageUrl = item['imageUrl'] ?? item['image_url'] ?? '';

                          return Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: itemImageUrl,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) {
                                    return Container(
                                      width: 44,
                                      height: 44,
                                      color: AppColors.oatCream,
                                      child: const Icon(Icons.bakery_dining, color: AppColors.brandAmber, size: 20),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(itemName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
                                    Text('${itemQty}x', style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                ),
                              ),
                              Text(_formatRupiah(itemSubtotal), style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14)),
                            ],
                          );
                        },
                      ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Divider(color: AppColors.surfaceBorder),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal', style: Theme.of(context).textTheme.bodySmall),
                        Text(_formatRupiah(totalPrice - 10000), style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ongkir', style: Theme.of(context).textTheme.bodySmall),
                        Text(_formatRupiah(10000), style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Bayar', style: Theme.of(context).textTheme.bodyLarge),
                        Text(
                          _formatRupiah(totalPrice),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.brandAmber,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.payment_rounded,
                          color: AppColors.brandAmber,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Metode Pembayaran',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (paymentProofUrl != null && paymentProofUrl.isNotEmpty) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: paymentProofUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) {
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              paymentMethod == 'COD' ? 'Cash on Delivery (COD)' : 'Transfer Bank Manual (BCA)',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  paymentMethod == 'COD' ? Icons.check_circle_rounded : Icons.check_circle_rounded,
                                  color: AppColors.success,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  paymentMethod == 'COD' ? 'COD Aktif' : 'Bukti Terunggah',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalTimelineStep(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String? subtitle,
        required bool isDone,
        required bool isActive,
        required bool isLast,
      }) {
    Color iconBgColor = AppColors.disabledGrey;
    Color iconColor = AppColors.textSecondary;

    if (isDone) {
      iconBgColor = AppColors.success;
      iconColor = Colors.white;
    } else if (isActive) {
      iconBgColor = AppColors.brandAmber;
      iconColor = Colors.white;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isDone ? AppColors.success : AppColors.surfaceBorder,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 14,
                      fontWeight: isDone || isActive ? FontWeight.bold : FontWeight.w500,
                      color: isDone || isActive ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}