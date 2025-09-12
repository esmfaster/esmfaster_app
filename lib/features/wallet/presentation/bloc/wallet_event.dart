import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class LoadWalletBalance extends WalletEvent {}

class LoadTransactionHistory extends WalletEvent {
  final int page;
  final int limit;

  const LoadTransactionHistory({
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [page, limit];
}

class AddBalanceEvent extends WalletEvent {
  final double amount;
  final String paymentMethod;

  const AddBalanceEvent({
    required this.amount,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [amount, paymentMethod];
}

class WithdrawBalanceEvent extends WalletEvent {
  final double amount;
  final String bankAccount;

  const WithdrawBalanceEvent({
    required this.amount,
    required this.bankAccount,
  });

  @override
  List<Object?> get props => [amount, bankAccount];
}

class RefreshWallet extends WalletEvent {}