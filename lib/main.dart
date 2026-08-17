import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:landingpage/firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:landingpage/src/ui/custom/custom_appbar.dart';
import 'package:landingpage/src/ui/screens/dashboard.dart';
import 'package:landingpage/src/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // debugPaintSizeEnabled = true;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const DashboardPage();
        }
        return const MusicLayout(); //
      },
    );
  }
}

class MusicLayout extends StatefulWidget {
  const MusicLayout({super.key});

  @override
  State<MusicLayout> createState() => _MusicLayoutState();
}

class _MusicLayoutState extends State<MusicLayout> {
  final ScrollController _scrollController = ScrollController();
  bool isAtBottom = false;
  bool isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? true;
    });
  }

  Future<void> _saveThemePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final phoneWidth = size.width * 0.18;
    final gap = size.width * 0.02;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: "scrollButton",
        mini: true,
        onPressed: () async {
          if (!isAtBottom) {
            await _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
            );

            setState(() {
              isAtBottom = true;
            });
          } else {
            await _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
            );

            setState(() {
              isAtBottom = false;
            });
          }
        },

        backgroundColor: isDarkMode ? AppColors.deepPurple : Colors.white,

        foregroundColor: isDarkMode ? Colors.white : AppColors.deepPurple,

        elevation: 8,

        child: Icon(
          isAtBottom
              ? Icons.keyboard_arrow_up_rounded
              : Icons.keyboard_arrow_down_rounded,
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? AppColors.backgroundDarkAlt
                : AppColors.backgroundLightAlt,
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [
              CustomAppBar(
                isDarkMode: !isDarkMode,
                showMenu: false,
                onToggleTheme: () {
                  setState(() => isDarkMode = !isDarkMode);
                  _saveThemePreference(isDarkMode);
                },
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,

                  child: Padding(
                    padding: const EdgeInsets.only(top: 25, bottom: 20),

                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          // COLUMN 1
                          Column(
                            children: [
                              PhoneCard(
                                isDarkMode: isDarkMode,
                                width: phoneWidth,
                                height: size.height * 0.64,
                                image: "images/singer.png",
                                title: "Discover",
                                subtitle: "Feel the rhythm",
                                buttonText: "Explore",
                                titleSize: 24,
                                titleColor: Colors.white,
                                subtitleSize: 14,
                                subtitleColor: Colors.white,
                              ),

                              SizedBox(height: gap),

                              PhoneCard(
                                isDarkMode: isDarkMode,
                                width: phoneWidth,
                                height: size.height * 0.51,
                                image: "images/card2.png",
                                title: "Listen",
                                subtitle: "Your favorite tracks",
                                buttonText: "Play",
                                titleSize: 24,
                                titleColor: Colors.white,
                                subtitleSize: 14,
                                subtitleColor: Colors.white,
                              ),
                            ],
                          ),

                          SizedBox(width: gap),

                          // COLUMN 2
                          Column(
                            children: [
                              PhoneCard(
                                isDarkMode: isDarkMode,
                                width: phoneWidth,
                                height: size.height * 0.46,
                                image: "images/card3.png",
                                title: "Artists",
                                subtitle: "Popular Now",
                                buttonText: "View",
                                titleSize: 24,
                                titleColor: Colors.white,
                                subtitleSize: 14,
                                subtitleColor: Colors.white,
                              ),

                              SizedBox(height: gap),

                              PhoneCard(
                                isDarkMode: isDarkMode,
                                width: phoneWidth,
                                height: size.height * 0.60,
                                image: "images/card4.png",
                                title: "Albums",
                                subtitle: "New Releases",
                                buttonText: "Browse",
                                titleSize: 24,
                                titleColor: Colors.white,
                                subtitleSize: 14,
                                subtitleColor: Colors.white,
                              ),
                            ],
                          ),

                          SizedBox(width: gap),

                          // COLUMN 3
                          Column(
                            children: [
                              PhoneCard(
                                isDarkMode: isDarkMode,
                                width: phoneWidth,
                                height: size.height * 0.68,
                                image: "images/card5.png",
                                title: "Playlists",
                                subtitle: "Curated for you",
                                buttonText: "Listen",
                                titleSize: 24,
                                titleColor: Colors.white,
                                subtitleSize: 14,
                                subtitleColor: Colors.white,
                              ),

                              SizedBox(height: gap),

                              PhoneCard(
                                isDarkMode: isDarkMode,
                                width: phoneWidth,
                                height: size.height * 0.48,
                                image: "images/card6.png",
                                title: "Favorites",
                                subtitle: "Your Collection",
                                buttonText: "Open",
                                titleSize: 24,
                                titleColor: Colors.white,
                                subtitleSize: 14,
                                subtitleColor: Colors.white,
                              ),
                            ],
                          ),

                          SizedBox(width: gap),

                          // COLUMN 4
                          Column(
                            children: [
                              PhoneCard(
                                isDarkMode: isDarkMode,
                                width: phoneWidth,
                                height: size.height * 0.54,
                                image: "images/card7.png",
                                title: "Radio",
                                subtitle: "Live Stations",
                                buttonText: "Tune In",
                                titleSize: 24,
                                titleColor: Colors.white,
                                subtitleSize: 14,
                                subtitleColor: Colors.white,
                              ),

                              SizedBox(height: gap),

                              PhoneCard(
                                isDarkMode: isDarkMode,
                                width: phoneWidth,
                                height: size.height * 0.40,
                                image: "images/card8.png",
                                title: "Podcasts",
                                subtitle: "Discover Stories",
                                buttonText: "Listen",
                                titleSize: 24,
                                titleColor: Colors.white,
                                subtitleSize: 14,
                                subtitleColor: Colors.white,
                              ),
                            ],
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

class PhoneCard extends StatefulWidget {
  final double width;
  final double height;
  final String image;
  final String title;
  final String subtitle;
  final String buttonText;
  final double titleSize;
  final Color titleColor;
  final double subtitleSize;
  final Color subtitleColor;
  final bool isDarkMode;

  const PhoneCard({
    super.key,
    required this.width,
    required this.height,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.titleSize,
    required this.titleColor,
    required this.subtitleSize,
    required this.subtitleColor,
    required this.isDarkMode,
  });

  @override
  State<PhoneCard> createState() => _PhoneCardState();
}

class _PhoneCardState extends State<PhoneCard> {
  bool isHovered = false;
  bool isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovered = false;
        });
      },
      child: AnimatedScale(
        scale: isHovered ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isHovered
                  ? (widget.isDarkMode ? Colors.white : Colors.black)
                  : (widget.isDarkMode ? Colors.black : Colors.white),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: isHovered ? 28 : 12,
                spreadRadius: isHovered ? 2 : 0,
                offset: Offset(0, isHovered ? 18 : 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              /// BACKGROUND IMAGE
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: Image.asset(widget.image, fit: BoxFit.cover),
                ),
              ),

              /// DARK OVERLAY
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    color: widget.isDarkMode
                        ? Colors.black.withValues(alpha: 0.35)
                        : Colors.white.withValues(alpha: 0.18),
                  ),
                ),
              ),

              /// WHITE HOVER OVERLAY
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      color: widget.isDarkMode
                          ? Colors.white.withValues(
                              alpha: isHovered ? 0.22 : 0.0,
                            )
                          : Colors.black.withValues(
                              alpha: isHovered ? 0.30 : 0.0,
                            ),
                    ),
                  ),
                ),
              ),

              /// TITLE & SUBTITLE
              Positioned(
                top: 40,
                left: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isDarkMode
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: widget.titleSize,
                          color: widget.titleColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: widget.subtitleSize,
                          color: widget.subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// BUTTON
              Positioned(
                bottom: 20,
                left: 18,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Placeholder(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepPurple,

                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                  ),
                  child: Text(
                    widget.buttonText,
                    style: GoogleFonts.spaceGrotesk(),
                  ),
                ),
              ),

              /// PHONE NOTCH
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    width: widget.width * 0.22,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(20),
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
