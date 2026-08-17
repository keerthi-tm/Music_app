import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:landingpage/main.dart';
import 'package:landingpage/src/forms/login_page.dart';
import 'package:landingpage/src/ui/screens/album_page.dart';
import 'package:landingpage/src/ui/screens/artist_page.dart';
import 'package:landingpage/src/ui/screens/discover.dart';
import 'package:landingpage/src/ui/screens/homepage.dart';
import 'package:landingpage/src/ui/screens/library.dart';
import 'package:landingpage/src/ui/screens/playlist.dart';
import 'package:landingpage/src/ui/screens/settings_page.dart';
// import 'package:landingpage/src/ui/screens/library_page.dart';
import 'package:landingpage/src/utils/colors.dart';

class CustomAppBar extends StatelessWidget {
  final bool isDarkMode;
  final bool showLoginButton;
  final bool showMenu;
  final String activePage;
  final VoidCallback onToggleTheme;
  final Widget? leading;

  static const Color _iconPurple = Color(0xFF6A1B9A);

  const CustomAppBar({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    this.showLoginButton = true,
    this.showMenu = true,
    this.activePage = "",
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final bool isLoggedIn = currentUser != null;

    return Column(
      children: [
        const SizedBox(height: 30),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.12) // Dark mode
                      : Colors.black.withValues(alpha: 0.06), // Light mode
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.black.withValues(alpha: 0.50) // Dark mode
                        : Colors.white.withValues(alpha: 0.50), // Light mode
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.35) // Dark mode
                          : Colors.black.withValues(alpha: 0.35), // Light mode
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'images/glogo.png',
                          width: 45,
                          height: 45,
                          fit: BoxFit.contain,
                        ),

                        const SizedBox(width: 0),

                        Text(
                          "Lizzen",
                          style: TextStyle(
                            color: isDarkMode ? Colors.black : Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    if (showMenu) ...[
                      Row(
                        children: [
                          _menuItem(
                            context,
                            "Home",
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HomePage(isDarkMode: true),
                                ),
                              );
                            },
                            isDarkMode,
                            isActive: activePage == "Home",
                          ),

                          const SizedBox(width: 25),

                          _menuItem(
                            context,
                            "Discover",
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DiscoverPage(),
                                ),
                              );
                            },
                            isDarkMode,
                            isActive: activePage == "Discover",
                          ),

                          const SizedBox(width: 25),

