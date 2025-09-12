import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/products/presentation/pages/products_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/wallet/presentation/pages/wallet_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../widgets/bottom_navigation.dart';
import '../../core/constants/colors.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ProductsPage(),
    const OrdersPage(),
    const WalletPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: MainBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
      floatingActionButton: _currentIndex == 0 ? _buildFloatingActionButton() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget? _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _quickScan,
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: AppColors.white,
      icon: const Icon(Icons.qr_code_scanner),
      label: const Text('Quick Scan'),
      elevation: 4,
    );
  }

  void _quickScan() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Quick Scan feature - QR code scanner'),
        backgroundColor: AppColors.primaryGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }
}