import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:landingpage/src/models/library_state.dart';
import 'package:landingpage/src/models/song_data.dart';
import 'package:landingpage/src/ui/custom/custom_appbar.dart';
// import 'package:landingpage/src/ui/custom/lyric_ticker.dart';
// import 'package:landingpage/src/ui/library_page.dart'; // PlaylistSheet, PlaylistCard
import 'package:landingpage/src/ui/screens/library.dart';
import 'package:landingpage/src/ui/widgets/lyric_ticker.dart';
import 'package:landingpage/src/utils/app_theme.dart';
import 'package:landingpage/src/utils/colors.dart';

class PlaylistMenuPage extends StatefulWidget {
  const PlaylistMenuPage({super.key, required bool isDarkMode});

  @override
  State<PlaylistMenuPage> createState() => _PlaylistMenuPageState();
}

class _PlaylistMenuPageState extends State<PlaylistMenuPage> {
  @override
  void initState() {
    super.initState();
    AppTheme.instance.load();
  }

  Future<void> _toggleTheme() => AppTheme.instance.toggleDark();

  Future<void> _openPlaylist(Playlist playlist) =>
      openPlaylistSheet(context, playlist, AppTheme.instance.isDarkMode);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppTheme.instance,
      builder: (context, _) {
        final isDarkMode = AppTheme.instance.isDarkMode;
        final textColor = AppColors.textPrimary(isDarkMode);
        final subTextColor = AppColors.textSecondary(isDarkMode);

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
                      showLoginButton: false,
                      activePage: "Playlist",
                      onToggleTheme: _toggleTheme,
                      leading: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.textPrimary(isDarkMode),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                        children: [
                          Text(
                            "Playlists",
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${playlists.length} playlists",
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              color: subTextColor,
                            ),
                          ),
                          const SizedBox(height: 22),
                          if (playlists.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 70),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.queue_music_rounded,
                                    size: 46,
                                    color: AppColors.textFaint(isDarkMode),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "No playlists yet",
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary(isDarkMode),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: playlists.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 14,
                                    crossAxisSpacing: 14,
                                    childAspectRatio: 1.8,
                                  ),
                              itemBuilder: (context, i) {
                                final playlist = playlists[i];
                                return _PlaylistCardWithLyrics(
                                  playlist: playlist,
                                  isDarkMode: isDarkMode,
                                  cardIndex: i,
                                  onTap: () => _openPlaylist(playlist),
                                );
                              },
                            ),
                        ],
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

class _PlaylistCardWithLyrics extends StatelessWidget {
  final Playlist playlist;
  final bool isDarkMode;
  final int cardIndex;
  final VoidCallback onTap;

  const _PlaylistCardWithLyrics({
    required this.playlist,
    required this.isDarkMode,
    required this.cardIndex,
    required this.onTap,
  });

  static const List<String> _cardBackgrounds = [
    'images/con2.png',
    'images/con3.png',
    'images/con4.png',
    'images/con5.png',
  ];

  @override
  Widget build(BuildContext context) {
    final backgroundImage =
        _cardBackgrounds[cardIndex % _cardBackgrounds.length];

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          PlaylistCard(
            playlist: playlist,
            isDarkMode: isDarkMode,
            onTap: onTap,
            backgroundImage: backgroundImage,
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 58,
            child: IgnorePointer(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: LyricTicker(cardIndex: cardIndex, big: true),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> openPlaylistSheet(
  BuildContext context,
  Playlist playlist,
  bool isDarkMode,
) async {
  final ids = await songIdsForPlaylist(playlist);
  final songs = ids.map(songById).whereType<Song>().toList();
  if (!context.mounted) return;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => PlaylistSheet(
      playlist: playlist,
      songs: songs,
      isDarkMode: isDarkMode,
      onLikeToggle: LibraryState.instance.toggleLiked,
      onPlay: (song) => LibraryState.instance.markPlayed(song.id),
    ),
  );
}
