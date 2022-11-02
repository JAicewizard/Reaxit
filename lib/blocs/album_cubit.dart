import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';

typedef AlbumState = DetailState<Album>;

class AlbumCubit extends Cubit<AlbumState> {
  final ApiRepository api;

  AlbumCubit(this.api) : super(const AlbumState.loading());

  void updateLike({required bool liked, required int index}) {
    if (state.result == null) {
      return;
    }
    final oldphoto = state.result!.photos[index];
    AlbumPhoto newphoto = oldphoto.copyWith(
        liked: liked, numLikes: oldphoto.numLikes + (liked ? 1 : -1));
    List<AlbumPhoto> newphotos = List.from(state.result!.photos);
    newphotos[index] = newphoto;

    api.updateLiked(newphoto.pk, liked);

    emit(AlbumState.result(result: state.result!.copyWith(photos: newphotos)));
  }

  Future<void> load(String slug) async {
    emit(state.copyWith(isLoading: true));
    try {
      final album = await api.getAlbum(slug: slug);
      emit(AlbumState.result(result: album));
    } on ApiException catch (exception) {
      emit(AlbumState.failure(
        message: exception.getMessage(notFound: 'The album does not exist.'),
      ));
    }
  }
}
