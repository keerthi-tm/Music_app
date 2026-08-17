import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landingpage/src/ui/custom/custom_appbar.dart';
import 'package:landingpage/src/utils/colors.dart';
import 'package:landingpage/src/utils/app_theme.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    AppTheme.instance.load();
  }

  int selectedCategoryIndex = 0;
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = const [
    "Poppular Music",
    // "Playlist",
    // "Liked",
    "Pop Punk",
    "Viral Music",
    "Indie Music",
    "Pop",
    "Reggae",
  ];

  final List<Map<String, dynamic>> musicCards = const [
    {
      "title": "The Most Hitz\nMusic in 2023",
      "count": "220 Music List",
      "icon": Icons.headphones_rounded,
      "image": "images/card2.png",
      "colors": AppColors.cardHitz,
      "flex": 3,
      "showButton": true,
    },
    {
      "title": "Relax",
      "count": "220 Music List",
      "icon": Icons.self_improvement_rounded,
      "image": "images/card3.png",
      "colors": AppColors.cardRelax,
      "flex": 2,
      "showButton": true,
    },
    {
      "title": "Pop Punk",
      "count": "220 Music List",
      "icon": Icons.electric_bolt_rounded,
      "image": "images/card4.png",
      "colors": AppColors.cardPopPunk,
      "flex": 2,
      "showButton": true,
    },
    {
      "title": "Nostalgic Songs\n90s high school era",
      "count": "220 Music List",
      "icon": Icons.album_rounded,
      "image": "images/card5.png",
      "colors": AppColors.cardNostalgic,
      "flex": 3,
      "showButton": true,
    },
    {
      "title": "This song will shake\nyour spirits",
      "count": "220 Music List",
      "icon": Icons.graphic_eq_rounded,
      "image": "images/card7.png",
      "colors": AppColors.cardShakeSpirits,
      "flex": 3,
      "showButton": true,
    },
    {
      "title": "Viral Music",
      "count": "220 Music List",
      "icon": Icons.trending_up_rounded,
      "image": "images/card8.png",
      "colors": AppColors.cardViral,
      "flex": 2,
      "showButton": true,
    },
  ];

  List<String> get _filteredCategories {
    if (searchQuery.trim().isEmpty) return categories;
    final q = searchQuery.toLowerCase();
    return categories.where((c) => c.toLowerCase().contains(q)).toList();
  }

  List<Map<String, dynamic>> get _filteredMusicCards {
    if (searchQuery.trim().isEmpty) return musicCards;
    final q = searchQuery.toLowerCase();
    return musicCards
        .where((m) => (m["title"] as String).toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCategory(
    BuildContext context,
    String label, {
    List<Color>? colors,
    IconData? icon,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _CategoryPage(
          isDarkMode: AppTheme.instance.isDarkMode,
          category: label,
          accentColors: colors,
          accentIcon: icon,
        ),
      ),
    );
  }

  List<Widget> _buildMusicRows(BuildContext context, bool isDarkMode) {
    final cards = _filteredMusicCards;
    if (cards.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text(
              "No results for \"$searchQuery\"",
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: AppColors.textMuted(isDarkMode),
              ),
            ),
          ),
        ),
      ];
    }

    final rows = <Widget>[];
    for (int i = 0; i < cards.length; i += 2) {
      final first = cards[i];
      final hasSecond = i + 1 < cards.length;
      final second = hasSecond ? cards[i + 1] : null;

      rows.add(
        Row(
          children: [
            Expanded(
              flex: first["flex"] as int,
              child: _MusicCard(
                isDarkMode: isDarkMode,
                data: first,
                height: 210,
                onTap: () => _openCategory(
                  context,
                  first["title"] as String,
                  colors: first["colors"] as List<Color>,
                  icon: first["icon"] as IconData,
                ),
              ),
            ),
            if (second != null) ...[
              const SizedBox(width: 18),
              Expanded(
                flex: second["flex"] as int,
                child: _MusicCard(
                  isDarkMode: isDarkMode,
                  data: second,
                  height: 210,
                  onTap: () => _openCategory(
                    context,
                    second["title"] as String,
                    colors: second["colors"] as List<Color>,
                    icon: second["icon"] as IconData,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
      if (i + 2 < cards.length) rows.add(const SizedBox(height: 18));
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = (user?.displayName?.isNotEmpty ?? false)
        ? user!.displayName!
        : (user?.email?.split("@").first ?? "Listener");

    return AnimatedBuilder(
      animation: AppTheme.instance,
      builder: (context, _) {
        final bool isDarkMode = AppTheme.instance.isDarkMode;
        final size = MediaQuery.of(context).size;

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
                      onToggleTheme: AppTheme.instance.toggleDark,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 25, bottom: 40),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: size.width * 0.9,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _WelcomeCard(
                                  isDarkMode: isDarkMode,
                                  name: displayName,
                                ),
                                const SizedBox(height: 28),

                                _SearchBar(
                                  isDarkMode: isDarkMode,
                                  controller: _searchController,
                                  onChanged: (value) {
                                    setState(() => searchQuery = value);
                                  },
                                ),
                                const SizedBox(height: 18),

                                SizedBox(
                                  height: 42,
                                  child: _filteredCategories.isEmpty
                                      ? Center(
                                          child: Text(
                                            "No categories match",
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 13,
                                              color: AppColors.textMuted(
                                                isDarkMode,
                                              ),
                                            ),
                                          ),
                                        )
                                      : ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: _filteredCategories.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(width: 10),
                                          itemBuilder: (context, index) {
                                            final label =
                                                _filteredCategories[index];
                                            final originalIndex = categories
                                                .indexOf(label);
                                            return _CategoryChip(
                                              isDarkMode: isDarkMode,
                                              label: label,
                                              selected:
                                                  originalIndex ==
                                                  selectedCategoryIndex,
                                              onTap: () {
                                                setState(
                                                  () => selectedCategoryIndex =
                                                      originalIndex,
                                                );
                                                _openCategory(context, label);
                                              },
                                            );
                                          },
                                        ),
                                ),
                                const SizedBox(height: 30),

                                ..._buildMusicRows(context, isDarkMode),
                              ],
                            ),
                          ),
                        ),
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

class _WelcomeCard extends StatelessWidget {
  final bool isDarkMode;
  final String name;

  const _WelcomeCard({required this.isDarkMode, required this.name});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
          decoration: BoxDecoration(
            color: AppColors.glassSurface(isDarkMode),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.glassBorder(isDarkMode),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.deepPurple,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : "?",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome back, $name",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(isDarkMode),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Here's what's happening with your music today.",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: AppColors.textSecondary(isDarkMode),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final bool isDarkMode;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.isDarkMode,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.glassSurface(isDarkMode),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.glassBorder(isDarkMode),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  textInputAction: TextInputAction.search,
                  style: GoogleFonts.spaceGrotesk(
                    color: AppColors.textPrimary(isDarkMode),
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search",
                    hintStyle: GoogleFonts.spaceGrotesk(
                      color: AppColors.textMuted(isDarkMode),
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  if (value.text.isEmpty) return const SizedBox.shrink();
                  return IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.textMuted(isDarkMode),
                    ),
                    onPressed: () {
                      controller.clear();
                      onChanged("");
                    },
                  );
                },
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.deepPurpleAccent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatefulWidget {
  final bool isDarkMode;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _CategoryChip({
    required this.isDarkMode,
    required this.label,
    required this.selected,
    this.onTap,
  });

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool highlighted = widget.selected || isHovered;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: highlighted
                ? AppColors.deepPurpleAccent
                : AppColors.glassSurface(widget.isDarkMode, darkAlpha: 0.07),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: highlighted
                  ? AppColors.deepPurpleAccent
                  : AppColors.glassBorder(widget.isDarkMode),
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: highlighted
                  ? Colors.white
                  : AppColors.textSecondary(widget.isDarkMode),
            ),
          ),
        ),
      ),
    );
  }
}

