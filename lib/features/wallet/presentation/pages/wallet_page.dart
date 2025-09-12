import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/strings.dart';
import '../../domain/models/wallet_model.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/wallet_action_button.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(LoadWalletBalance());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.wallet),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<WalletBloc>().add(RefreshWallet());
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<WalletBloc>().add(RefreshWallet());
        },
        child: BlocConsumer<WalletBloc, WalletState>(
          listener: (context, state) {
            if (state is WalletError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            } else if (state is WalletTransactionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transaction completed successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is WalletLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                ),
              );
            }

            if (state is WalletLoaded) {
              return _buildWalletContent(context, state);
            }

            if (state is WalletError) {
              return _buildErrorWidget(context, state.message);
            }

            return _buildEmptyWidget();
          },
        ),
      ),
    );
  }

  Widget _buildWalletContent(BuildContext context, WalletLoaded state) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wallet Balance Card
          WalletBalanceCard(balance: state.balance),
          
          const SizedBox(height: AppDimensions.paddingLarge),
          
          // Action Buttons
          _buildActionButtons(context),
          
          const SizedBox(height: AppDimensions.paddingLarge),
          
          // Transaction History
          _buildTransactionHistory(context, state.transactions),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: WalletActionButton(
            icon: Icons.add,
            title: AppStrings.addBalance,
            color: AppColors.primaryGreen,
            onTap: () => _showAddBalanceDialog(context),
          ),
        ),
        const SizedBox(width: AppDimensions.paddingMedium),
        Expanded(
          child: WalletActionButton(
            icon: Icons.remove,
            title: AppStrings.withdraw,
            color: AppColors.secondaryOrange,
            onTap: () => _showWithdrawDialog(context),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionHistory(BuildContext context, List<WalletTransaction> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.transactionHistory,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        
        if (transactions.isEmpty)
          _buildEmptyTransactions()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              color: AppColors.grey300,
            ),
            itemBuilder: (context, index) {
              return TransactionListItem(
                transaction: transactions[index],
              );
            },
          ),
      ],
    );
  }

  Widget _buildEmptyTransactions() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: AppDimensions.iconExtraLarge,
            color: AppColors.grey500,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: AppDimensions.iconExtraLarge,
            color: AppColors.error,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          ElevatedButton(
            onPressed: () {
              context.read<WalletBloc>().add(RefreshWallet());
            },
            child: const Text(AppStrings.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return const Center(
      child: Text('Welcome to your wallet'),
    );
  }

  void _showAddBalanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AddBalanceDialog(),
    );
  }

  void _showWithdrawDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _WithdrawDialog(),
    );
  }
}

class _AddBalanceDialog extends StatefulWidget {
  @override
  State<_AddBalanceDialog> createState() => _AddBalanceDialogState();
}

class _AddBalanceDialogState extends State<_AddBalanceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _paymentMethod = 'card';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.addBalance),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value!);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: const InputDecoration(labelText: 'Payment Method'),
              items: const [
                DropdownMenuItem(value: 'card', child: Text('Credit Card')),
                DropdownMenuItem(value: 'bank', child: Text('Bank Transfer')),
                DropdownMenuItem(value: 'mobile', child: Text('Mobile Money')),
              ],
              onChanged: (value) => setState(() => _paymentMethod = value!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: _submitAddBalance,
          child: const Text(AppStrings.confirm),
        ),
      ],
    );
  }

  void _submitAddBalance() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.parse(_amountController.text);
      context.read<WalletBloc>().add(AddBalanceEvent(
        amount: amount,
        paymentMethod: _paymentMethod,
      ));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}

class _WithdrawDialog extends StatefulWidget {
  @override
  State<_WithdrawDialog> createState() => _WithdrawDialogState();
}

class _WithdrawDialogState extends State<_WithdrawDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _accountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.withdraw),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value!);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            TextFormField(
              controller: _accountController,
              decoration: const InputDecoration(
                labelText: 'Bank Account Number',
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter bank account number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: _submitWithdraw,
          child: const Text(AppStrings.confirm),
        ),
      ],
    );
  }

  void _submitWithdraw() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.parse(_amountController.text);
      context.read<WalletBloc>().add(WithdrawBalanceEvent(
        amount: amount,
        bankAccount: _accountController.text,
      ));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _accountController.dispose();
    super.dispose();
  }
}