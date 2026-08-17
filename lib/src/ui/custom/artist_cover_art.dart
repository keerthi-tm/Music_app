import 'package:flutter/material.dart';
import 'package:landingpage/src/services/album_cover_service.dart';

/// Square (rounded-rect) cover art tile that shows the real album cover
/// for [albumTitle] by [artistName], fetched via [AlbumCoverService].
///
/// Falls back to the gradient + icon tile while the cover is loading,
/// on a network/decode error, or when no cover image is found.
class AlbumCoverArt extends StatefulWidget {
  final String albumTitle;
  final String artistName;
  final List<Color> gradientColors;
  final double borderRadius;
  final IconData fallbackIcon;
  final double fallbackIconSize;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const AlbumCoverArt({
    super.key,
    required this.albumTitle,
    required this.artistName,
    required this.gradientColors,
    this.borderRadius = 20,
    this.fallbackIcon = Icons.album_rounded,
    this.fallbackIconSize = 40,
    this.border,
    this.boxShadow,
  });

  @override
  State<AlbumCoverArt> createState() => _AlbumCoverArtState();
}

class _AlbumCoverArtState extends State<AlbumCoverArt> {
  Future<String?>? _coverFuture;

  @override
  void initState() {
    super.initState();
    _coverFuture = AlbumCoverService.fetch(
      widget.albumTitle,
      widget.artistName,
    );
  }

  @override
  void didUpdateWidget(covariant AlbumCoverArt oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-fetch only if this tile gets reused for a different album
    // (e.g. inside a GridView that recycles widgets).
    if (oldWidget.albumTitle != widget.albumTitle ||
        oldWidget.artistName != widget.artistName) {
      _coverFuture = AlbumCoverService.fetch(
        widget.albumTitle,
        widget.artistName,
      );
    }
  }

  Widget _fallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.gradientColors,
        ),
      ),
      child: Center(
        child: Icon(
          widget.fallbackIcon,
          color: Colors.white70,
          size: widget.fallbackIconSize,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: widget.border,
        boxShadow: widget.boxShadow,
      ),
      child: FutureBuilder<String?>(
        future: _coverFuture,
        builder: (context, snapshot) {
          final url = snapshot.data;
          if (url == null) return _fallback();

          return Image.network(
            url,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => _fallback(),
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) return child;
              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: child,
              );
            },
          );
        },
      ),
    );
  }
}
