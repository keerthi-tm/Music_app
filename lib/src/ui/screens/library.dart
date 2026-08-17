import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landingpage/src/models/library_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:landingpage/src/ui/custom/custom_appbar.dart';
import 'package:landingpage/src/utils/app_theme.dart';
import 'package:landingpage/src/utils/colors.dart';
import 'package:landingpage/src/models/song_data.dart';

class LibraryPage extends StatefulWidget {
  @Deprecated(
    'LibraryPage now follows AppTheme.instance. This value is ignored.',
  )
  final bool? isDarkMode;
  const LibraryPage({super.key, this.isDarkMode});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  int _tabIndex = 0;
  final LibraryState _lib = LibraryState.instance;

  @override
  void initState() {
    super.initState();
    AppTheme.instance.load();
    _lib.load();
  }

  void _toggleLike(String id) => _lib.toggleLiked(id);

  void _toggleSaved(String id) => _lib.toggleSaved(id);

  Future<void> _markPlayed(Song song) async {
    await _lib.markPlayed(song.id);

    if (!mounted) return;
    final isDarkMode = AppTheme.instance.isDarkMode;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDarkMode ? const Color(0xff220833) : Colors.white,
        content: Text(
          'Playing "${song.title}"',
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.textPrimary(isDarkMode),
            fontWeight: FontWeight.w600,
          ),
        ),
        duration: const Duration(milliseconds: 1400),
      ),
    );
  }

  Future<void> _clearRecent() => _lib.clearRecent();

  Future<void> _toggleTheme() => AppTheme.instance.toggleDark();

  Future<void> _openPlaylist(Playlist playlist) async {
    final ids = await songIdsForPlaylist(playlist);
    final songs = ids.map(songById).whereType<Song>().toList();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PlaylistSheet(
        playlist: playlist,
        songs: songs,
        isDarkMode: AppTheme.instance.isDarkMode,
        onLikeToggle: _toggleLike,
        onPlay: _markPlayed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppTheme.instance,
      builder: (context, _) {
        final isDarkMode = AppTheme.instance.isDarkMode;
        final textColor = AppColors.textPrimary(isDarkMode);
        final subTextColor = AppColors.textSecondary(isDarkMode);
        final isLoggedOut = FirebaseAuth.instance.currentUser == null;

        return Scaffold(
          body: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDarkMode
                        ? AppColors.backgroundDarkAlt
                        : AppColors.backgroundLightAlt,
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    CustomAppBar(
                      isDarkMode: !isDarkMode,
                      showLoginButton: isLoggedOut,
                      activePage: "Library",
                      onToggleTheme: _toggleTheme,
                    ),
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _lib,
                        builder: (context, _) {
                          if (!_lib.isLoaded) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.instance.accentColor,
                              ),
                            );
                          }

                          final likedIds = _lib.likedIds;
                          final savedIds = _lib.savedIds;
                          final recentIds = _lib.recentIds;

                          return ListView(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                            children: [
                              Text(
                                "Your Library",
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${likedIds.length} liked • ${savedIds.length} saved • ${playlists.length} playlists",
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  color: subTextColor,
                                ),
                              ),
                              const SizedBox(height: 22),
                              _buildTabSelector(isDarkMode),
                              const SizedBox(height: 20),
                              AnimatedSwitcher(
                                duration: AppTheme.instance.animDuration,
                                child: Container(
                                  key: ValueKey(_tabIndex),
                                  child: _buildTabContent(
                                    isDarkMode,
                                    likedIds,
                                    savedIds,
                                    recentIds,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
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

  Widget _buildTabSelector(bool isDarkMode) {
    final tabs = ['Liked', 'Saved', 'Playlists', 'Recent'];
    final accentGradient = AppColors.accentGradient(
      AppTheme.instance.accentColor,
    );

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: AppColors.glassSurface(
          isDarkMode,
          darkAlpha: 0.10,
          lightAlpha: 0.05,
        ),
        border: Border.all(color: AppColors.glassBorder(isDarkMode)),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final selected = _tabIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tabIndex = i),
              child: AnimatedContainer(
                duration: AppTheme.instance.animDuration,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: selected
                      ? LinearGradient(colors: accentGradient)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  tabs[i],
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? Colors.white
                        : AppColors.textSecondary(isDarkMode),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent(
    bool isDarkMode,
    Set<String> likedIds,
    Set<String> savedIds,
    List<String> recentIds,
  ) {
    switch (_tabIndex) {
      case 0:
        return _buildLikedTab(isDarkMode, likedIds);
      case 1:
        return _buildSavedTab(isDarkMode, savedIds);
      case 2:
        return _buildPlaylistsTab(isDarkMode);
      default:
        return _buildRecentTab(isDarkMode, likedIds, recentIds);
    }
  }

  Widget _buildLikedTab(bool isDarkMode, Set<String> likedIds) {
    final likedSongs = allSongs.where((s) => likedIds.contains(s.id)).toList();
    if (likedSongs.isEmpty) {
      return _emptyState(
        isDarkMode: isDarkMode,
        icon: Icons.favorite_border_rounded,
        title: "No liked songs yet",
        subtitle: "Tap the heart on any track in Discover to save it here.",
      );
    }
    return Column(
      children: likedSongs
          .map(
            (s) => SongTile(
              song: s,
              isDarkMode: isDarkMode,
              isLiked: true,
              onLikeToggle: () => _toggleLike(s.id),
              onTap: () => _markPlayed(s),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSavedTab(bool isDarkMode, Set<String> savedIds) {
    final savedSongs = allSongs.where((s) => savedIds.contains(s.id)).toList();
    if (savedSongs.isEmpty) {
      return _emptyState(
        isDarkMode: isDarkMode,
        icon: Icons.bookmark_border_rounded,
        title: "No saved songs yet",
        subtitle: "Tap the bookmark on any track in Discover to save it here.",
      );
    }
    return Column(
      children: savedSongs
          .map(
            (s) => _SavedSongTile(
              song: s,
              isDarkMode: isDarkMode,
              onSaveToggle: () => _toggleSaved(s.id),
              onTap: () => _markPlayed(s),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPlaylistsTab(bool isDarkMode) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: playlists.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        // Higher ratio = shorter card height. Bump this up further
        // (e.g. 1.5, 1.6...) if you want them even flatter.
        childAspectRatio: 1.3,
      ),
      itemBuilder: (context, i) {
        final playlist = playlists[i];
        return PlaylistCard(
          playlist: playlist,
          isDarkMode: isDarkMode,
          onTap: () => _openPlaylist(playlist),
        );
      },
    );
  }

  Widget _buildRecentTab(
    bool isDarkMode,
    Set<String> likedIds,
    List<String> recentIds,
  ) {
    final recentSongs = recentIds.map(songById).whereType<Song>().toList();
    if (recentSongs.isEmpty) {
      return _emptyState(
        isDarkMode: isDarkMode,
        icon: Icons.history_rounded,
        title: "Nothing played yet",
        subtitle: "Songs you play will show up here.",
      );
    }
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _clearRecent,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 16,
              color: AppColors.textSecondary(isDarkMode),
            ),
            label: Text(
              "Clear",
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary(isDarkMode),
              ),
            ),
          ),
        ),
        ...recentSongs.map(
          (s) => SongTile(
            song: s,
            isDarkMode: isDarkMode,
            isLiked: likedIds.contains(s.id),
            onLikeToggle: () => _toggleLike(s.id),
            onTap: () => _markPlayed(s),
          ),
        ),
      ],
    );
  }

  Widget _emptyState({
    required bool isDarkMode,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 70),
      child: Column(
        children: [
          Icon(icon, size: 46, color: AppColors.textFaint(isDarkMode)),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(isDarkMode),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              color: AppColors.textSecondary(isDarkMode),
            ),
          ),
        ],
      ),
    );
  }
}

class SongTile extends StatelessWidget {
  final Song song;
  final bool isDarkMode;
  final bool isLiked;
  final VoidCallback onLikeToggle;
  final VoidCallback onTap;

  const SongTile({
    super.key,
    required this.song,
    required this.isDarkMode,
    required this.isLiked,
    required this.onLikeToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = AppTheme.instance.accentColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AppColors.glassSurface(
            isDarkMode,
            darkAlpha: 0.08,
            lightAlpha: 0.04,
          ),
          border: Border.all(color: AppColors.glassBorder(isDarkMode)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: song.colors),
              ),
              child: const Icon(
                Icons.music_note_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary(isDarkMode),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: AppColors.textSecondary(isDarkMode),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onLikeToggle,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isLiked
                      ? accentColor
                      : AppColors.textSecondary(isDarkMode),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedSongTile extends StatelessWidget {
  final Song song;
  final bool isDarkMode;
  final VoidCallback onSaveToggle;
  final VoidCallback onTap;

  const _SavedSongTile({
    required this.song,
    required this.isDarkMode,
    required this.onSaveToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AppColors.glassSurface(
            isDarkMode,
            darkAlpha: 0.08,
            lightAlpha: 0.04,
          ),
          border: Border.all(color: AppColors.glassBorder(isDarkMode)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: song.colors),
              ),
              child: const Icon(
                Icons.music_note_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary(isDarkMode),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: AppColors.textSecondary(isDarkMode),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onSaveToggle,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.bookmark_rounded,
                  color: song.colors.last,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final bool isDarkMode;
  final VoidCallback onTap;

  // Optional per-card cover (e.g. the rotating con2/con3/con4/con5 images
  // used on the Playlist Menu page). When not provided, every card falls
  // back to the same connn.png cover.
  final String? backgroundImage;

  const PlaylistCard({
    super.key,
    required this.playlist,
    required this.isDarkMode,
    required this.onTap,
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(backgroundImage ?? 'images/connn.png'),
            fit: BoxFit.cover,
            // Darkens the photo a bit so the white title text stays
            // readable no matter what the image looks like.
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.32),
              BlendMode.darken,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: playlist.gradient.first.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        // Tight padding to keep the card short.
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.22),
              ),
              child: Icon(playlist.icon, color: Colors.white, size: 12),
            ),
            const Spacer(),
            Text(
              playlist.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Colors.white,
              ),
            ),
            Text(
              "${playlist.songIds.length} songs",
              style: GoogleFonts.spaceGrotesk(
                fontSize: 8,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaylistSheet extends StatefulWidget {
  final Playlist playlist;
  final List<Song> songs;
  final bool isDarkMode;
  final void Function(String id) onLikeToggle;
  final Future<void> Function(Song song) onPlay;

  const PlaylistSheet({
    super.key,
    required this.playlist,
    required this.songs,
    required this.isDarkMode,
    required this.onLikeToggle,
    required this.onPlay,
  });

  @override
  State<PlaylistSheet> createState() => _PlaylistSheetState();
}

class _PlaylistSheetState extends State<PlaylistSheet> {
  final LibraryState _lib = LibraryState.instance;

  void _toggle(String id) => widget.onLikeToggle(id);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;
    final songs = widget.songs;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          constraints: BoxConstraints(
            // Was 0.75 — shorter sheet so it doesn't dominate the screen.
            maxHeight: MediaQuery.of(context).size.height * 0.55,
          ),
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
            children: [
              Container(
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
              const SizedBox(height: 18),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'images/connn.png',
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: widget.playlist.gradient,
                          ),
                        ),
                        child: Icon(
                          widget.playlist.icon,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.playlist.title,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary(isDarkMode),
                          ),
                        ),
                        Text(
                          widget.playlist.description,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: AppColors.textSecondary(isDarkMode),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Flexible(
                child: SingleChildScrollView(
                  child: AnimatedBuilder(
                    animation: _lib,
                    builder: (context, _) {
                      return Column(
                        children: songs
                            .map(
                              (s) => SongTile(
                                song: s,
                                isDarkMode: isDarkMode,
                                isLiked: _lib.isLiked(s.id),
                                onLikeToggle: () => _toggle(s.id),
                                onTap: () => widget.onPlay(s),
                              ),
                            )
                            .toList(),
                      );
                    },
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
