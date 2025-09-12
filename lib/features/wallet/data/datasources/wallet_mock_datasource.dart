import 'dart:async';
import 'dart:math';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/sample_data.dart';
import '../models/wallet_data_model.dart';
import 'wallet_remote_datasource.dart';

class WalletMockDataSource implements WalletRemoteDataSource {
  final Random _random = Random();

  @override
  Future<WalletBalanceModel> getWalletBalance() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));
    
    // Simulate occasional network error (5% chance)
    if (_random.nextInt(100) < 5) {
      throw const NetworkException('Mock network error occurred');
    }

    final sampleBalance = SampleData.getSampleWalletBalance();
    return WalletBalanceModel(
      balance: sampleBalance.balance,
      currency: sampleBalance.currency,
      lastUpdated: sampleBalance.lastUpdated,
    );
  }

  @override
  Future<List<WalletTransactionModel>> getTransactionHistory({
    int page = 1,
    int limit = 20,
  }) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(700)));
    
    // Simulate occasional network error (3% chance)
    if (_random.nextInt(100) < 3) {
      throw const NetworkException('Mock network error occurred');
    }

    final sampleTransactions = SampleData.getSampleTransactions();
    
    // Simulate pagination
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    
    final paginatedTransactions = sampleTransactions
        .skip(startIndex)
        .take(limit)
        .map((transaction) => WalletTransactionModel(
              id: transaction.id,
              userId: transaction.userId,
              type: transaction.type,
              amount: transaction.amount,
              currency: transaction.currency,
              description: transaction.description,
              createdAt: transaction.createdAt,
              status: transaction.status,
              reference: transaction.reference,
              metadata: transaction.metadata,
            ))
        .toList();

    return paginatedTransactions;
  }

  @override
  Future<WalletTransactionModel> addBalance({
    required double amount,
    required String paymentMethod,
  }) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 1000 + _random.nextInt(2000)));
    
    // Simulate validation error for very small amounts
    if (amount < 1.0) {
      throw const ValidationException('Minimum amount is \$1.00');
    }
    
    // Simulate occasional payment failure (10% chance)
    if (_random.nextInt(100) < 10) {
      throw const ServerException('Payment processing failed');
    }

    // Generate mock transaction
    final transactionId = 'txn_${DateTime.now().millisecondsSinceEpoch}';
    final reference = '${10000 + _random.nextInt(90000)}';
    
    return WalletTransactionModel(
      id: transactionId,
      userId: 'user_123',
      type: TransactionType.topUp,
      amount: amount,
      currency: 'USD',
      description: 'Added money via $paymentMethod',
      createdAt: DateTime.now(),
      status: TransactionStatus.completed,
      reference: reference,
      metadata: {
        'payment_method': paymentMethod,
        'processed_at': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  Future<WalletTransactionModel> withdrawBalance({
    required double amount,
    required String bankAccount,
  }) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 1500 + _random.nextInt(2500)));
    
    // Simulate validation error for very small amounts
    if (amount < 5.0) {
      throw const ValidationException('Minimum withdrawal amount is \$5.00');
    }
    
    // Simulate insufficient balance error (15% chance for large amounts)
    if (amount > 1000 && _random.nextInt(100) < 15) {
      throw const ServerException('Insufficient balance for withdrawal');
    }
    
    // Simulate occasional processing failure (8% chance)
    if (_random.nextInt(100) < 8) {
      throw const ServerException('Withdrawal processing failed');
    }

    // Generate mock transaction
    final transactionId = 'txn_${DateTime.now().millisecondsSinceEpoch}';
    final reference = 'WD${10000 + _random.nextInt(90000)}';
    
    return WalletTransactionModel(
      id: transactionId,
      userId: 'user_123',
      type: TransactionType.withdraw,
      amount: amount,
      currency: 'USD',
      description: 'Withdrawal to Bank Account',
      createdAt: DateTime.now(),
      status: TransactionStatus.pending, // Withdrawals usually start as pending
      reference: reference,
      metadata: {
        'bank_account': bankAccount,
        'processing_time': '1-3 business days',
        'initiated_at': DateTime.now().toIso8601String(),
      },
    );
  }
}