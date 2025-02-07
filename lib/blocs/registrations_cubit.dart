import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';

typedef RegistrationsState = ListState<EventRegistration>;

class RegistrationsCubit extends Cubit<RegistrationsState> {
  final ApiRepository api;
  final int eventPk;

  static const int firstPageSize = 60;
  static const int pageSize = 30;

  /// The offset to be used for the next paginated request.
  int _nextOffset = 0;

  RegistrationsCubit(this.api, {required this.eventPk})
      : super(const RegistrationsState.loading(results: []));

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final listResponse = await api.getEventRegistrations(
          pk: eventPk, limit: firstPageSize, offset: 0);

      final isDone = listResponse.results.length == listResponse.count;

      _nextOffset = firstPageSize;

      if (listResponse.results.isNotEmpty) {
        emit(RegistrationsState.success(
            results: listResponse.results, isDone: isDone));
      } else {
        emit(const RegistrationsState.failure(
          message: 'There are no registrations yet.',
        ));
      }
    } on ApiException catch (exception) {
      emit(RegistrationsState.failure(
        message: exception.getMessage(notFound: 'The event does not exist.'),
      ));
    }
  }

  Future<void> more() async {
    final oldState = state;

    if (oldState.isDone || oldState.isLoading || oldState.isLoadingMore) return;

    emit(oldState.copyWith(isLoadingMore: true));

    try {
      var listResponse = await api.getEventRegistrations(
        pk: eventPk,
        limit: pageSize,
        offset: _nextOffset,
      );

      final registrations = state.results + listResponse.results;
      final isDone = registrations.length == listResponse.count;

      _nextOffset += pageSize;

      emit(RegistrationsState.success(results: registrations, isDone: isDone));
    } on ApiException catch (exception) {
      emit(RegistrationsState.failure(
        message: exception.getMessage(notFound: 'The event does not exist.'),
      ));
    }
  }
}
