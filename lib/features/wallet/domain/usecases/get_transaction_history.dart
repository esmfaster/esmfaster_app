import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../models/wallet_model.dart';
import '../repositories/wallet_repository.dart';

class GetTransactionHistory {
  final WalletRepository repository;

  GetTransactionHistory(this.repository);

  Future<Either<Failure, List<WalletTransaction>>> call({
    int page = 1,
    int limit = 20,
  }) async {
    return await repository.getTransactionHistory(
      page: page,
      limit: limit,
    );
  }
}