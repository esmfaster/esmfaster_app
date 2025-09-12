import 'package:equatable/equatable.dart';
import '../../domain/models/wallet_model.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final WalletBalance balance;
  final List<WalletTransaction> transactions;

  const WalletLoaded({
    required this.balance,
    required this.transactions,
  });

  @override
  List<Object?> get props => [balance, transactions];

  WalletLoaded copyWith({
    WalletBalance? balance,
    List<WalletTransaction>? transactions,
  }) {
    return WalletLoaded(
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
    );
  }
}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}

class WalletTransactionLoading extends WalletState {}

class WalletTransactionSuccess extends WalletState {
  final WalletTransaction transaction;

  const WalletTransactionSuccess(this.transaction);

  @override
  List<Object?> get props => [transaction];
}