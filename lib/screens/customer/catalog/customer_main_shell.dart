import 'package:flutter/material.dart';
import '../../../core/widgets/floating_navbar.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import '../orders/order_history_screen.dart';
import '../../auth/profile_screen.dart';

class CustomerMainShell extends StatefulWidget {
  final int initialIndex;

  const CustomerMainShell({super.key, this.initialIndex = 0});

  @override
  State<CustomerMainShell> createState() => _CustomerMainShellState();
}

class _CustomerMainShellState extends State<CustomerMainShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    CartScreen(),
    OrderHistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: SafeArea(
        child: FloatingNavbar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
