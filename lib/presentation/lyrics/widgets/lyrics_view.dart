import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
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
        return Stack(
          children: [
            // Background cover image
            _buildBackgroundCover(),
            // Gradient overlay
            _buildGradientOverlay(),
            // Content
            _buildContent(state),
          ],
        );
      },
    );
  }

  Widget _buildBackgroundCover() {
    if (widget.coverImageUrl == null) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(1),
            ],
          ),
        ),
      );
    }

    return Positioned.fill(
      child: Image.network(
        widget.coverImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.grey[800]!, Colors.black],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.4, 0.7, 1.0],
            colors: [
              Colors.black.withOpacity(0.1),
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0.9),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(LyricsState state) {
    if (state is LyricsLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is LyricsNotFound) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note,
              size: 48,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'No lyrics found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (state is LyricsFailure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load lyrics',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (state is LyricsLoaded) {
      return state.lyricsLines.isNotEmpty
          ? _buildSyncedLyrics(state)
          : state.lyrics.plainLyrics != null
          ? _buildPlainLyrics(state.lyrics.plainLyrics!)
          : Container();
    }

    return Container();
  }

  Widget _buildSyncedLyrics(LyricsLoaded state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      itemCount: state.lyricsLines.length + 10, // Add extra space at bottom
      itemBuilder: (context, index) {
        if (index >= state.lyricsLines.length) {
          return const SizedBox(height: 40); // Empty space at bottom
        }

        final line = state.lyricsLines[index];
        final isCurrentLine = index == state.currentLineIndex;
        final isPastLine = index < state.currentLineIndex;
        final isUpcomingLine = index > state.currentLineIndex;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: isCurrentLine ? 24 : 18,
                fontWeight: isCurrentLine ? FontWeight.bold : FontWeight.w500,
                color: isCurrentLine
                    ? Colors.white
                    : isPastLine
                    ? Colors.white.withOpacity(0.4)
                    : isUpcomingLine
                    ? Colors.white.withOpacity(0.7)
                    : Colors.white.withOpacity(0.6),
                shadows: isCurrentLine
                    ? [
                        Shadow(
                          offset: const Offset(0, 1),
                          blurRadius: 3,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ]
                    : null,
              ),
              child: Text(line.text, textAlign: TextAlign.center),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlainLyrics(String plainLyrics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Text(
        plainLyrics,
        style: TextStyle(
          fontSize: 18,
          height: 1.8,
          color: Colors.white.withOpacity(0.8),
          fontWeight: FontWeight.w400,
          shadows: [
            Shadow(
              offset: const Offset(0, 1),
              blurRadius: 2,
              color: Colors.black.withOpacity(0.5),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _scrollToCurrentLine(int index) {
    if (_scrollController.hasClients) {
      const itemHeight = 60.0;
      final targetOffset = index * itemHeight - 150;

      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
