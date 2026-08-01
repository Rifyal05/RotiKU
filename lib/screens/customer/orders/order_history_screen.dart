import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/orders/order_provider.dart';
import 'order_detail_customer_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = [
    'Semua Pesanan',
    'pending',
    'processed',
    'shipped',
    'completed',
  ];

  final List<String> _filterLabels = [
    'Semua Pesanan',
    'Menunggu',
    'Diproses',
    'Dikirim',
    'Selesai',
  ];

  String _formatRupiah(num number) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(number);
  }

  String _formatDate(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    } catch (_) {
      return '29 Jul 2026';
    }
  }

  Widget _buildStatusBadge(String status) {
    String label = 'Menunggu';
    Color bgColor = AppColors.oatCream;
    Color textColor = AppColors.brandAmber;

    if (status == 'processed') {
      label = 'Sedang Diproses';
      bgColor = AppColors.oatCream;
      textColor = AppColors.brandAmber;
    } else if (status == 'shipped') {
      label = 'Dalam Pengiriman';
      bgColor = const Color(0xFFE0F2FE);
      textColor = const Color(0xFF0284C7);
    } else if (status == 'completed') {
      label = 'Selesai';
      bgColor = const Color(0xFFD1FAE5);
      textColor = AppColors.success;
    } else if (status == 'cancelled') {
      label = 'Dibatalkan';
      bgColor = const Color(0xFFFEE2E2);
      textColor = AppColors.danger;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCanvas,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Riwayat Pesanan',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 38,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _filterLabels.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilterIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilterIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.brandAmber : AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : AppColors.surfaceBorder,
                        ),
                      ),
                      child: Text(
                        _filterLabels[index],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: orderProvider.fetchOrdersDirectly(currentUserId),
                builder: (context, futureSnapshot) {
                  return StreamBuilder<List<Map<String, dynamic>>>(
                    stream: orderProvider.getCustomerOrdersStream(currentUserId),
                    builder: (context, streamSnapshot) {
                      if (!futureSnapshot.hasData && streamSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppColors.brandAmber),
                        );
                      }

                      var orders = streamSnapshot.data ?? futureSnapshot.data ?? [];

                      if (_selectedFilterIndex != 0) {
                        final selectedStatus = _filters[_selectedFilterIndex];
                        orders = orders.where((o) => o['status'] == selectedStatus).toList();
                      }

                      if (orders.isEmpty) {
                        return RefreshIndicator(
                          color: AppColors.brandAmber,
                          backgroundColor: AppColors.surfaceWhite,
                          onRefresh: () async {
                            setState(() {});
                          },
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(24.0),
                            children: [
                              const SizedBox(height: 60),
                              Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceWhite,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.surfaceBorder),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(Icons.receipt_long_outlined, color: AppColors.textSecondary, size: 48),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Belum Ada Riwayat Pesanan',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Pesanan yang kamu buat akan muncul di sini secara realtime.',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        color: AppColors.brandAmber,
                        backgroundColor: AppColors.surfaceWhite,
                        onRefresh: () async {
                          setState(() {});
                        },
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: orders.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            final String orderId = order['id']?.toString().substring(0, 8).toUpperCase() ?? '00000000';
                            final String status = order['status'] ?? 'pending';
                            final String createdAt = order['created_at'] ?? '';
                            final num totalPrice = order['total_price'] ?? 0;

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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(_formatDate(createdAt), style: Theme.of(context).textTheme.bodySmall),
                                          const SizedBox(height: 2),
                                          Text(
                                            '#RK-$orderId',
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      _buildStatusBadge(status),
                                    ],
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12.0),
                                    child: Divider(color: AppColors.surfaceBorder),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          color: AppColors.oatCream,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.bakery_dining_rounded, color: AppColors.brandAmber, size: 28),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Pesanan RotiKu',
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              'Metode: ${order['payment_method']?.toString().toUpperCase() ?? 'COD'}',
                                              style: Theme.of(context).textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12.0),
                                    child: Divider(color: AppColors.surfaceBorder),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Total Belanja', style: Theme.of(context).textTheme.bodySmall),
                                          Text(
                                            _formatRupiah(totalPrice),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.brandAmber,
                                            ),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => OrderDetailCustomerScreen(order: order),
                                            ),
                                          );
                                        },
                                        behavior: HitTestBehavior.opaque,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Text(
                                                'Detail',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.brandAmber,
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.brandAmber),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}