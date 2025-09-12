import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                Icons.add_circle_outline,
                'Add Money',
                AppColors.primaryGreen,
                () => _handleAddMoney(context),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              child: _buildActionButton(
                context,
                Icons.send_outlined,
                'Send Money',
                AppColors.secondaryOrange,
                () => _handleSendMoney(context),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              child: _buildActionButton(
                context,
                Icons.qr_code_scanner_outlined,
                'Scan QR',
                AppColors.info,
                () => _handleScanQR(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey300.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
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
            const SizedBox(height: AppDimensions.paddingSmall),
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _handleAddMoney(BuildContext context) {
    // Navigate to add money page or show dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add Money feature'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  void _handleSendMoney(BuildContext context) {
    // Navigate to send money page or show dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Send Money feature'),
        backgroundColor: AppColors.secondaryOrange,
      ),
    );
  }

  void _handleScanQR(BuildContext context) {
    // Open QR scanner
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR Scanner feature'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}