import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../models/wallet_model.dart';
import '../repositories/wallet_repository.dart';

class AddBalance {
  final WalletRepository repository;

  AddBalance(this.repository);

  Future<Either<Failure, WalletTransaction>> call({
    required double amount,
    required String paymentMethod,
  }) async {
    if (amount <= 0) {
      return const Left(ValidationFailure('Amount must be greater than zero'));
    }
    
    return await repository.addBalance(
      amount: amount,
      paymentMethod: paymentMethod,
    );
  }
}