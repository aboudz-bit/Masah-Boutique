import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../main.dart';
import '../services/api_service.dart';
import 'shimmer_placeholder.dart';

/// A gold-themed video player widget with auto-hiding controls.
///
/// Displays video at 4:5 aspect ratio with play/pause overlay, progress bar,
/// and an optional thumbnail shown before playback starts.
class LuxuryVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;
  final bool autoPlay;
  final bool looping;

  const LuxuryVideoPlayer({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
    this.autoPlay = false,
    this.looping = true,
  });

  @override
  State<LuxuryVideoPlayer> createState() => _LuxuryVideoPlayerState();
}

class _LuxuryVideoPlayerState extends State<LuxuryVideoPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _hasError = false;
  bool _showControls = true;
  bool _hasStarted = false;
  Timer? _hideTimer;

  String get _resolvedUrl {
    final url = widget.videoUrl;
    if (url.startsWith('http')) return url;
    return '${ApiService.baseUrl}$url';
  }

  String? get _resolvedThumbnail {
    final url = widget.thumbnailUrl;
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return url;
    return '${ApiService.baseUrl}$url';
  }

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(_resolvedUrl));
    _controller.addListener(_onVideoUpdate);
    try {
      await _controller.initialize();
      _controller.setLooping(widget.looping);
      if (mounted) {
        setState(() => _initialized = true);
        if (widget.autoPlay) {
          _play();
        }
      }
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  void _onVideoUpdate() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.removeListener(_onVideoUpdate);
    _controller.dispose();
    super.dispose();
  }

  // ---------- Controls logic ----------

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      _showControls = true;
      _hideTimer?.cancel();
    } else {
      _play();
    }
  }

  void _play() {
    _controller.play();
    _hasStarted = true;
    _resetHideTimer();
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    _showControls = true;
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controller.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _onTapVideo() {
    if (_showControls && _controller.value.isPlaying) {
      setState(() => _showControls = false);
    } else {
      setState(() => _showControls = true);
      if (_controller.value.isPlaying) _resetHideTimer();
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // ---------- Build ----------

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: kCharcoal,
          child: _hasError
              ? _buildError()
              : !_initialized
                  ? _buildLoading()
                  : _buildPlayer(),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    final thumb = _resolvedThumbnail;
    if (thumb != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: thumb,
            fit: BoxFit.cover,
            placeholder: (_, __) => const ShimmerPlaceholder(),
            errorWidget: (_, __, ___) => const ShimmerPlaceholder(),
          ),
          const Center(
            child: CircularProgressIndicator(
              color: kGoldPrimary,
              strokeWidth: 2.5,
            ),
          ),
        ],
      );
    }
    return const Center(
      child: CircularProgressIndicator(
        color: kGoldPrimary,
        strokeWidth: 2.5,
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.videocam_off_rounded, color: kGoldPrimary.withOpacity(0.5), size: 48),
          const SizedBox(height: 8),
          Text(
            'Video unavailable',
            style: TextStyle(color: kGoldPrimary.withOpacity(0.7), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayer() {
    return GestureDetector(
      onTap: _onTapVideo,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),

          // Thumbnail overlay before playback starts
          if (!_hasStarted && _resolvedThumbnail != null)
            CachedNetworkImage(
              imageUrl: _resolvedThumbnail!,
              fit: BoxFit.cover,
              placeholder: (_, __) => const SizedBox.shrink(),
              errorWidget: (_, __, ___) => const SizedBox.shrink(),
            ),

          // Controls overlay
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: IgnorePointer(
              ignoring: !_showControls,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.15),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.55),
                    ],
                    stops: const [0.0, 0.25, 0.6, 1.0],
                  ),
                ),
                child: Column(
                  children: [
                    const Spacer(),
                    // Play / Pause button
                    _PlayPauseButton(
                      isPlaying: _controller.value.isPlaying,
                      hasStarted: _hasStarted,
                      onTap: _togglePlayPause,
                    ),
                    const Spacer(),
                    // Bottom bar: progress + time
                    _buildBottomBar(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final position = _controller.value.position;
    final duration = _controller.value.duration;
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          SizedBox(
            height: 20,
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                activeTrackColor: kGoldPrimary,
                inactiveTrackColor: Colors.white.withOpacity(0.3),
                thumbColor: kGoldPrimary,
                overlayColor: kGoldPrimary.withOpacity(0.2),
              ),
              child: Slider(
                value: progress.clamp(0.0, 1.0),
                onChanged: (value) {
                  final newPosition = Duration(
                    milliseconds: (value * duration.inMilliseconds).round(),
                  );
                  _controller.seekTo(newPosition);
                  _resetHideTimer();
                },
              ),
            ),
          ),
          const SizedBox(height: 2),
          // Time labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(position),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _formatDuration(duration),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------- Play / Pause Button with animation ----------

class _PlayPauseButton extends StatefulWidget {
  final bool isPlaying;
  final bool hasStarted;
  final VoidCallback onTap;

  const _PlayPauseButton({
    required this.isPlaying,
    required this.hasStarted,
    required this.onTap,
  });

  @override
  State<_PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<_PlayPauseButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.isPlaying ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(covariant _PlayPauseButton old) {
    super.didUpdateWidget(old);
    if (widget.isPlaying != old.isPlaying) {
      if (widget.isPlaying) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final large = !widget.hasStarted;
    final size = large ? 64.0 : 52.0;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: kGoldPrimary.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: kGoldPrimary.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: AnimatedIcon(
            icon: AnimatedIcons.play_pause,
            progress: _animController,
            color: Colors.white,
            size: large ? 32 : 26,
          ),
        ),
      ),
    );
  }
}
