import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api_repository.dart';
import 'package:reaxit/config.dart' as config;
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models/food_order.dart';
import 'package:reaxit/models/payment.dart';

typedef FoodAdminState = DetailState<List<FoodOrder>>;

class FoodAdminCubit extends Cubit<FoodAdminState> {
  final ApiRepository api;
  final int foodEventPk;

  /// The last used search query. Can be set through `this.search(query)`.
  String? _searchQuery;

  /// The last used search query. Can be set through `this.search(query)`.
  String? get searchQuery => _searchQuery;

  /// A timer used to debounce calls to `this.load()` from `this.search()`.
  Timer? _searchDebounceTimer;

  FoodAdminCubit(this.api, {required this.foodEventPk})
      : super(const FoodAdminState.loading());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final query = _searchQuery;
      final orders = await api.getAdminFoodOrders(
        pk: foodEventPk,
        search: query,
        limit: 999999999,
      );
      if (orders.results.isEmpty) {
        if (query?.isEmpty ?? true) {
          emit(const FoodAdminState.failure(
            message: 'There are no orders.',
          ));
        } else {
          emit(FoodAdminState.failure(
            message: 'There are no orders matching "$query".',
          ));
        }
      } else {
        emit(FoodAdminState.result(result: orders.results));
      }
    } on ApiException catch (exception) {
      emit(FoodAdminState.failure(message: _failureMessage(exception)));
    }
  }

  /// Set this cubit's `searchQuery` and load the orders for that query.
  ///
  /// Use `null` as argument to remove the search query.
  void search(String? query) {
    if (query != _searchQuery) {
      _searchQuery = query;
      _searchDebounceTimer?.cancel();
      if (query?.isEmpty ?? false) {
        /// Don't get results when the query is empty.
        emit(const FoodAdminState.loading());
      } else {
        _searchDebounceTimer = Timer(config.searchDebounceTime, load);
      }
    }
  }

  Future<void> setPayment({
    required int orderPk,
    required PaymentType? paymentType,
  }) async {
    if (paymentType != null) {
      final payable = await api.markPaidAdminFoodOrder(
        orderPk: orderPk,
        paymentType: paymentType,
      );
      if (state.result != null) {
        emit(
          state.copyWith(
            result: state.result!.map(
              (order) {
                if (order.pk == orderPk) {
                  return order.copyWithPayment(payable.payment);
                } else {
                  return order;
                }
              },
            ).toList(),
          ),
        );
      } else {
        await load();
      }
    } else {
      await api.markNotPaidAdminFoodOrder(
        orderPk: orderPk,
      );
      if (state.result != null) {
        emit(
          state.copyWith(
            result: state.result!.map(
              (order) {
                if (order.pk == orderPk) {
                  return order.copyWithPayment(null);
                } else {
                  return order;
                }
              },
            ).toList(),
          ),
        );
      } else {
        await load();
      }
    }
  }

  String _failureMessage(ApiException exception) {
    switch (exception) {
      case ApiException.noInternet:
        return 'Not connected to the internet.';
      case ApiException.notFound:
        return 'The food event does not exist.';
      default:
        return 'An unknown error occurred.';
    }
  }
}