                          _menuItem(
                            context,
                            "Library",
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LibraryPage(isDarkMode: true),
                                ),
                              );
                            },
                            isDarkMode,
                            isActive: activePage == "Library",
                          ),

                          const SizedBox(width: 25),

                          _menuItem(
                            context,
                            "Albums",
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AlbumsPage(),
                                ),
                              );
                            },
                            isDarkMode,
                            isActive: activePage == "Albums",
                          ),

                          const SizedBox(width: 25),

                          _menuItem(
                            context,
                            "Artists",
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ArtistsPage(),
                                ),
                              );
                            },
                            isDarkMode,
                            isActive: activePage == "Artists",
                          ),

                          const SizedBox(width: 25),

                          _menuItem(
                            context,
                            "Playlist",
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PlaylistMenuPage(isDarkMode: isDarkMode),
                                ),
                              );
                            },
                            isDarkMode,
                            isActive: activePage == "Playlist",
                          ),
                        ],
                      ),
                      const SizedBox(width: 25),
                    ],

                    const SizedBox(width: 14),
                    _themeToggleButton(),

                    const SizedBox(width: 16),

                    if (isLoggedIn)
                      _UserMenuButton(
                        isDarkMode: isDarkMode,
                        username:
                            currentUser.displayName ??
                            currentUser.email ??
                            "User",
                        onMenuTap: (anchor) =>
                            _handleUserMenu(context, isDarkMode, anchor),
                      )
                    else if (showLoginButton)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginPage(),
                                  ),
                                );
                              },
                              child: Container(
                                height: 35,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                ),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? AppColors.lavenderAccent.withOpacity(
                                          0.25,
                                        )
                                      : AppColors.lavenderAccent.withOpacity(
                                          0.30,
                                        ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isDarkMode
                                        ? AppColors.lavenderAccent.withOpacity(
                                            0.40,
                                          )
                                        : AppColors.lavenderAccent.withOpacity(
                                            0.40,
                                          ),
                                    width: 1.2,
                                  ),
                                ),
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? _iconPurple
                                        : const Color.fromARGB(
                                            255,
                                            250,
                                            250,
                                            251,
                                          ),
                                  ),
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
        ),

        // Container(
        //   margin: const EdgeInsets.only(top: 5),
        //   width: 70,
        //   height: 5,
        //   decoration: BoxDecoration(
        //     color: AppColors.purpleAccent,
        //     borderRadius: BorderRadius.circular(20),
        //   ),
        // ),
      ],
    );
  }

  static Future<void> _handleUserMenu(
    BuildContext context,
    bool isDarkMode,
    Offset anchor,
  ) async {
    final String? choice = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "dismiss",
      barrierColor: Colors.black.withOpacity(0.45),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _UserMenuPopup(isDarkMode: !isDarkMode, anchor: anchor);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeIn,
        );
        return Opacity(
          opacity: animation.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.85 + (0.15 * curved.value),
            alignment: Alignment.topRight,
            child: child,
          ),
        );
      },
    );

    if (!context.mounted || choice == null) return;

    switch (choice) {
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SettingsPage(isDarkMode: isDarkMode),
          ),
        );
        break;
      case 'logout':
        _confirmLogout(context, isDarkMode, anchor);
        break;
    }
  }

  static Future<void> _confirmLogout(
    BuildContext context,
    bool isDarkMode,
    Offset anchor,
  ) async {
    final bool? confirmed = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "dismiss",
      barrierColor: Colors.black.withOpacity(0.45),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _LogoutPopup(isDarkMode: !isDarkMode, anchor: anchor);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeIn,
        );
        return Opacity(
          opacity: animation.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.85 + (0.15 * curved.value),
            alignment: Alignment.topRight,
            child: child,
          ),
        );
      },
    );

    if (confirmed != true) return;

    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  Widget _themeToggleButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggleTheme,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 60,
              height: 35,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.lavenderAccent.withOpacity(
                        0.25,
                      ) // dark mode bg tint (was white opacity)
                    : AppColors.lavenderAccent.withOpacity(
                        0.30,
                      ), // light mode bg tint
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDarkMode
                      ? AppColors.lavenderAccent.withOpacity(0.40)
                      : AppColors.lavenderAccent.withOpacity(0.40),
                  width: 1.2,
                ),
              ),
              child: Icon(
                isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: isDarkMode
                    ? _iconPurple
                    : const Color.fromARGB(255, 220, 198, 234),
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context,
    String text,
    VoidCallback onPressed,
    bool isDarkMode, {
    bool isActive = false,
  }) {
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setState) {
        final bool highlighted = isActive || isHovered;
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              foregroundColor: isDarkMode ? Colors.black : Colors.white,
              overlayColor: Colors.transparent,
              padding: EdgeInsets.zero,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 17,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isDarkMode ? Colors.black : Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 3,
                  width: highlighted ? 50 : 0,
                  decoration: BoxDecoration(
                    color: AppColors.purpleAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _UserMenuButton extends StatefulWidget {
  final bool isDarkMode;
  final String username;
  final void Function(Offset anchor) onMenuTap;

  const _UserMenuButton({
    required this.isDarkMode,
    required this.username,
    required this.onMenuTap,
  });

  @override
  State<_UserMenuButton> createState() => _UserMenuButtonState();
}

class _UserMenuButtonState extends State<_UserMenuButton> {
  final GlobalKey _iconKey = GlobalKey();

  Offset _iconBottomRightGlobal() {
    final RenderBox box =
        _iconKey.currentContext!.findRenderObject() as RenderBox;
    return box.localToGlobal(Offset(box.size.width, box.size.height));
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.username,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onMenuTap(_iconBottomRightGlobal()),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              key: _iconKey,
              width: 60,
              height: 35,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: widget.isDarkMode
                    ? AppColors.lavenderAccent.withOpacity(
                        0.25,
                      ) // dark mode bg tint (was white opacity)
                    : AppColors.lavenderAccent.withOpacity(
                        0.30,
                      ), // light mode bg tint
                border: Border.all(
                  color: widget.isDarkMode
                      ? AppColors.lavenderAccent.withOpacity(0.40)
                      : AppColors.lavenderAccent.withOpacity(0.40),
                  width: 1.2,
                ),
              ),
              child: Icon(
                Icons.person_rounded,
                color: widget.isDarkMode
                    ? CustomAppBar._iconPurple
                    : const Color.fromARGB(255, 223, 212, 229),
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UserMenuPopup extends StatelessWidget {
  final bool isDarkMode;
  final Offset anchor;

  const _UserMenuPopup({required this.isDarkMode, required this.anchor});

  @override
  Widget build(BuildContext context) {
    final Color accent = isDarkMode
        ? AppColors.lavenderAccent
        : AppColors.deepPurple;

    final Color cardColor = isDarkMode
        ? Colors.white.withOpacity(0.10)
        : Colors.white.withOpacity(0.85);

    final Color borderColor = isDarkMode
        ? Colors.white.withOpacity(0.18)
        : Colors.black.withOpacity(0.08);

    final Color textColor = isDarkMode ? Colors.white : Colors.black87;

    final Color logoutColor = isDarkMode ? Colors.white : Colors.black;

    const double popupWidth = 220;
    const double gap = 10;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: screenWidth - anchor.dx,
            top: anchor.dy + gap,
            child: SizedBox(
              width: popupWidth,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor, width: 1.4),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(0.35),
                          blurRadius: 30,
                          spreadRadius: 2,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _menuRow(
                          context,
                          icon: Icons.settings_outlined,
                          label: "Settings",
                          color: textColor,
                          onTap: () => Navigator.of(context).pop('settings'),
                        ),
                        const SizedBox(height: 8),

                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => Navigator.of(context).pop('logout'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 13,
                              ),
                              decoration: BoxDecoration(
                                color: logoutColor.withOpacity(0.16),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: logoutColor.withOpacity(0.45),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.logout_rounded,
                                    size: 19,
                                    color: logoutColor,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Logout",
                                    style: GoogleFonts.spaceGrotesk(
                                      color: logoutColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 19, color: color),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutPopup extends StatelessWidget {
  final bool isDarkMode;
  final Offset anchor;

  const _LogoutPopup({required this.isDarkMode, required this.anchor});

  @override
  Widget build(BuildContext context) {
    final Color accent = isDarkMode
        ? AppColors.lavenderAccent
        : AppColors.deepPurple;

    final Color cardColor = isDarkMode
        ? Colors.white.withOpacity(0.10)
        : Colors.white.withOpacity(0.85);

    final Color borderColor = isDarkMode
        ? Colors.white.withOpacity(0.18)
        : Colors.black.withOpacity(0.08);

    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color subTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    const double popupWidth = 260;
    const double gap = 10;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: screenWidth - anchor.dx,
            top: anchor.dy + gap,
            child: SizedBox(
              width: popupWidth,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor, width: 1.4),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(0.35),
                          blurRadius: 30,
                          spreadRadius: 2,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Log Out",
                          style: GoogleFonts.spaceGrotesk(
                            color: accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.5,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Are you sure you want to log out of Lizzen?",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.spaceGrotesk(
                            color: textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 22),

                        Row(
                          children: [
                            // CANCEL
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: isDarkMode
                                        ? Colors.white.withOpacity(0.25)
                                        : Colors.black.withOpacity(0.15),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  "Cancel",
                                  style: GoogleFonts.spaceGrotesk(
                                    color: subTextColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            Expanded(
                              child: ElevatedButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDarkMode
                                      ? Colors.white
                                      : const Color(0xFF6A1B9A),
                                  foregroundColor: isDarkMode
                                      ? Colors.black
                                      : Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  "Logout",
                                  style: GoogleFonts.spaceGrotesk(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    decoration: TextDecoration.none,
                                  ),
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
          ),
        ],
      ),
    );
  }
}