class _MusicCard extends StatefulWidget {
  final bool isDarkMode;
  final Map<String, dynamic> data;
  final double height;
  final VoidCallback? onTap;

  const _MusicCard({
    required this.isDarkMode,
    required this.data,
    required this.height,
    this.onTap,
  });

  @override
  State<_MusicCard> createState() => _MusicCardState();
}

class _MusicCardState extends State<_MusicCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = widget.data["colors"] as List<Color>;
    final title = widget.data["title"] as String;
    final count = widget.data["count"] as String?;
    final showButton = widget.data["showButton"] as bool;
    final imagePath = widget.data["image"] as String?;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Container(
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: colors.last.withValues(
                      alpha: isHovered ? 0.45 : 0.25,
                    ),
                    blurRadius: isHovered ? 26 : 14,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imagePath != null)
                    Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: colors,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: colors,
                        ),
                      ),
                    ),

                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colors.first.withValues(alpha: 0.55),
                          Colors.black.withValues(alpha: 0.72),
                        ],
                      ),
                    ),
                  ),

                  // Foreground content
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (count != null) ...[
                              Text(
                                count,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                            if (showButton)
                              GestureDetector(
                                // separate tap target so the button visually
                                // reacts too, but triggers the same navigation
                                onTap: widget.onTap,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    "Listen Now",
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: colors.last,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Category detail page
///
/// Instead of a static placeholder, this now renders a themed hero header
/// (accent color / icon inferred from the category or card that was
/// tapped) plus a real, scrollable track list built in the same
/// glassmorphism style as the rest of the dashboard.
/// ---------------------------------------------------------------------
class _CategoryPage extends StatelessWidget {
  final bool isDarkMode;
  final String category;
  final List<Color>? accentColors;
  final IconData? accentIcon;

  const _CategoryPage({
    required this.isDarkMode,
    required this.category,
    this.accentColors,
    this.accentIcon,
  });

  // Fallback accent palette used whenever a card/category doesn't carry
  // its own colors (e.g. the horizontal category chips).
  static const Map<String, List<Color>> _paletteByKeyword = {
    "pop punk": AppColors.cardPopPunk,
    "viral": AppColors.cardViral,
    "indie": AppColors.cardRelax,
    "reggae": AppColors.cardNostalgic,
    "popular": AppColors.cardHitz,
    "pop": AppColors.cardShakeSpirits,
  };

  static const Map<String, IconData> _iconByKeyword = {
    "pop punk": Icons.electric_bolt_rounded,
    "viral": Icons.trending_up_rounded,
    "indie": Icons.self_improvement_rounded,
    "reggae": Icons.album_rounded,
    "popular": Icons.headphones_rounded,
    "pop": Icons.graphic_eq_rounded,
  };

  // Small curated track lists so every category feels distinct.
  static const Map<String, List<Map<String, String>>> _tracksByKeyword = {
    "pop punk": [
      {
        "title": "Skate Park Sunset",
        "artist": "The Broken Amps",
        "duration": "2:58",
      },
      {"title": "Basement Anthem", "artist": "Loud Static", "duration": "3:12"},
      {
        "title": "Fast Lane Feelings",
        "artist": "Velocity Kids",
        "duration": "2:41",
      },
      {
        "title": "Chorus of Chaos",
        "artist": "Neon Wreckage",
        "duration": "3:05",
      },
      {
        "title": "Runaway Riot",
        "artist": "The Broken Amps",
        "duration": "2:49",
      },
      {"title": "Stage Dive", "artist": "Loud Static", "duration": "3:20"},
    ],
    "viral": [
      {"title": "Trending Tonight", "artist": "Echo Bloom", "duration": "2:30"},
      {"title": "Algorithm Love", "artist": "Pixel Parade", "duration": "2:47"},
      {
        "title": "Fifteen Seconds Famous",
        "artist": "Clout Chaser",
        "duration": "2:19",
      },
      {"title": "On Repeat", "artist": "Echo Bloom", "duration": "3:01"},
      {"title": "Screen Time", "artist": "Pixel Parade", "duration": "2:55"},
      {
        "title": "Everybody's Talking",
        "artist": "Clout Chaser",
        "duration": "2:38",
      },
    ],
    "indie": [
      {"title": "Quiet Streets", "artist": "Paper Moths", "duration": "3:34"},
      {
        "title": "Cardigan Weather",
        "artist": "Slow Static",
        "duration": "3:11",
      },
      {"title": "Attic Light", "artist": "Paper Moths", "duration": "2:58"},
      {"title": "Wallflower", "artist": "Slow Static", "duration": "3:22"},
      {"title": "Corner Booth", "artist": "Faded Polaroid", "duration": "3:07"},
      {
        "title": "Small Town Sky",
        "artist": "Faded Polaroid",
        "duration": "2:44",
      },
    ],
    "reggae": [
      {"title": "Island Breeze", "artist": "Coral Roots", "duration": "3:45"},
      {"title": "Sunset Sway", "artist": "Golden Tide", "duration": "3:52"},
      {"title": "One Love Riddim", "artist": "Coral Roots", "duration": "3:29"},
      {
        "title": "Palm Tree Groove",
        "artist": "Golden Tide",
        "duration": "3:18",
      },
      {"title": "Coastal Vibes", "artist": "Reef Sound", "duration": "3:40"},
      {"title": "Easy Skanking", "artist": "Reef Sound", "duration": "3:33"},
    ],
    "popular": [
      {
        "title": "Neon Nights",
        "artist": "Midnight Circuit",
        "duration": "3:02",
      },
      {"title": "Top of the Chart", "artist": "Aria Vale", "duration": "2:54"},
      {
        "title": "City Lights Fade",
        "artist": "Midnight Circuit",
        "duration": "3:15",
      },
      {
        "title": "Golden Hour Anthem",
        "artist": "Aria Vale",
        "duration": "2:47",
      },
      {"title": "Heatwave", "artist": "Sable Rae", "duration": "3:09"},
      {"title": "Everybody Dance", "artist": "Sable Rae", "duration": "2:58"},
    ],
    "pop": [
      {"title": "Bright Side", "artist": "Willow Grace", "duration": "3:01"},
      {"title": "Feel It Now", "artist": "Nova Kelsey", "duration": "2:52"},
      {
        "title": "Champagne Skies",
        "artist": "Willow Grace",
        "duration": "3:07",
      },
      {"title": "Take It Slow", "artist": "Nova Kelsey", "duration": "3:14"},
      {"title": "Electric Heart", "artist": "June Halo", "duration": "2:49"},
      {"title": "Better With You", "artist": "June Halo", "duration": "3:03"},
    ],
  };

  String get _displayTitle => category.replaceAll("\n", " ");

  String get _matchKey {
    final lower = category.toLowerCase();
    for (final key in _tracksByKeyword.keys) {
      if (lower.contains(key)) return key;
    }
    return "popular";
  }

  List<Color> get _colors => accentColors ?? _paletteByKeyword[_matchKey]!;

  IconData get _icon => accentIcon ?? _iconByKeyword[_matchKey]!;

  List<Map<String, String>> get _tracks => _tracksByKeyword[_matchKey]!;

  @override
  Widget build(BuildContext context) {
    final colors = _colors;
    final tracks = _tracks;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? AppColors.backgroundDarkAlt
                : AppColors.categoryLightAlt,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textPrimary(isDarkMode),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _displayTitle,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(isDarkMode),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                  children: [
                    _CategoryHero(
                      isDarkMode: isDarkMode,
                      title: _displayTitle,
                      subtitle: "${tracks.length} Songs • Curated for you",
                      icon: _icon,
                      colors: colors,
                    ),
                    const SizedBox(height: 26),
                    Text(
                      "Tracklist",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(isDarkMode),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...List.generate(tracks.length, (index) {
                      final track = tracks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _TrackTile(
                          isDarkMode: isDarkMode,
                          index: index + 1,
                          title: track["title"]!,
                          artist: track["artist"]!,
                          duration: track["duration"]!,
                          accentColors: colors,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: colors.last,
                                content: Text(
                                  "Now playing \"${track["title"]}\"",
                                  style: GoogleFonts.spaceGrotesk(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryHero extends StatelessWidget {
  final bool isDarkMode;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;

  const _CategoryHero({
    required this.isDarkMode,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: colors.last.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: colors.last,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackTile extends StatefulWidget {
  final bool isDarkMode;
  final int index;
  final String title;
  final String artist;
  final String duration;
  final List<Color> accentColors;
  final VoidCallback? onTap;

  const _TrackTile({
    required this.isDarkMode,
    required this.index,
    required this.title,
    required this.artist,
    required this.duration,
    required this.accentColors,
    this.onTap,
  });

  @override
  State<_TrackTile> createState() => _TrackTileState();
}

class _TrackTileState extends State<_TrackTile> {
  bool isHovered = false;
  bool isLiked = false;
  bool isSaved = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isHovered
                    ? widget.accentColors.last.withValues(alpha: 0.16)
                    : AppColors.glassSurface(widget.isDarkMode),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isHovered
                      ? widget.accentColors.last.withValues(alpha: 0.5)
                      : AppColors.glassBorder(widget.isDarkMode),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 26,
                    child: Text(
                      "${widget.index}",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted(widget.isDarkMode),
                      ),
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: widget.accentColors,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.music_note_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(widget.isDarkMode),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.artist,

                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: AppColors.textSecondary(widget.isDarkMode),
                          ),
                        ),
                        const SizedBox(height: 6),

                        Row(
                          children: [
                            Icon(
                              Icons.graphic_eq_rounded,
                              color: Colors.greenAccent,
                              size: 15,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "Now Playing",
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.greenAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.duration,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: AppColors.textMuted(widget.isDarkMode),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Icon(
                    Icons.graphic_eq_rounded,
                    color: Colors.greenAccent,
                    size: 18,
                  ),

                  const SizedBox(width: 10),

                  IconButton(
                    tooltip: "Like",
                    splashRadius: 20,
                    icon: Icon(
                      isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isLiked
                          ? Colors.red
                          : AppColors.textMuted(widget.isDarkMode),
                    ),
                    onPressed: () {
                      setState(() {
                        isLiked = !isLiked;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            isLiked
                                ? "Added to Liked Songs ❤️"
                                : "Removed from Liked Songs",
                          ),
                        ),
                      );
                    },
                  ),

                  IconButton(
                    tooltip: "Save",
                    splashRadius: 20,
                    icon: Icon(
                      isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: isSaved
                          ? widget.accentColors.last
                          : AppColors.textMuted(widget.isDarkMode),
                    ),
                    onPressed: () {
                      setState(() {
                        isSaved = !isSaved;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            isSaved
                                ? "Saved to Library 💾"
                                : "Removed from Library",
                          ),
                        ),
                      );
                    },
                  ),

                  PopupMenuButton<String>(
                    tooltip: "More",
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: AppColors.textSecondary(widget.isDarkMode),
                    ),
                    onSelected: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text(value),
                        ),
                      );
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: "▶ Playing Now",
                        child: Text(
                          "Play Now",
                          style: TextStyle(
                            color: widget.isDarkMode
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        value: "⏭ Added to Queue",
                        child: Text(
                          "Play Next",
                          style: TextStyle(
                            color: widget.isDarkMode
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        value: "➕ Added to Playlist",
                        child: Text(
                          "Add to Playlist",
                          style: TextStyle(
                            color: widget.isDarkMode
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        value: "👤 Opening Artist",
                        child: Text(
                          "View Artist",
                          style: TextStyle(
                            color: widget.isDarkMode
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        value: "💿 Opening Album",
                        child: Text(
                          "View Album",
                          style: TextStyle(
                            color: widget.isDarkMode
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        value: "🔗 Share",
                        child: Text(
                          "Share",
                          style: TextStyle(
                            color: widget.isDarkMode
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
