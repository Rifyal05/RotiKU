import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/catalog/catalog_provider.dart';
import '../../../providers/catalog/cart_provider.dart';
import '../../../providers/user/auth_provider.dart';
import 'search_screen.dart';
import 'product_detail_screen.dart';
import '../notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _bannerController = PageController();
  final ScrollController _scrollController = ScrollController();
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  final List<Map<String, String>> _bannerPromos = [
    {
      'title': 'Roti Fresh\nSetiap Hari',
      'subtitle': 'Dipanggang langsung dari oven dengan bahan kualitas terbaik',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBhVkDtfunZWxQiXaVa6t4F5rJg3Nnl9ycSPnCmU0TJ3NYakEwqpYwGXLt4LF2D2gwOS_NJTubSwIJ5UQ0vH0Ctmeh-3cTQlH7IVL1-_tvktqKcjg7slNxHSQ9ed2Ya5UklCnJujD6M4OPpS_F_HkhHFs3E9Sw8vegzXHMcSbBuhGwIWmkMcYEnJ6wVYKUBSDOT3plfwakj6DIVxyRv7Fuqr7HLUolCpZ5EOVdS9M6MZrUaMy3peDEW',
    },
    {
      'title': 'Anugerah Pastry\nMentega Murni',
      'subtitle': '100% mentega Prancis asli tanpa bahan pengawet',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCcsfwcES2Bur09isSYifHd9D_OqcJixOOCifatGluluWGuBtmI3_fG5yWMrwfrkg7vyN8gU_daqhdlHBKdn0WSaGVbNvegB8eW-i1_7zmswJlhQp7AXmPDznBW21GWjWxyfZNeEc1EMpmqz_lv6M3CGSGYwGl4izLj55zf1qAU5x7FQ4Y-PMBFFxQRDiLc_rfw5JPelh51dnh17UH1WwOXHWhRTx7EMo7mrC-bbdnwdSiPLsbpN22U',
    },
    {
      'title': 'Roti Sourdough\nAdonan Alami',
      'subtitle': 'Fermentasi lambat 24 jam dengan ragi liar alami, menghasilkan roti sehat yang ramah untuk pencernaan.',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDDcl0SDriwR_Ivb74XZqe4sC0_z9yPEe6M-Z2kImiTnR4CCuPH-f6hWereHEWCL_RFe1J_BeVZXjEsZjABm0MKkl_iRXvJs9ug1t-eJmtghS0iN7Hc1BisHtNH9VWbJE6h-ZvmqMjpaHb1zAxiNpcNJVxRRSJITvPV-4jtJ78jEaDpD6hAnyObA8zvL-OAi7M3crkmaFGr2gfLV0l9p0-Cr0p5sFzYt6MVPBNjqjX0e6Hf2uoy4ICh',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().fetchProducts();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<CatalogProvider>().fetchMoreProducts();
    }
  }

  void _startAutoSlide() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        int nextPage = (_currentBannerIndex + 1) % _bannerPromos.length;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final catalogProvider = context.watch<CatalogProvider>();
    final cartProvider = context.watch<CartProvider>();

    final firstName = authProvider.userName.split(' ').first;

    return Scaffold(
      backgroundColor: AppColors.backgroundCanvas,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.brandAmber,
          backgroundColor: AppColors.surfaceWhite,
          onRefresh: () async {
            await context.read<CatalogProvider>().fetchProducts(isRefresh: true);
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, $firstName 👋',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.brandAmber,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Mau makan roti apa hari ini?',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const NotificationScreen()),
                            );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceWhite,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.surfaceBorder),
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: AppColors.textPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: authProvider.userAvatarUrl != null
                                ? Image.network(
                              authProvider.userAvatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset('assets/images/rotiku_logo.png', fit: BoxFit.cover);
                              },
                            )
                                : Image.asset('assets/images/rotiku_logo.png', fit: BoxFit.cover),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    );
                  },
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 22),
                        const SizedBox(width: 12),
                        Text(
                          'Cari roti favoritmu...',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 140,
                  child: PageView.builder(
                    controller: _bannerController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentBannerIndex = index;
                      });
                    },
                    itemCount: _bannerPromos.length,
                    itemBuilder: (context, index) {
                      final promo = _bannerPromos[index];
                      return Container(
                        margin: const EdgeInsets.only(right: 2),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.brandAmber,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    promo['title']!,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      height: 1.2,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    promo['subtitle']!,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.oatCream,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                promo['image']!,
                                width: 90,
                                height: 85,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_bannerPromos.length, (index) {
                    final isCurrent = _currentBannerIndex == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isCurrent ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isCurrent ? AppColors.brandAmber : AppColors.brandAmber.withAlpha(76),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: catalogProvider.categories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final isSelected = catalogProvider.selectedCategoryIndex == index;
                      return GestureDetector(
                        onTap: () {
                          catalogProvider.selectCategory(index);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.brandAmber : AppColors.surfaceWhite,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : AppColors.surfaceBorder,
                            ),
                          ),
                          child: Text(
                            catalogProvider.categories[index],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                _buildProductSection(context, catalogProvider, cartProvider),
                if (catalogProvider.isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.brandAmber, strokeWidth: 2),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductSection(
      BuildContext context,
      CatalogProvider catalogProvider,
      CartProvider cartProvider,
      ) {
    if (catalogProvider.isLoading) {
      return Container(
        height: 200,
        width: double.infinity,
        alignment: Alignment.center,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.brandAmber),
            SizedBox(height: 12),
            Text('Memuat Katalog Roti...', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      );
    }

    if (catalogProvider.errorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 44),
            const SizedBox(height: 12),
            const Text(
              'Gagal Memuat Katalog Roti',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              catalogProvider.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(140, 40),
              ),
              onPressed: () {
                catalogProvider.fetchProducts(isRefresh: true);
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    final products = catalogProvider.filteredProducts;

    if (products.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded, color: AppColors.textSecondary, size: 40),
            const SizedBox(height: 8),
            Text(
              'Tidak ada roti pada kategori ini',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final String productId = product['id']?.toString() ?? '$index';
        final String name = product['name'] ?? 'Roti';
        final int price = (product['price'] as num?)?.toInt() ?? 0;
        final int stock = (product['stock'] as num?)?.toInt() ?? 0;
        final String imageUrl = product['image_url'] ?? '';

        final isInCart = cartProvider.items.any((item) => item.productId == productId);
        final isOutOfStock = stock <= 0;

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
            );
          },
          child: Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 120,
                          color: AppColors.oatCream,
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandAmber),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 120,
                          color: AppColors.oatCream,
                          child: const Icon(Icons.bakery_dining, color: AppColors.brandAmber, size: 40),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOutOfStock ? AppColors.danger : const Color(0x80000000),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          isOutOfStock ? 'HABIS' : 'Stok: $stock',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp $price',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brandAmber,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isOutOfStock
                                ? AppColors.disabledGrey
                                : (isInCart ? AppColors.success : AppColors.brandAmber),
                            foregroundColor: isOutOfStock ? AppColors.textSecondary : Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          onPressed: isOutOfStock
                              ? null
                              : () {
                            if (isInCart) {
                              cartProvider.removeItem(productId);
                            } else {
                              cartProvider.addItem(
                                id: productId,
                                name: name,
                                price: price,
                                imageUrl: imageUrl,
                              );
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isOutOfStock
                                    ? Icons.cancel_outlined
                                    : (isInCart ? Icons.check_circle_outlined : Icons.shopping_cart_outlined),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isOutOfStock ? 'Habis' : (isInCart ? 'Ditambahkan' : 'Keranjang'),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}