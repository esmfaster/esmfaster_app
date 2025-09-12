import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/wallet_model.dart';
import '../../domain/usecases/add_balance.dart';
import '../../domain/usecases/get_transaction_history.dart';
import '../../domain/usecases/get_wallet_balance.dart';
import '../../domain/usecases/withdraw_balance.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWalletBalance getWalletBalance;
  final GetTransactionHistory getTransactionHistory;
  final AddBalance addBalance;
  final WithdrawBalance withdrawBalance;

  WalletBloc({
    required this.getWalletBalance,
    required this.getTransactionHistory,
    required this.addBalance,
    required this.withdrawBalance,
  }) : super(WalletInitial()) {
    on<LoadWalletBalance>(_onLoadWalletBalance);
    on<LoadTransactionHistory>(_onLoadTransactionHistory);
    on<AddBalanceEvent>(_onAddBalance);
    on<WithdrawBalanceEvent>(_onWithdrawBalance);
    on<RefreshWallet>(_onRefreshWallet);
  }

  Future<void> _onLoadWalletBalance(
    LoadWalletBalance event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    final balanceResult = await getWalletBalance();
    final transactionResult = await getTransactionHistory();

    await balanceResult.fold(
      (failure) => emit(WalletError(failure.message)),
      (balance) async {
        await transactionResult.fold(
          (failure) => emit(WalletError(failure.message)),
          (transactions) => emit(WalletLoaded(
            balance: balance,
            transactions: transactions,
          )),
        );
      },
    );
  }

  Future<void> _onLoadTransactionHistory(
    LoadTransactionHistory event,
    Emitter<WalletState> emit,
  ) async {
    final result = await getTransactionHistory(
      page: event.page,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(WalletError(failure.message)),
      (transactions) {
        if (state is WalletLoaded) {
          final currentState = state as WalletLoaded;
          emit(currentState.copyWith(transactions: transactions));
        }
      },
    );
  }

  Future<void> _onAddBalance(
    AddBalanceEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletTransactionLoading());

    final result = await addBalance(
      amount: event.amount,
      paymentMethod: event.paymentMethod,
    );

    result.fold(
      (failure) => emit(WalletError(failure.message)),
      (transaction) {
        emit(WalletTransactionSuccess(transaction));
        // Refresh wallet data
        add(LoadWalletBalance());
      },
    );
  }

  Future<void> _onWithdrawBalance(
    WithdrawBalanceEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletTransactionLoading());

    final result = await withdrawBalance(
      amount: event.amount,
      bankAccount: event.bankAccount,
    );

    result.fold(
      (failure) => emit(WalletError(failure.message)),
      (transaction) {
        emit(WalletTransactionSuccess(transaction));
        // Refresh wallet data
        add(LoadWalletBalance());
      },
    );
  }

  Future<void> _onRefreshWallet(
    RefreshWallet event,
    Emitter<WalletState> emit,
  ) async {
    add(LoadWalletBalance());
  }
}