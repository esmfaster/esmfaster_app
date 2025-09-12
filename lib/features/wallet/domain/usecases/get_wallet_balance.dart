import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../models/wallet_model.dart';
import '../repositories/wallet_repository.dart';

class GetWalletBalance {
  final WalletRepository repository;

  GetWalletBalance(this.repository);

  Future<Either<Failure, WalletBalance>> call() async {
    return await repository.getWalletBalance();
  }
}