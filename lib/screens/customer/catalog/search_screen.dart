import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/catalog/product_model.dart';
import '../../../providers/catalog/cart_provider.dart';
import '../../../providers/catalog/catalog_provider.dart';
import 'product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  int _selectedFilterIndex = 0;

  final List<String> _filters = [
    'Harga Terendah',
    'Harga Tertinggi',
    'Stok Tersedia',
    'Roti Manis',
    'Pastry',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
    final catalogProvider = context.watch<CatalogProvider>();
    final cartProvider = context.watch<CartProvider>();

    final String query = _searchController.text.trim().toLowerCase();
    final allProducts = catalogProvider.allProducts;

    List<ProductModel> searchResults = query.isEmpty
        ? List<ProductModel>.from(allProducts)
        : allProducts
              .where((p) => p.name.toLowerCase().contains(query))
              .toList();

    if (_selectedFilterIndex == 0) {
      searchResults.sort((a, b) => a.price.compareTo(b.price));
    } else if (_selectedFilterIndex == 1) {
      searchResults.sort((a, b) => b.price.compareTo(a.price));
    } else if (_selectedFilterIndex == 2) {
      searchResults = searchResults.where((p) => p.stock > 0).toList();
    } else if (_selectedFilterIndex == 3) {
      searchResults = searchResults
          .where((p) => p.category == 'Roti Manis')
          .toList();
    } else if (_selectedFilterIndex == 4) {
      searchResults = searchResults
          .where((p) => p.category == 'Pastry')
          .toList();
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundCanvas,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.brandAmber,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              onChanged: (val) {
                                catalogProvider.searchProducts(val);
                              },
                              decoration: const InputDecoration(
                                hintText: 'Cari roti favoritmu...',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                catalogProvider.searchProducts('');
                              },
                              child: const Icon(
                                Icons.close_rounded,
                                color: AppColors.textSecondary,
                                size: 18,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 38,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.brandAmber
                            : AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : AppColors.surfaceBorder,
                        ),
                      ),
                      child: Text(
                        _filters[index],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Text(
                    'Menampilkan ${searchResults.length} Hasil ${_searchController.text.isNotEmpty ? "untuk '${_searchController.text}'" : ''}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  catalogProvider.isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(
                              color: AppColors.brandAmber,
                            ),
                          ),
                        )
                      : (searchResults.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceWhite,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.surfaceBorder,
                                  ),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(
                                      Icons.search_off_rounded,
                                      color: AppColors.textSecondary,
                                      size: 40,
                                    ),
                                    SizedBox(height: 8),
                                    Text('Roti yang kamu cari tidak ditemukan'),
                                  ],
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.72,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                    ),
                                itemCount: searchResults.length,
                                itemBuilder: (context, index) {
                                  final product = searchResults[index];
                                  final String productId = product.id;
                                  final String name = product.name;
                                  final int price = product.price;
                                  final int stock = product.stock;
                                  final String imageUrl = product.imageUrl;

                                  final isInCart = cartProvider.items.any(
                                    (item) => item.productId == productId,
                                  );
                                  final isOutOfStock = stock <= 0;

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ProductDetailScreen(
                                            product: product.toJson(),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceWhite,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: AppColors.surfaceBorder,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color.fromRGBO(
                                              28,
                                              25,
                                              23,
                                              0.04,
                                            ),
                                            blurRadius: 16,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                      top: Radius.circular(16),
                                                    ),
                                                child: CachedNetworkImage(
                                                  imageUrl: imageUrl,
                                                  height: 120,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      Container(
                                                        height: 120,
                                                        color:
                                                            AppColors.oatCream,
                                                        child: const Center(
                                                          child: SizedBox(
                                                            width: 20,
                                                            height: 20,
                                                            child: CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color: AppColors
                                                                  .brandAmber,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                  errorWidget:
                                                      (
                                                        context,
                                                        url,
                                                        error,
                                                      ) => Container(
                                                        height: 120,
                                                        color:
                                                            AppColors.oatCream,
                                                        child: const Icon(
                                                          Icons.bakery_dining,
                                                          color: AppColors
                                                              .brandAmber,
                                                          size: 40,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 8,
                                                left: 8,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: isOutOfStock
                                                        ? AppColors.danger
                                                        : const Color(
                                                            0x80000000,
                                                          ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          999,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    isOutOfStock
                                                        ? 'HABIS'
                                                        : 'Stok: $stock',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(fontSize: 14),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  _formatRupiah(price),
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.brandAmber,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                SizedBox(
                                                  width: double.infinity,
                                                  height: 34,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          isOutOfStock
                                                          ? AppColors
                                                                .disabledGrey
                                                          : (isInCart
                                                                ? AppColors
                                                                      .success
                                                                : AppColors
                                                                      .brandAmber),
                                                      foregroundColor:
                                                          isOutOfStock
                                                          ? AppColors
                                                                .textSecondary
                                                          : Colors.white,
                                                      padding: EdgeInsets.zero,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                    ),
                                                    onPressed: isOutOfStock
                                                        ? null
                                                        : () {
                                                            if (isInCart) {
                                                              cartProvider
                                                                  .removeItem(
                                                                    productId,
                                                                  );
                                                            } else {
                                                              cartProvider.addItem(
                                                                id: productId,
                                                                name: name,
                                                                price: price,
                                                                imageUrl:
                                                                    imageUrl,
                                                              );
                                                            }
                                                          },
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          isOutOfStock
                                                              ? Icons
                                                                    .cancel_outlined
                                                              : (isInCart
                                                                    ? Icons
                                                                          .check_circle_outlined
                                                                    : Icons
                                                                          .shopping_cart_outlined),
                                                          size: 16,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          isOutOfStock
                                                              ? 'Habis'
                                                              : (isInCart
                                                                    ? 'Ditambahkan'
                                                                    : 'Keranjang'),
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 12,
                                                              ),
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
                              )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
