import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';

class BalanceSummary extends StatelessWidget {
  const BalanceSummary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGreen,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                'Total Balance',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.visibility_outlined,
                color: AppColors.white.withOpacity(0.8),
                size: AppDimensions.iconMedium,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            '\$1,234.56',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingSmall,
                  vertical: AppDimensions.paddingSmall / 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      size: AppDimensions.iconSmall,
                      color: AppColors.white,
                    ),
                    const SizedBox(width: AppDimensions.paddingSmall / 2),
                    Text(
                      '+\$125.30',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              Text(
                'this month',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}