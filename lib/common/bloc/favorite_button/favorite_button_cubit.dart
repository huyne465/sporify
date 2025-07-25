import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:sporify/common/bloc/favorite_button/favorite_button_state.dart';
import 'package:sporify/domain/usecases/song/add_or_remove_song.dart';
import 'package:sporify/domain/usecases/song/is_favorite.dart';
import 'package:sporify/core/di/service_locator.dart';

class FavoriteButtonCubit extends Cubit<FavoriteButtonState> {
  FavoriteButtonCubit() : super(FavoriteButtonInitial());

  Future<void> init(String songId) async {
    // Kiểm tra trạng thái favorite khi khởi tạo
    final isFavorite = await sl<IsFavoriteUseCase>().call(params: songId);
    emit(FavoriteButtonUpdated(isFavorite: isFavorite));
  }

  Future<void> favoriteButtonUpdated(String songId) async {
    // Gọi use case để toggle trạng thái favorite
    var result = await sl<AddOrRemoveSongUseCase>().call(params: songId);
    result.fold(
      (error) {
        // Xử lý lỗi nếu cần
      },
      (isFavorite) {
        emit(FavoriteButtonUpdated(isFavorite: isFavorite));
      },
    );
  }
}
