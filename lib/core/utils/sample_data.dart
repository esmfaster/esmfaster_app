import '../../features/wallet/domain/models/wallet_model.dart';

class SampleData {
  static WalletBalance getSampleWalletBalance() {
    return WalletBalance(
      balance: 1234.56,
      currency: 'USD',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 30)),
    );
  }

  static List<WalletTransaction> getSampleTransactions() {
    return [
      WalletTransaction(
        id: 'txn_001',
        userId: 'user_123',
        type: TransactionType.topUp,
        amount: 100.00,
        currency: 'USD',
        description: 'Added money via Credit Card',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: TransactionStatus.completed,
        reference: '12345',
        metadata: {'payment_method': 'credit_card', 'card_last_four': '1234'},
      ),
      WalletTransaction(
        id: 'txn_002',
        userId: 'user_123',
        type: TransactionType.payment,
        amount: 25.99,
        currency: 'USD',
        description: 'Payment for Wireless Headphones',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        status: TransactionStatus.completed,
        reference: '12346',
        metadata: {'order_id': 'ord_001', 'product_name': 'Wireless Headphones'},
      ),
      WalletTransaction(
        id: 'txn_003',
        userId: 'user_123',
        type: TransactionType.withdraw,
        amount: 50.00,
        currency: 'USD',
        description: 'Withdrawal to Bank Account',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        status: TransactionStatus.pending,
        reference: '12347',
        metadata: {'bank_account': '****1234', 'withdrawal_method': 'bank_transfer'},
      ),
      WalletTransaction(
        id: 'txn_004',
        userId: 'user_123',
        type: TransactionType.refund,
        amount: 15.50,
        currency: 'USD',
        description: 'Refund for cancelled order',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        status: TransactionStatus.completed,
        reference: '12348',
        metadata: {'order_id': 'ord_002', 'reason': 'cancelled_by_user'},
      ),
      WalletTransaction(
        id: 'txn_005',
        userId: 'user_123',
        type: TransactionType.commission,
        amount: 5.75,
        currency: 'USD',
        description: 'Commission from referral',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        status: TransactionStatus.completed,
        reference: '12349',
        metadata: {'referral_code': 'REF123', 'referred_user': 'user_456'},
      ),
      WalletTransaction(
        id: 'txn_006',
        userId: 'user_123',
        type: TransactionType.topUp,
        amount: 200.00,
        currency: 'USD',
        description: 'Added money via Mobile Money',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        status: TransactionStatus.completed,
        reference: '12350',
        metadata: {'payment_method': 'mobile_money', 'provider': 'M-Pesa'},
      ),
      WalletTransaction(
        id: 'txn_007',
        userId: 'user_123',
        type: TransactionType.payment,
        amount: 89.99,
        currency: 'USD',
        description: 'Payment for Smart Watch',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        status: TransactionStatus.failed,
        reference: '12351',
        metadata: {'order_id': 'ord_003', 'product_name': 'Smart Watch', 'failure_reason': 'insufficient_balance'},
      ),
    ];
  }
}