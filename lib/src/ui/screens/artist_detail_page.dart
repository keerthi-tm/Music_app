import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:landingpage/src/models/app_theme.dart';
import 'package:landingpage/src/models/library_state.dart';
import 'package:landingpage/src/utils/app_theme.dart';
import 'package:landingpage/src/utils/colors.dart';
import 'package:landingpage/src/models/song_data.dart';
import 'package:landingpage/src/models/artist_data.dart';
import 'package:landingpage/src/services/artist_photo_service.dart';

class ArtistDetailPage extends StatefulWidget {
  final String artistId;

  const ArtistDetailPage({
    super.key,
    required this.artistId,
    required bool isDarkMode,
  });

  @override
  State<ArtistDetailPage> createState() => _ArtistDetailPageState();
}

class _ArtistDetailPageState extends State<ArtistDetailPage> {
  String? _playingSongId;
  String? _fetchedUrl;
  bool _fetchDone = false;

  @override
  void initState() {
    super.initState();
    AppTheme.instance.load();
    final artist = artistById(widget.artistId);
    if (artist != null && artist.imageUrl.isEmpty) {
      _loadPhoto(artist.name);
    } else {
      _fetchDone = true;
    }
  }

  Future<void> _loadPhoto(String artistName) async {
    final url = await ArtistPhotoService.fetch(artistName);
    if (!mounted) return;
    setState(() {
      _fetchedUrl = url;
      _fetchDone = true;
    });
  }

  void _setPlaying(String songId, bool playing) {
    setState(() => _playingSongId = playing ? songId : null);
  }

