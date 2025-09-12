import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../models/wallet_model.dart';
import '../repositories/wallet_repository.dart';

class WithdrawBalance {
  final WalletRepository repository;

  WithdrawBalance(this.repository);

  Future<Either<Failure, WalletTransaction>> call({
    required double amount,
    required String bankAccount,
  }) async {
    if (amount <= 0) {
      return const Left(ValidationFailure('Amount must be greater than zero'));
    }
    
    return await repository.withdrawBalance(
      amount: amount,
      bankAccount: bankAccount,
    );
  }
}