import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:landingpage/src/forms/login_page.dart';
import 'package:landingpage/src/ui/custom/custom_appbar.dart';
// import 'package:landingpage/src/ui/custom/lyric_ticker.dart';
import 'package:landingpage/src/ui/widgets/lyric_ticker.dart';
import 'package:landingpage/src/utils/app_theme.dart';
import 'package:landingpage/src/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  @Deprecated('HomePage now follows AppTheme.instance. This value is ignored.')
  final bool? isDarkMode;
  const HomePage({super.key, this.isDarkMode});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final AnimationController _blobController;

  final List<(IconData, String)> moods = const [
    (Icons.nightlight_round, "Chill"),
    (Icons.celebration_rounded, "Party"),
    (Icons.center_focus_strong_rounded, "Focus"),
    (Icons.bedtime_rounded, "Sleep"),
    (Icons.directions_run_rounded, "Energy"),
  ];

  final List<(IconData, String, String, List<Color>, String)> features = const [
    (
      Icons.graphic_eq_rounded,
      "Discover",
      "Fresh sounds daily",
      AppColors.primaryGradient,
      "images/con1.png",
    ),
    (
      Icons.favorite_rounded,
      "Favorites",
      "Your saved tracks",
      [Color.fromARGB(255, 233, 224, 218), Color.fromARGB(255, 210, 68, 239)],
      "images/con2.png",
    ),
    (
      Icons.queue_music_rounded,
      "Playlists",
      "Curated for you",
      [AppColors.cyan, AppColors.blue],
      "images/con3.png",
    ),
    (
      Icons.radio_rounded,
      "Live Radio",
      "Tune in now",
      [Color.fromARGB(255, 225, 151, 208), Color.fromARGB(255, 109, 25, 104)],
      "images/con4.png",
    ),
    (
      Icons.mic_rounded,
      "Podcasts",
      "Stories & talk",
      [AppColors.violet, AppColors.indigo],
      "images/con5.png",
    ),
    (
      Icons.trending_up_rounded,
      "Trending",
      "What's hot now",
      [Color.fromARGB(255, 242, 235, 236), Color.fromARGB(255, 251, 60, 222)],
      "images/con6.png",
    ),
  ];

  @override
  void initState() {
    super.initState();
    AppTheme.instance.load();
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginAndPrompt();
    });
  }

  void _checkLoginAndPrompt() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null && mounted) {
      _showLoginPrompt();
    }
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _LoginPromptDialog(
          isDarkMode: AppTheme.instance.isDarkMode,
          onLogin: () async {
            Navigator.of(dialogContext).pop();
            await _goToLogin();
          },
        );
      },
    );
  }

  Future<void> _goToLogin() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LoginPage()));
    if (!mounted) return;
    setState(() {});
    _checkLoginAndPrompt();
  }

  Future<void> _toggleTheme() => AppTheme.instance.toggleDark();

  @override
  void dispose() {
    _blobController.dispose();
    super.dispose();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
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

              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _blobController,
                    builder: (context, _) {
                      final size = MediaQuery.of(context).size;
                      final t = _blobController.value; // 0 -> 1 loop
                      return Stack(
                        children: _notes.map((note) {
                          return _FloatingNote(
                            progress: t,
                            note: note,
                            screenSize: size,
                            isDarkMode: isDarkMode,
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    CustomAppBar(
                      isDarkMode: !isDarkMode,
                      showLoginButton: isLoggedOut,
                      activePage: "Home",
                      onToggleTheme: _toggleTheme,
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _greeting,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 15,
                                        color: subTextColor,
                                      ),
                                    ),
                                    Text(
                                      "What's the vibe today? \u{1F3A7}",
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 26),

                          // Mood chips
                          SizedBox(
                            height: 46,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: moods.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (context, i) {
                                final (icon, label) = moods[i];
                                return _MoodChip(
                                  icon: icon,
                                  label: label,
                                  isDarkMode: isDarkMode,
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 28),

                          // "Now playing" glass banner
                          _NowPlayingCard(isDarkMode: isDarkMode),

                          const SizedBox(height: 30),

                          Text(
                            "Jump back in",
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 14),

                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: features.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 14,
                                  crossAxisSpacing: 14,
                                  childAspectRatio: 1.8,
                                ),
                            itemBuilder: (context, i) {
                              final (icon, title, subtitle, colors, image) =
                                  features[i];
                              return _FeatureCard(
                                icon: icon,
                                title: title,
                                subtitle: subtitle,
                                gradientColors: colors,
                                image: image,
                                cardIndex: i,
                                isDarkMode: isDarkMode,
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

class _NoteSpec {
  final IconData icon;
  final double xFraction;
  final double size;
  final double speed;
  final double phase;
  final double sway;
  final Color color;

  const _NoteSpec({
    required this.icon,
    required this.xFraction,
    required this.size,
    required this.speed,
    required this.phase,
    required this.sway,
    required this.color,
  });
}

const List<_NoteSpec> _notes = [
  const _NoteSpec(
    icon: Icons.music_note_rounded,
    xFraction: 0.08,
    size: 60,
    speed: 1.0,
    phase: 0.0,
    sway: 26,
    color: AppColors.primaryPurple,
  ),
  const _NoteSpec(
    icon: Icons.music_note_rounded,
    xFraction: 0.85,
    size: 48,
    speed: 1.35,
    phase: 0.15,
    sway: 20,
    color: AppColors.primaryPink,
  ),
  const _NoteSpec(
    icon: Icons.audiotrack_rounded,
    xFraction: 0.25,
    size: 44,
    speed: 0.8,
    phase: 0.35,
    sway: 18,
    color: AppColors.cyan,
  ),
  const _NoteSpec(
    icon: Icons.queue_music_rounded,
    xFraction: 0.65,
    size: 56,
    speed: 1.15,
    phase: 0.55,
    sway: 28,
    color: AppColors.orange,
  ),
  const _NoteSpec(
    icon: Icons.music_note_rounded,
    xFraction: 0.45,
    size: 38,
    speed: 1.6,
    phase: 0.7,
    sway: 16,
    color: AppColors.green,
  ),
  const _NoteSpec(
    icon: Icons.library_music_rounded,
    xFraction: 0.05,
    size: 52,
    speed: 0.95,
    phase: 0.85,
    sway: 22,
    color: AppColors.violet,
  ),
  const _NoteSpec(
    icon: Icons.music_note_rounded,
    xFraction: 0.92,
    size: 42,
    speed: 1.25,
    phase: 0.45,
    sway: 20,
    color: AppColors.rose,
  ),
];

class _FloatingNote extends StatelessWidget {
  final double progress;
  final _NoteSpec note;
  final Size screenSize;
  final bool isDarkMode;

  const _FloatingNote({
    required this.progress,
    required this.note,
    required this.screenSize,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final localT = (progress * note.speed + note.phase) % 1.0;
    final travel = screenSize.height + 120;
    final y = screenSize.height + 60 - (localT * travel);
    final wobble = note.sway * _sway(localT);

    double opacity;
    if (localT < 0.12) {
      opacity = localT / 0.12;
    } else if (localT > 0.85) {
      opacity = (1.0 - localT) / 0.15;
    } else {
      opacity = 1.0;
    }
    opacity = opacity.clamp(0.0, 1.0) * (isDarkMode ? 0.55 : 0.35);

    return Positioned(
      left: (screenSize.width * note.xFraction) + wobble,
      top: y,
      child: Opacity(
        opacity: opacity,
        child: Icon(note.icon, size: note.size, color: note.color),
      ),
    );
  }

  double _sway(double t) {
    final angle = t * 2 * 3.14159265;
    return math.sin(angle);
  }
}

class _LoginPromptDialog extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onLogin;

  const _LoginPromptDialog({required this.isDarkMode, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    final accentGradient = AppColors.accentGradient(
      AppTheme.instance.accentColor,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: isDarkMode
                  ? const Color(0xff220833).withValues(alpha: 0.96)
                  : Colors.white.withValues(alpha: 0.94),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.14)
                    : Colors.black.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: isDarkMode ? 0.5 : 0.15,
                  ),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: accentGradient),
                  ),
                  child: const Icon(
                    Icons.lock_person_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Login to continue",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Sign in to unlock your playlists, favorites, and personalized mixes.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: isDarkMode ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onLogin,
                    style:
                        ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ).copyWith(
                          backgroundColor: WidgetStateProperty.all(
                            Colors.transparent,
                          ),
                        ),
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(16),
                        ),
                        gradient: LinearGradient(colors: accentGradient),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          "Log In",
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _GlassCircle extends StatelessWidget {
  final bool isDarkMode;
  final IconData icon;
  const _GlassCircle({required this.isDarkMode, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.glassSurface(
              isDarkMode,
              darkAlpha: 0.12,
              lightAlpha: 0.06,
            ),
            border: Border.all(
              color: AppColors.glassBorder(
                isDarkMode,
                darkAlpha: 0.25,
                lightAlpha: 0.15,
              ),
            ),
          ),
          child: Icon(icon, color: isDarkMode ? Colors.white : Colors.black87),
        ),
      ),
    );
  }
}

class _MoodChip extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isDarkMode;
  const _MoodChip({
    required this.icon,
    required this.label,
    required this.isDarkMode,
  });

  @override
  State<_MoodChip> createState() => _MoodChipState();
}

class _MoodChipState extends State<_MoodChip> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    final accentGradient = AppColors.accentGradient(
      AppTheme.instance.accentColor,
    );

    return GestureDetector(
      onTap: () => setState(() => selected = !selected),
      child: AnimatedContainer(
        duration: AppTheme.instance.animDuration,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? LinearGradient(colors: accentGradient) : null,
          color: selected
              ? null
              : AppColors.glassSurface(
                  widget.isDarkMode,
                  darkAlpha: 0.10,
                  lightAlpha: 0.05,
                ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : AppColors.glassBorder(
                    widget.isDarkMode,
                    darkAlpha: 0.2,
                    lightAlpha: 0.12,
                  ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              size: 16,
              color: selected
                  ? Colors.white
                  : (widget.isDarkMode ? Colors.white : Colors.black87),
            ),
            const SizedBox(width: 6),
            Text(
              widget.label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : (widget.isDarkMode ? Colors.white : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NowPlayingCard extends StatefulWidget {
  final bool isDarkMode;
  const _NowPlayingCard({required this.isDarkMode});

  @override
  State<_NowPlayingCard> createState() => _NowPlayingCardState();
}

class _NowPlayingCardState extends State<_NowPlayingCard> {
  bool isPlaying = true;
  bool isFavorited = false;
  int trackIndex = 0;
  double _progress = 0.42;

  final List<(String, String)> _tracks = const [
    ("Midnight Waves", "Chill Mix"),
    ("Solar Drift", "Focus Flow"),
    ("Neon Pulse", "Party Mix"),
  ];

  void _togglePlay() {
    setState(() => isPlaying = !isPlaying);
  }

  void _skip(int direction) {
    setState(() {
      trackIndex = (trackIndex + direction) % _tracks.length;
      if (trackIndex < 0) trackIndex += _tracks.length;
      _progress = 0.0;
    });
  }

  void _seek(double value) {
    setState(() => _progress = value.clamp(0.0, 1.0));
  }

  void _toggleFavorite() {
    setState(() => isFavorited = !isFavorited);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;
    final accentColor = AppTheme.instance.accentColor;
    final accentGradient = AppColors.accentGradient(accentColor);
    final (title, subtitle) = _tracks[trackIndex];

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            color: AppColors.glassSurface(
              isDarkMode,
              darkAlpha: 0.10,
              lightAlpha: 0.05,
            ),
            border: Border.all(color: AppColors.glassBorder(isDarkMode)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: AppTheme.instance.animDuration,
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(colors: accentGradient),
                      boxShadow: isPlaying
                          ? [
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.45),
                                blurRadius: 16,
                                spreadRadius: 1,
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      isPlaying
                          ? Icons.graphic_eq_rounded
                          : Icons.music_note_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.textPrimary(isDarkMode),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${isPlaying ? 'Now Playing' : 'Paused'} • $subtitle",
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: isDarkMode ? Colors.white60 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 5,
                            activeTrackColor: accentColor,
                            inactiveTrackColor: AppColors.glassBorder(
                              isDarkMode,
                              darkAlpha: 0.15,
                              lightAlpha: 0.08,
                            ),
                            thumbColor: accentColor,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 14,
                            ),
                            overlayColor: accentColor.withValues(alpha: 0.2),
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
                ],
              ),
              const SizedBox(height: 14),

              // Playback controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ControlButton(
                    icon: Icons.skip_previous_rounded,
                    isDarkMode: isDarkMode,
                    onTap: () => _skip(-1),
                  ),
                  const SizedBox(width: 18),
                  GestureDetector(
                    onTap: _togglePlay,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: accentGradient),
                      ),
                      child: Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  _ControlButton(
                    icon: Icons.skip_next_rounded,
                    isDarkMode: isDarkMode,
                    onTap: () => _skip(1),
                  ),
                  const SizedBox(width: 18),
                  _ControlButton(
                    icon: isFavorited
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    isDarkMode: isDarkMode,
                    activeColor: isFavorited ? accentColor : null,
                    onTap: _toggleFavorite,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final bool isDarkMode;
  final VoidCallback onTap;
  final Color? activeColor;

  const _ControlButton({
    required this.icon,
    required this.isDarkMode,
    required this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.instance.animDuration,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: activeColor != null
              ? activeColor!.withValues(alpha: 0.15)
              : AppColors.glassSurface(
                  isDarkMode,
                  darkAlpha: 0.10,
                  lightAlpha: 0.05,
                ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: activeColor ?? AppColors.textPrimary(isDarkMode),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final String image;
  final int cardIndex;
  final bool isDarkMode;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.image,
    required this.cardIndex,
    required this.isDarkMode,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedScale(
        scale: isHovered ? 1.04 : 1.0,
        duration: AppTheme.instance.animDuration,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isHovered
                  ? widget.gradientColors.first.withValues(alpha: 0.9)
                  : Colors.black.withValues(alpha: 0.3),
              width: 1.6,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isHovered ? 0.45 : 0.25),
                blurRadius: isHovered ? 22 : 10,
                offset: Offset(0, isHovered ? 12 : 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(widget.image, fit: BoxFit.cover),

                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.25),
                        Colors.black.withValues(alpha: 0.35),
                        Colors.black.withValues(alpha: 0.80),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),

                DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.gradientColors.first.withValues(
                      alpha: isHovered ? 0.18 : 0.08,
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Stack(
                    children: [
                      // Icon + title
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: widget.gradientColors,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.gradientColors.first.withValues(
                                    alpha: 0.6,
                                  ),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.icon,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            widget.title,
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      // Lyric ticker
                      Positioned.fill(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: LyricTicker(
                              cardIndex: widget.cardIndex,
                              big: true,
                            ),
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
      ),
    );
  }
}
