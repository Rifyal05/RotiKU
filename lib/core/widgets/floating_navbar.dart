import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FloatingNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FloatingNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: 64,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(204),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.surfaceBorder.withAlpha(180), width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(28, 25, 23, 0.06),
                  blurRadius: 20,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Beranda'),
                _buildNavItem(1, Icons.shopping_cart_rounded, 'Keranjang'),
                _buildNavItem(2, Icons.receipt_long_rounded, 'Pesanan'),
                _buildNavItem(3, Icons.person_rounded, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? AppColors.brandAmber : AppColors.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? AppColors.brandAmber : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}