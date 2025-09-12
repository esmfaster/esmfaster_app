// Dependency Injection setup for production use
// This file shows how to set up real services instead of mock data

/*
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../../features/wallet/data/datasources/wallet_remote_datasource.dart';
import '../../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/wallet/domain/usecases/get_wallet_balance.dart';
import '../../features/wallet/domain/usecases/get_transaction_history.dart';
import '../../features/wallet/domain/usecases/add_balance.dart';
import '../../features/wallet/domain/usecases/withdraw_balance.dart';
import '../../features/wallet/presentation/bloc/wallet_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Core
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  // Data Sources
  getIt.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSourceImpl(
      client: getIt<http.Client>(),
      baseUrl: 'https://api.esmfaster.com', // Replace with your API URL
    ),
  );

  // Repositories
  getIt.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(
      remoteDataSource: getIt<WalletRemoteDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetWalletBalance(getIt<WalletRepository>()));
  getIt.registerLazySingleton(() => GetTransactionHistory(getIt<WalletRepository>()));
  getIt.registerLazySingleton(() => AddBalance(getIt<WalletRepository>()));
  getIt.registerLazySingleton(() => WithdrawBalance(getIt<WalletRepository>()));

  // BLoCs
  getIt.registerFactory(
    () => WalletBloc(
      getWalletBalance: getIt<GetWalletBalance>(),
      getTransactionHistory: getIt<GetTransactionHistory>(),
      addBalance: getIt<AddBalance>(),
      withdrawBalance: getIt<WithdrawBalance>(),
    ),
  );
}

// Usage in main.dart:
// 
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await configureDependencies();
//   runApp(ModernEsmFasterApp());
// }
//
// Then in app widget:
// BlocProvider<WalletBloc>(
//   create: (context) => getIt<WalletBloc>(),
//   ...
// )
*/

// For now, we're using mock data sources in main_modern.dart for demonstration