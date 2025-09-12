import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../domain/models/wallet_model.dart';

class TransactionListItem extends StatelessWidget {
  final WalletTransaction transaction;

  const TransactionListItem({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Row(
        children: [
          // Transaction Icon
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingSmall),
            decoration: BoxDecoration(
              color: _getTransactionColor().withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getTransactionIcon(),
              color: _getTransactionColor(),
              size: AppDimensions.iconMedium,
            ),
          ),
          
          const SizedBox(width: AppDimensions.paddingMedium),
          
          // Transaction Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.type.displayName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingSmall / 2),
                Text(
                  transaction.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.paddingSmall / 2),
                Row(
                  children: [
                    Text(
                      DateFormat('MMM dd, yyyy • HH:mm').format(transaction.createdAt),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingSmall),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingSmall,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
                      ),
                      child: Text(
                        transaction.status.displayName,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _getStatusColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_isDebit() ? '-' : '+'}${currencyFormat.format(transaction.amount)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _isDebit() ? AppColors.error : AppColors.success,
                ),
              ),
              if (transaction.reference != null)
                Text(
                  '#${transaction.reference}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getTransactionIcon() {
    switch (transaction.type) {
      case TransactionType.topUp:
        return Icons.add_circle_outline;
      case TransactionType.withdraw:
        return Icons.remove_circle_outline;
      case TransactionType.transfer:
        return Icons.swap_horiz;
      case TransactionType.payment:
        return Icons.shopping_cart_outlined;
      case TransactionType.refund:
        return Icons.undo;
      case TransactionType.commission:
        return Icons.percent;
    }
  }

  Color _getTransactionColor() {
    switch (transaction.type) {
      case TransactionType.topUp:
        return AppColors.success;
      case TransactionType.withdraw:
        return AppColors.secondaryOrange;
      case TransactionType.transfer:
        return AppColors.info;
      case TransactionType.payment:
        return AppColors.primaryGreen;
      case TransactionType.refund:
        return AppColors.warning;
      case TransactionType.commission:
        return AppColors.primaryGreen;
    }
  }

  Color _getStatusColor() {
    switch (transaction.status) {
      case TransactionStatus.pending:
        return AppColors.warning;
      case TransactionStatus.completed:
        return AppColors.success;
      case TransactionStatus.failed:
        return AppColors.error;
      case TransactionStatus.cancelled:
        return AppColors.grey600;
    }
  }

  bool _isDebit() {
    return transaction.type == TransactionType.withdraw ||
           transaction.type == TransactionType.payment ||
           transaction.type == TransactionType.transfer;
  }
}