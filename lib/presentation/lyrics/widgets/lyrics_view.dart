import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';
import 'package:sporify/presentation/lyrics/bloc/lyrics_cubit.dart';
import 'package:sporify/presentation/lyrics/bloc/lyrics_state.dart';

class LyricsView extends StatefulWidget {
  final Duration currentPosition;
  final String? coverImageUrl;

  const LyricsView({
    super.key,
    required this.currentPosition,
    this.coverImageUrl,
  });

  @override
  State<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends State<LyricsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(LyricsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPosition != oldWidget.currentPosition) {
      context.read<LyricsCubit>().updateCurrentLine(widget.currentPosition);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LyricsCubit, LyricsState>(
      listener: (context, state) {
        if (state is LyricsLoaded && state.currentLineIndex >= 0) {
          _scrollToCurrentLine(state.currentLineIndex);
        }
      },
      builder: (context, state) {
        if (state is LyricsLoading) {
          return Column(
            children: [
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              _buildCoverImage(),
            ],
          );
        }

        if (state is LyricsNotFound) {
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.music_note, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No lyrics found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildCoverImage(),
            ],
          );
        }

        if (state is LyricsFailure) {
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load lyrics',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              _buildCoverImage(),
            ],
          );
        }

        if (state is LyricsLoaded) {
          return Column(
            children: [
              Expanded(
                child: state.lyricsLines.isNotEmpty
                    ? _buildSyncedLyrics(state)
                    : state.lyrics.plainLyrics != null
                    ? _buildPlainLyrics(state.lyrics.plainLyrics!)
                    : Container(),
              ),
              _buildCoverImage(),
            ],
          );
        }

        return Column(
          children: [
            Expanded(child: Container()),
            _buildCoverImage(),
          ],
        );
      },
    );
  }

  Widget _buildSyncedLyrics(LyricsLoaded state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: state.lyricsLines.length,
      itemBuilder: (context, index) {
        final line = state.lyricsLines[index];
        final isCurrentLine = index == state.currentLineIndex;
        final isPastLine = index < state.currentLineIndex;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: isCurrentLine ? 20 : 16,
              fontWeight: isCurrentLine ? FontWeight.bold : FontWeight.normal,
              color: isCurrentLine
                  ? AppColors.primary
                  : isPastLine
                  ? Colors.grey[500]
                  : Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black87,
            ),
            child: Text(line.text, textAlign: TextAlign.center),
          ),
        );
      },
    );
  }

  Widget _buildPlainLyrics(String plainLyrics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Text(
        plainLyrics,
        style: TextStyle(
          fontSize: 16,
          height: 1.6,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white70
              : Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _scrollToCurrentLine(int index) {
    if (_scrollController.hasClients) {
      const itemHeight = 48.0;
      final targetOffset = index * itemHeight - 200;

      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildCoverImage() {
    if (widget.coverImageUrl == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          widget.coverImageUrl!,
          width: 200,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.music_note, size: 80, color: Colors.grey[600]),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
