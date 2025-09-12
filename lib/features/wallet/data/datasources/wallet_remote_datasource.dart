import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/errors/exceptions.dart';
import '../models/wallet_data_model.dart';

abstract class WalletRemoteDataSource {
  Future<WalletBalanceModel> getWalletBalance();
  Future<List<WalletTransactionModel>> getTransactionHistory({
    int page = 1,
    int limit = 20,
  });
  Future<WalletTransactionModel> addBalance({
    required double amount,
    required String paymentMethod,
  });
  Future<WalletTransactionModel> withdrawBalance({
    required double amount,
    required String bankAccount,
  });
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  WalletRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
  });

  @override
  Future<WalletBalanceModel> getWalletBalance() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/wallet/balance'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return WalletBalanceModel.fromJson(jsonResponse);
      } else {
        throw ServerException('Failed to get wallet balance: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Network error occurred');
    }
  }

  @override
  Future<List<WalletTransactionModel>> getTransactionHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/wallet/transactions?page=$page&limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> transactionsList = jsonResponse['data'] ?? [];
        return transactionsList
            .map((json) => WalletTransactionModel.fromJson(json))
            .toList();
      } else {
        throw ServerException('Failed to get transaction history: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Network error occurred');
    }
  }

  @override
  Future<WalletTransactionModel> addBalance({
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/wallet/add-balance'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': amount,
          'payment_method': paymentMethod,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return WalletTransactionModel.fromJson(jsonResponse);
      } else {
        throw ServerException('Failed to add balance: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Network error occurred');
    }
  }

  @override
  Future<WalletTransactionModel> withdrawBalance({
    required double amount,
    required String bankAccount,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/wallet/withdraw'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': amount,
          'bank_account': bankAccount,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return WalletTransactionModel.fromJson(jsonResponse);
      } else {
        throw ServerException('Failed to withdraw balance: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Network error occurred');
    }
  }
}