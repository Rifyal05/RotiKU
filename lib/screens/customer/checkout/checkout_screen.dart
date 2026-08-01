import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/catalog/cart_provider.dart';
import '../../../providers/checkout/checkout_provider.dart';
import 'qris_payment_screen.dart';
import 'bank_transfer_payment_screen.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoadingLocation = false;
  bool _hasLocationBeenDetected = false;
  late MapController _mapController;
  final Geocoding _geocoding = Geocoding();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  Future<void> _fetchGpsLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin lokasi ditolak permanen. Harap aktifkan di pengaturan HP.'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {

        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sensor GPS HP kamu mati. Harap aktifkan GPS Anda terlebih dahulu.'),
              backgroundColor: AppColors.danger,
            ),
          );
          return;
        }

        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );

        setState(() {
          _hasLocationBeenDetected = true;
        });

        await _updateLocationFromCoordinates(position.latitude, position.longitude);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mendapatkan lokasi GPS: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _updateLocationFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await _geocoding.placemarkFromCoordinates(lat, lng);
      String formattedAddress = 'Jl. M.T. Haryono No. 52, Cikoko, Kec. Pancoran, Kota Jakarta Selatan, 12770';

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        formattedAddress =
        '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''} ${place.postalCode ?? ''}';
      }

      if (!mounted) return;

      context.read<CheckoutProvider>().updateLocation(
        lat: lat,
        lng: lng,
        address: formattedAddress,
      );

      _mapController.move(LatLng(lat, lng), 15.0);
    } catch (e) {
      if (!mounted) return;
      context.read<CheckoutProvider>().updateLocation(
        lat: lat,
        lng: lng,
        address: 'Jl. M.T. Haryono No. 52, Cikoko, Kec. Pancoran, Kota Jakarta Selatan, 12770',
      );
    }
  }

  Future<void> _processCheckout() async {
    if (!_hasLocationBeenDetected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap tekan "Lokasi Saya" untuk mendeteksi lokasi pengiriman terlebih dahulu'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final checkoutProvider = context.read<CheckoutProvider>();
    final cartProvider = context.read<CartProvider>();
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    if (checkoutProvider.paymentMethodIndex == 0) {
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
    } else if (checkoutProvider.paymentMethodIndex == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const QrisPaymentScreen()),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const BankTransferPaymentScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkoutProvider = context.watch<CheckoutProvider>();
    final cartProvider = context.watch<CartProvider>();

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
          'Checkout & Pengiriman',
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
                        Text(
                          'Lokasi Pengiriman (GPS)',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 15),
                        ),
                        GestureDetector(
                          onTap: _isLoadingLocation ? null : _fetchGpsLocation,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.oatCream,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              children: [
                                _isLoadingLocation
                                    ? const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.brandAmber,
                                  ),
                                )
                                    : const Icon(Icons.my_location_rounded, size: 14, color: AppColors.brandAmber),
                                const SizedBox(width: 4),
                                const Text(
                                  'Lokasi Saya',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.brandAmber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (!_hasLocationBeenDetected)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundCanvas,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.location_off_outlined, color: AppColors.textSecondary, size: 28),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Tekan "Lokasi Saya" di atas untuk mendeteksi posisi GPS rumah kamu.',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 130,
                          width: double.infinity,
                          child: FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: LatLng(checkoutProvider.latitude, checkoutProvider.longitude),
                              initialZoom: 15.0,
                              onTap: (tapPosition, point) {
                                _updateLocationFromCoordinates(point.latitude, point.longitude);
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.rotiku.app',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(checkoutProvider.latitude, checkoutProvider.longitude),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundCanvas,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Lat: ${checkoutProvider.latitude.toStringAsFixed(6)}, Long: ${checkoutProvider.longitude.toStringAsFixed(6)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        checkoutProvider.addressText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih Metode Pembayaran',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentOption(
                      0,
                      'Cash on Delivery (COD)',
                      'Bayar tunai saat roti sampai',
                      checkoutProvider,
                    ),
                    const SizedBox(height: 8),
                    _buildPaymentOption(
                      1,
                      'QRIS Instant (Gopay/OVO/ShopeePay)',
                      'Scan QR & verifikasi otomatis',
                      checkoutProvider,
                    ),
                    const SizedBox(height: 8),
                    _buildPaymentOption(
                      2,
                      'Transfer Bank Manual (BCA)',
                      'Transfer & upload bukti bayar',
                      checkoutProvider,
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal Produk (${cartProvider.totalItemsCount} Item)', style: Theme.of(context).textTheme.bodySmall),
                        Text('Rp ${cartProvider.subtotalPrice}', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ongkir (Flat)', style: Theme.of(context).textTheme.bodySmall),
                        Text('Rp ${cartProvider.shippingFee}', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Divider(color: AppColors.surfaceBorder),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Pembayaran', style: Theme.of(context).textTheme.bodyLarge),
                        Text(
                          'Rp ${cartProvider.grandTotalPrice}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.brandAmber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: checkoutProvider.isLoading ? null : _processCheckout,
                      child: checkoutProvider.isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                          : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Lanjut ke Pembayaran'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
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

  Widget _buildPaymentOption(
      int index,
      String title,
      String subtitle,
      CheckoutProvider checkoutProvider,
      ) {
    final isSelected = checkoutProvider.paymentMethodIndex == index;
    return GestureDetector(
      onTap: () {
        checkoutProvider.selectPaymentMethod(index);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFFBEB) : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.brandAmber : AppColors.surfaceBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.brandAmber : AppColors.textSecondary,
                  width: isSelected ? 6 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.brandAmber : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}