import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sporify/domain/usecases/spotify/get_track_with_preview.dart';
import 'package:sporify/core/di/service_locator.dart';

abstract class SpotifyPlayerState {}

class SpotifyPlayerInitial extends SpotifyPlayerState {}

class SpotifyPlayerLoading extends SpotifyPlayerState {}

class SpotifyPlayerPlaying extends SpotifyPlayerState {
  final String trackId;
  final String? previewUrl;

  SpotifyPlayerPlaying({required this.trackId, this.previewUrl});
}

class SpotifyPlayerPaused extends SpotifyPlayerState {}

class SpotifyPlayerStopped extends SpotifyPlayerState {}

class SpotifyPlayerError extends SpotifyPlayerState {
  final String message;

  SpotifyPlayerError({required this.message});
}

class SpotifyPlayerCubit extends Cubit<SpotifyPlayerState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentTrackId;

  SpotifyPlayerCubit() : super(SpotifyPlayerInitial());

  Future<void> playTrack(String trackId) async {
    try {
      emit(SpotifyPlayerLoading());

      // Lấy chi tiết track bao gồm cả URL preview từ Spotify API
      final track = await sl<GetTrackWithPreviewUseCase>().call(
        params: trackId,
      );

      if (track.previewUrl != null && track.previewUrl!.isNotEmpty) {
        // Phát preview thực tế
        await _audioPlayer.play(UrlSource(track.previewUrl!));
        _currentTrackId = trackId;
        emit(
          SpotifyPlayerPlaying(trackId: trackId, previewUrl: track.previewUrl),
        );
      } else {
        // Phát âm thanh demo hoặc hiển thị thông báo
        emit(
          SpotifyPlayerError(message: 'No preview available for this track'),
        );
      }
    } catch (e) {
      emit(SpotifyPlayerError(message: 'Error playing track: $e'));
    }
  }

  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      emit(SpotifyPlayerPaused());
    } catch (e) {
      emit(SpotifyPlayerError(message: 'Error pausing: $e'));
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _currentTrackId = null;
      emit(SpotifyPlayerStopped());
    } catch (e) {
      emit(SpotifyPlayerError(message: 'Error stopping: $e'));
    }
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}
