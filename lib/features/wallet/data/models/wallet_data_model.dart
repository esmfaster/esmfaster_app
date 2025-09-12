import '../../domain/models/wallet_model.dart';

class WalletBalanceModel extends WalletBalance {
  const WalletBalanceModel({
    required super.balance,
    required super.currency,
    required super.lastUpdated,
  });

  factory WalletBalanceModel.fromJson(Map<String, dynamic> json) {
    return WalletBalanceModel(
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
}

class WalletTransactionModel extends WalletTransaction {
  const WalletTransactionModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.amount,
    required super.currency,
    required super.description,
    required super.createdAt,
    required super.status,
    super.reference,
    super.metadata,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
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
}