  @override
  Widget build(BuildContext context) {
    final artist = artistById(widget.artistId);

    return AnimatedBuilder(
      animation: AppTheme.instance,
      builder: (context, _) {
        final isDarkMode = AppTheme.instance.isDarkMode;

        if (artist == null) {
          return Scaffold(
            body: Center(
              child: Text(
                "Artist not found",
                style: GoogleFonts.spaceGrotesk(
                  color: AppColors.textPrimary(isDarkMode),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDarkMode
                          ? AppColors.backgroundDark
                          : AppColors.backgroundLight,
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.of(context).maybePop(),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.glassSurface(isDarkMode),
                                  border: Border.all(
                                    color: AppColors.glassBorder(isDarkMode),
                                  ),
                                ),
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  size: 18,
                                  color: AppColors.textPrimary(isDarkMode),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: artist.colors,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: artist.colors.last.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 22,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child:
                                    (artist.imageUrl.isNotEmpty
                                            ? artist.imageUrl
                                            : _fetchedUrl) !=
                                        null
                                    ? Image.network(
                                        artist.imageUrl.isNotEmpty
                                            ? artist.imageUrl
                                            : _fetchedUrl!,
                                        fit: BoxFit.cover,
                                        width: 120,
                                        height: 120,
                                        errorBuilder: (_, __, ___) =>
                                            const Center(
                                              child: Icon(
                                                Icons.person_rounded,
                                                color: Colors.white70,
                                                size: 48,
                                              ),
                                            ),
                                      )
                                    : (_fetchDone
                                          ? const Center(
                                              child: Icon(
                                                Icons.person_rounded,
                                                color: Colors.white70,
                                                size: 48,
                                              ),
                                            )
                                          : const Center(
                                              child: SizedBox(
                                                width: 26,
                                                height: 26,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white70,
                                                    ),
                                              ),
                                            )),
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "ARTIST",
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                      color: AppColors.textFaint(isDarkMode),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    artist.name,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary(isDarkMode),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${artist.songs.length} songs",
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 13,
                                      color: AppColors.textSecondary(
                                        isDarkMode,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final song = artist.songs[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ArtistSongBar(
                              isDarkMode: isDarkMode,
                              song: song,
                              trackNumber: index + 1,
                              isPlaying: _playingSongId == song.id,
                              onPlayingChanged: (playing) =>
                                  _setPlaying(song.id, playing),
                            ),
                          );
                        }, childCount: artist.songs.length),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ArtistSongBar extends StatefulWidget {
  final bool isDarkMode;
  final Song song;
  final int trackNumber;
  final bool isPlaying;
  final ValueChanged<bool> onPlayingChanged;

  const _ArtistSongBar({
    required this.isDarkMode,
    required this.song,
    required this.trackNumber,
    required this.isPlaying,
    required this.onPlayingChanged,
  });

  @override
  State<_ArtistSongBar> createState() => _ArtistSongBarState();
}

class _ArtistSongBarState extends State<_ArtistSongBar> {
  final LibraryState _lib = LibraryState.instance;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _lib.load();
  }

  Future<void> _toggleFavorite() async {
    await _lib.toggleLiked(widget.song.id);
  }

  Future<void> _toggleSaved() async {
    final wasSaved = _lib.isSaved(widget.song.id);
    await _lib.toggleSaved(widget.song.id);

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: widget.isDarkMode
            ? const Color(0xff220833)
            : Colors.white,
        content: Text(
          wasSaved
              ? 'Removed "${widget.song.title}" from Saved'
              : 'Saved "${widget.song.title}"',
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.textPrimary(widget.isDarkMode),
            fontWeight: FontWeight.w600,
          ),
        ),
        duration: const Duration(milliseconds: 1200),
      ),
    );
  }

  void _togglePlay() {
    final nowPlaying = !widget.isPlaying;
    widget.onPlayingChanged(nowPlaying);
    if (nowPlaying) _lib.markPlayed(widget.song.id);
  }

  void _seek(double value) => setState(() => _progress = value.clamp(0.0, 1.0));

  void _openAddToPlaylist() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          _AddToPlaylistSheet(isDarkMode: widget.isDarkMode, song: widget.song),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _lib,
      builder: (context, _) {
        final isDarkMode = widget.isDarkMode;
        final song = widget.song;
        final isPlaying = widget.isPlaying;
        final isFavorited = _lib.isLiked(song.id);
        final isSaved = _lib.isSaved(song.id);

        return ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: AppColors.glassSurface(isDarkMode),
                border: Border.all(color: AppColors.glassBorder(isDarkMode)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 22,
                    child: Text(
                      '${widget.trackNumber}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: AppColors.textFaint(isDarkMode),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.spaceGrotesk(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.textPrimary(isDarkMode),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _openAddToPlaylist,
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.playlist_add_rounded,
                                  size: 20,
                                  color: AppColors.textFaint(isDarkMode),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _toggleSaved,
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  isSaved
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_border_rounded,
                                  size: 18,
                                  color: isSaved
                                      ? song.colors.last
                                      : AppColors.textFaint(isDarkMode),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _toggleFavorite,
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  isFavorited
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  size: 18,
                                  color: isFavorited
                                      ? song.colors.last
                                      : AppColors.textFaint(isDarkMode),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${isPlaying ? 'Now Playing' : 'Paused'} • ${song.artist}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: isDarkMode ? Colors.white60 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 2),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            activeTrackColor: song.colors.last,
                            inactiveTrackColor: AppColors.glassBorder(
                              isDarkMode,
                              darkAlpha: 0.15,
                              lightAlpha: 0.08,
                            ),
                            thumbColor: song.colors.last,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 5,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 12,
                            ),
                            overlayColor: song.colors.last.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          child: Slider(
                            value: _progress,
                            min: 0.0,
                            max: 1.0,
                            onChanged: _seek,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _togglePlay,
                    child: Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: song.colors),
                      ),
                      child: Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AddToPlaylistSheet extends StatelessWidget {
  final bool isDarkMode;
  final Song song;

  const _AddToPlaylistSheet({required this.isDarkMode, required this.song});

  Future<void> _add(BuildContext context, Playlist playlist) async {
    final added = await LibraryState.instance.addToPlaylist(
      playlist.id,
      song.id,
    );
    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDarkMode ? const Color(0xff220833) : Colors.white,
        content: Text(
          added
              ? 'Added "${song.title}" to ${playlist.title}'
              : '"${song.title}" is already in ${playlist.title}',
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.textPrimary(isDarkMode),
            fontWeight: FontWeight.w600,
          ),
        ),
        duration: const Duration(milliseconds: 1400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color(0xff220833).withValues(alpha: 0.97)
                : Colors.white.withValues(alpha: 0.96),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: AppColors.glassBorder(isDarkMode)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.glassBorder(
                      isDarkMode,
                      darkAlpha: 0.35,
                      lightAlpha: 0.25,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                "Add to playlist",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(isDarkMode),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                song.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: AppColors.textSecondary(isDarkMode),
                ),
              ),
              const SizedBox(height: 18),
              ...playlists.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => _add(context, p),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppColors.glassSurface(
                          isDarkMode,
                          darkAlpha: 0.08,
                          lightAlpha: 0.04,
                        ),
                        border: Border.all(
                          color: AppColors.glassBorder(isDarkMode),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: p.gradient),
                            ),
                            child: Icon(p.icon, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.title,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: AppColors.textPrimary(isDarkMode),
                                  ),
                                ),
                                Text(
                                  p.description,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 11,
                                    color: AppColors.textSecondary(isDarkMode),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.add_circle_outline_rounded,
                            size: 20,
                            color: AppColors.textFaint(isDarkMode),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
