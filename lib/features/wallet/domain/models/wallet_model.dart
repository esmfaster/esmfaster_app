import 'package:equatable/equatable.dart';

class WalletBalance extends Equatable {
  final double balance;
  final String currency;
  final DateTime lastUpdated;

  const WalletBalance({
    required this.balance,
    required this.currency,
    required this.lastUpdated,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      balance: double.tryParse(json['balance'].toString()) ?? 0.0,
      currency: json['currency'] ?? 'USD',
      lastUpdated: DateTime.tryParse(json['last_updated'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'currency': currency,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [balance, currency, lastUpdated];
}

class WalletTransaction extends Equatable {
  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final String currency;
  final String description;
  final DateTime createdAt;
  final TransactionStatus status;
  final String? reference;
  final Map<String, dynamic>? metadata;

  const WalletTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.description,
    required this.createdAt,
    required this.status,
    this.reference,
    this.metadata,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      type: TransactionType.fromString(json['type'] ?? ''),
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      currency: json['currency'] ?? 'USD',
      description: json['description'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      status: TransactionStatus.fromString(json['status'] ?? ''),
      reference: json['reference'],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.value,
      'amount': amount,
      'currency': currency,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'status': status.value,
      'reference': reference,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        amount,
        currency,
        description,
        createdAt,
        status,
        reference,
        metadata,
      ];
}

enum TransactionType {
  topUp('top_up'),
  withdraw('withdraw'),
  transfer('transfer'),
  payment('payment'),
  refund('refund'),
  commission('commission');

  const TransactionType(this.value);

  final String value;

  static TransactionType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'top_up':
        return TransactionType.topUp;
      case 'withdraw':
        return TransactionType.withdraw;
      case 'transfer':
        return TransactionType.transfer;
      case 'payment':
        return TransactionType.payment;
      case 'refund':
        return TransactionType.refund;
      case 'commission':
        return TransactionType.commission;
      default:
        return TransactionType.payment;
    }
  }

  String get displayName {
    switch (this) {
      case TransactionType.topUp:
        return 'Top Up';
      case TransactionType.withdraw:
        return 'Withdraw';
      case TransactionType.transfer:
        return 'Transfer';
      case TransactionType.payment:
        return 'Payment';
      case TransactionType.refund:
        return 'Refund';
      case TransactionType.commission:
        return 'Commission';
    }
  }
}

enum TransactionStatus {
  pending('pending'),
  completed('completed'),
  failed('failed'),
  cancelled('cancelled');

  const TransactionStatus(this.value);

  final String value;

  static TransactionStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return TransactionStatus.pending;
      case 'completed':
        return TransactionStatus.completed;
      case 'failed':
        return TransactionStatus.failed;
      case 'cancelled':
        return TransactionStatus.cancelled;
      default:
        return TransactionStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
    }
  }
}