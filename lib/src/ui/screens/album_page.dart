import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:landingpage/src/models/app_theme.dart';
// import 'package:landingpage/src/ui/custom/album_cover_art.dart';
import 'package:landingpage/src/ui/custom/artist_cover_art.dart';
import 'package:landingpage/src/ui/custom/custom_appbar.dart';
import 'package:landingpage/src/ui/screens/album_detail_page.dart';
import 'package:landingpage/src/utils/app_theme.dart';
import 'package:landingpage/src/utils/colors.dart';
import 'package:landingpage/src/models/album_data.dart';

class AlbumsPage extends StatefulWidget {
  const AlbumsPage({super.key});

  @override
  State<AlbumsPage> createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage> {
  @override
  void initState() {
    super.initState();
    AppTheme.instance.load();
  }

  void _openAlbum(Album album) {
    Navigator.of(context).push(
      MaterialPageRoute(
        // If this doesn't compile: AlbumDetailPage's constructor doesn't
        // have a parameter literally named `albumId`, or `Album` doesn't
        // have an `.id` field. Check album_detail_page.dart / album_data.dart.
        builder: (_) => AlbumDetailPage(albumId: album.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1100
        ? 5
        : (width > 800 ? 4 : (width > 550 ? 3 : 2));

    return AnimatedBuilder(
      animation: AppTheme.instance,
      builder: (context, _) {
        final isDarkMode = AppTheme.instance.isDarkMode;

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
                child: Column(
                  children: [
                    CustomAppBar(
                      isDarkMode: !isDarkMode,
                      showLoginButton: false,
                      activePage: "Albums",
                      onToggleTheme: AppTheme.instance.toggleDark,
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                        itemCount: allAlbums.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 22,
                          childAspectRatio: 0.78,
                        ),
                        itemBuilder: (context, index) {
                          // If this doesn't compile: `allAlbums` isn't a
                          // List<Album>, or Album doesn't have the fields
                          // _AlbumCard reads below (.id, .title, .artist).
                          final album = allAlbums[index];
                          return _AlbumCard(
                            isDarkMode: isDarkMode,
                            album: album,
                            onTap: () => _openAlbum(album),
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
}

class _AlbumCard extends StatelessWidget {
  final bool isDarkMode;
  final Album album;
  final VoidCallback onTap;

  const _AlbumCard({
    required this.isDarkMode,
    required this.album,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: AlbumCoverArt(
                  albumTitle: album.title,
                  artistName: album.artist,
                  gradientColors: const [
                    Color.fromARGB(255, 92, 75, 131),
                    Color.fromARGB(255, 101, 81, 132),
                  ],
                  borderRadius: 20,
                  border: Border.all(
                    // Was reading AppTheme.instance.isDarkMode directly —
                    // switched to the isDarkMode param this widget
                    // already receives, so it can't drift out of sync.
                    color: isDarkMode ? Colors.white : Colors.black,
                    width: 3,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x806D28D9),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            album.title,
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
            album.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              color: AppColors.textSecondary(isDarkMode),
            ),
          ),
        ],
      ),
    );
  }
}
