import 'package:dartz/dartz.dart';
import '../models/wallet_model.dart';
import '../../../../core/errors/failures.dart';

abstract class WalletRepository {
  Future<Either<Failure, WalletBalance>> getWalletBalance();
  Future<Either<Failure, List<WalletTransaction>>> getTransactionHistory({
    int page = 1,
    int limit = 20,
  });
  Future<Either<Failure, WalletTransaction>> addBalance({
    required double amount,
    required String paymentMethod,
  });
  Future<Either<Failure, WalletTransaction>> withdrawBalance({
    required double amount,
    required String bankAccount,
  });
  Future<Either<Failure, WalletTransaction>> transferMoney({
    required double amount,
    required String recipientId,
    String? note,
  });
}