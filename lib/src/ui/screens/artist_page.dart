import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landingpage/src/ui/custom/custom_appbar.dart';
import 'package:landingpage/src/ui/screens/artist_detail_page.dart';
import 'package:landingpage/src/utils/colors.dart';
import 'package:landingpage/src/utils/app_theme.dart';
import 'package:landingpage/src/models/artist_data.dart';
import 'package:landingpage/src/services/artist_photo_service.dart';

class ArtistsPage extends StatefulWidget {
  const ArtistsPage({super.key});

  @override
  State<ArtistsPage> createState() => _ArtistsPageState();
}

class _ArtistsPageState extends State<ArtistsPage> {
  @override
  void initState() {
    super.initState();
    // Idempotent: if Settings (or any other page) already loaded the
    // saved theme this session, this just returns immediately.
    AppTheme.instance.load();
  }

  void _openArtist(Artist artist, bool isDarkMode) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ArtistDetailPage(artistId: artist.id, isDarkMode: isDarkMode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder + AppTheme.instance is what makes this page repaint
    // the instant the theme changes anywhere in the app — including from
    // SettingsPage's Appearance tab.
    return AnimatedBuilder(
      animation: AppTheme.instance,
      builder: (context, _) {
        final bool isDarkMode = AppTheme.instance.isDarkMode;
        final width = MediaQuery.of(context).size.width;
        final crossAxisCount = width > 1100
            ? 5
            : width > 800
            ? 4
            : width > 550
            ? 3
            : 2;

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
                      activePage: "Artists",
                      onToggleTheme: AppTheme.instance.toggleDark,
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                        itemCount: allArtists.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 22,
                          childAspectRatio: 0.78,
                        ),
                        itemBuilder: (context, index) {
                          final artist = allArtists[index];
                          return _ArtistCard(
                            isDarkMode: isDarkMode,
                            artist: artist,
                            onTap: () => _openArtist(artist, isDarkMode),
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

class _ArtistCard extends StatefulWidget {
  final bool isDarkMode;
  final Artist artist;
  final VoidCallback onTap;

  const _ArtistCard({
    required this.isDarkMode,
    required this.artist,
    required this.onTap,
  });

  @override
  State<_ArtistCard> createState() => _ArtistCardState();
}

class _ArtistCardState extends State<_ArtistCard> {
  String? _fetchedUrl;
  bool _fetchDone = false;

  @override
  void initState() {
    super.initState();
    // Only hit the network if no manual link was pasted in artist_data.dart.
    if (widget.artist.imageUrl.isEmpty) {
      _loadPhoto();
    } else {
      _fetchDone = true;
    }
  }

  Future<void> _loadPhoto() async {
    final url = await ArtistPhotoService.fetch(widget.artist.name);
    if (!mounted) return;
    setState(() {
      _fetchedUrl = url;
      _fetchDone = true;
    });
  }

  Widget _fallbackIcon() => const Center(
    child: Icon(Icons.person_rounded, color: Colors.white70, size: 40),
  );

  @override
  Widget build(BuildContext context) {
    final artist = widget.artist;
    final isDarkMode = widget.isDarkMode;
    final resolvedUrl = artist.imageUrl.isNotEmpty
        ? artist.imageUrl
        : _fetchedUrl;

    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: artist.colors,
                ),
                boxShadow: [
                  BoxShadow(
                    color: artist.colors.last.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(
                child: resolvedUrl != null
                    ? Image.network(
                        resolvedUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) => _fallbackIcon(),
                      )
                    : (_fetchDone
                          ? _fallbackIcon()
                          : const Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white70,
                                ),
                              ),
                            )),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            artist.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.textPrimary(isDarkMode),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "${artist.songs.length} songs",
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
