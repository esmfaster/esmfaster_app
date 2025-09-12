import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/strings.dart';
import '../widgets/feature_card.dart';
import '../widgets/balance_summary.dart';
import '../widgets/quick_actions.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Handle notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(context),
            
            const SizedBox(height: AppDimensions.paddingLarge),
            
            // Balance Summary
            const BalanceSummary(),
            
            const SizedBox(height: AppDimensions.paddingLarge),
            
            // Quick Actions
            const QuickActions(),
            
            const SizedBox(height: AppDimensions.paddingLarge),
            
            // Features Grid
            _buildFeaturesGrid(context),
            
            const SizedBox(height: AppDimensions.paddingLarge),
            
            // Recent Activity
            _buildRecentActivity(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGreen.withOpacity(0.1),
            AppColors.secondaryOrange.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            'Manage your e-commerce experience with ease',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Features',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: AppDimensions.paddingMedium,
          crossAxisSpacing: AppDimensions.paddingMedium,
          childAspectRatio: 1.1,
          children: [
            FeatureCard(
              icon: Icons.shopping_bag_outlined,
              title: AppStrings.products,
              description: 'Browse products',
              color: AppColors.primaryGreen,
              onTap: () => _navigateToProducts(context),
            ),
            FeatureCard(
              icon: Icons.receipt_long_outlined,
              title: AppStrings.orders,
              description: 'Track orders',
              color: AppColors.secondaryOrange,
              onTap: () => _navigateToOrders(context),
            ),
            FeatureCard(
              icon: Icons.account_balance_wallet_outlined,
              title: AppStrings.wallet,
              description: 'Manage wallet',
              color: AppColors.success,
              onTap: () => _navigateToWallet(context),
            ),
            FeatureCard(
              icon: Icons.map_outlined,
              title: AppStrings.map,
              description: 'Find locations',
              color: AppColors.info,
              onTap: () => _navigateToMap(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to activity page
              },
              child: Text(
                AppStrings.viewAll,
                style: TextStyle(
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        _buildActivityItem(
          context,
          'Order Placed',
          'Order #12345 has been placed successfully',
          Icons.shopping_cart_outlined,
          AppColors.success,
          '2 hours ago',
        ),
        _buildActivityItem(
          context,
          'Payment Received',
          'Wallet credited with \$50.00',
          Icons.account_balance_wallet_outlined,
          AppColors.primaryGreen,
          '5 hours ago',
        ),
        _buildActivityItem(
          context,
          'Product Viewed',
          'You viewed "Wireless Headphones"',
          Icons.visibility_outlined,
          AppColors.info,
          '1 day ago',
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    String time,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey300.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingSmall),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: AppDimensions.iconMedium,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingSmall / 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToProducts(BuildContext context) {
    // Navigate to products page
    Navigator.pushNamed(context, '/products');
  }

  void _navigateToOrders(BuildContext context) {
    // Navigate to orders page
    Navigator.pushNamed(context, '/orders');
  }

  void _navigateToWallet(BuildContext context) {
    // Navigate to wallet page
    Navigator.pushNamed(context, '/wallet');
  }

  void _navigateToMap(BuildContext context) {
    // Navigate to map page
    Navigator.pushNamed(context, '/map');
  }
}