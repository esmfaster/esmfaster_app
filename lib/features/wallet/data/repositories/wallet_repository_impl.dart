import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/models/wallet_model.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_datasource.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;

  WalletRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, WalletBalance>> getWalletBalance() async {
    try {
      final result = await remoteDataSource.getWalletBalance();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<WalletTransaction>>> getTransactionHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result = await remoteDataSource.getTransactionHistory(
        page: page,
        limit: limit,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, WalletTransaction>> addBalance({
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      final result = await remoteDataSource.addBalance(
        amount: amount,
        paymentMethod: paymentMethod,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, WalletTransaction>> withdrawBalance({
    required double amount,
    required String bankAccount,
  }) async {
    try {
      final result = await remoteDataSource.withdrawBalance(
        amount: amount,
        bankAccount: bankAccount,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, WalletTransaction>> transferMoney({
    required double amount,
    required String recipientId,
    String? note,
  }) async {
    // Implementation for money transfer would go here
    // For now, returning a placeholder
    return const Left(ServerFailure('Transfer functionality not implemented yet'));
  }
}