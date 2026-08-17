import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landingpage/src/forms/login_page.dart';
// import 'package:landingpage/src/models/app_theme.dart';
import 'package:landingpage/src/ui/custom/custom_appbar.dart';
import 'package:landingpage/src/ui/widgets/glass_container.dart';
import 'package:landingpage/src/ui/widgets/settings_popup.dart';
import 'package:landingpage/src/utils/app_theme.dart';
import 'package:landingpage/src/utils/colors.dart';
// import 'package:landingpage/src/ui/widgets/update_photo_sheet.dart';

enum _SettingsTab { profile, account, appearance, playback }

/// Firebase only sets `displayName` for accounts created via Google (or
/// another provider that supplies one) — email/password sign-ups leave it
/// null, which used to show up as an empty/"null" name field. This falls
/// back to the part of the email before "@", formatted as a name
/// (e.g. "priya.raj" -> "Priya Raj").
String _resolveDisplayName(User? user) {
  final String? displayName = user?.displayName;
  if (displayName != null && displayName.trim().isNotEmpty) {
    return displayName;
  }

  final String? email = user?.email;
  if (email == null || email.isEmpty) return "";

  final String localPart = email.split('@').first;
  if (localPart.isEmpty) return "";

  return localPart
      .split(RegExp(r'[._]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required bool isDarkMode});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  _SettingsTab _tab = _SettingsTab.profile;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final TextEditingController _passwordController = TextEditingController(
    text: "••••••••••",
  );

  Uint8List? _avatarBytes;

  @override
  void initState() {
    super.initState();
    final User? user = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(text: _resolveDisplayName(user));
    _emailController = TextEditingController(text: user?.email ?? "");
    AppTheme.instance.load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _confirmSignOutAllDevices() async {
    final bool confirmed = await _showAccountConfirmDialog(
      icon: CupertinoIcons.arrow_right_square,
      title: "Sign Out",
      description:
          "This will sign you out of Lizzen on this device. You'll need to log back in to continue listening.",
      confirmLabel: "Sign Out",
    );
    if (!confirmed) return;

    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Couldn't sign out: $e")));
      }
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final bool confirmed = await _showAccountConfirmDialog(
      icon: CupertinoIcons.trash,
      title: "Delete Account",
      description:
          "This permanently deletes your Lizzen account, playlists, and saved data. This can't be undone.",
      confirmLabel: "Delete",
      isDestructive: true,
    );
    if (!confirmed) return;

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'requires-recent-login') {
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Please log in again, then retry deleting your account.",
            ),
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Couldn't delete account: ${e.message}")),
        );
      }
      return;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Couldn't delete account: $e")));
      }
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<bool> _showAccountConfirmDialog({
    required IconData icon,
    required String title,
    required String description,
    required String confirmLabel,
    bool isDestructive = false,
  }) async {
    final bool isDarkMode = AppTheme.instance.isDarkMode;
    final Color accentColor = AppTheme.instance.accentColor;
    const Color destructiveRed = Color(0xFFE05A5A);
    final Color accent = isDestructive ? destructiveRed : accentColor;
    final Color cardColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.90);
    final Color borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.black.withValues(alpha: 0.08);
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color subTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    final Color cancelBorder = isDarkMode
        ? Colors.white.withValues(alpha: 0.2)
        : Colors.black.withValues(alpha: 0.15);

    final bool? result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "dismiss",
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: SizedBox(
              width: 340,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                      child: Container(
                        margin: const EdgeInsets.only(top: 28),
                        padding: const EdgeInsets.fromLTRB(22, 36, 22, 22),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: borderColor, width: 1.4),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.35),
                              blurRadius: 34,
                              spreadRadius: 2,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title.toUpperCase(),
                              style: GoogleFonts.spaceGrotesk(
                                color: accent,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.2,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              description,
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
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(false),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: cancelBorder),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
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
                                        fontSize: 12.5,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDestructive
                                          ? destructiveRed
                                          : accentColor,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      confirmLabel,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12.5,
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
                  Positioned(
                    top: 0,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColors.accentGradient(accent),
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderColor, width: 1.4),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.4),
                            blurRadius: 30,
                            spreadRadius: 2,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
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
            scale: 0.9 + (0.1 * curved.value),
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
    );
    return result ?? false;
  }

  Future<void> _saveName() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;
    try {
      await user.updateDisplayName(newName);
      await user.reload();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Name updated")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Couldn't update name: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppTheme.instance,
      builder: (context, _) {
        final bool isDarkMode = AppTheme.instance.isDarkMode;
        final Color textColor = AppColors.textPrimary(isDarkMode);

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
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CustomAppBar(
                        isDarkMode: !isDarkMode,
                        onToggleTheme: AppTheme.instance.toggleDark,
                        activePage: "",
                        showMenu: true,
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Settings",
                            style: GoogleFonts.spaceGrotesk(
                              color: textColor,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 900;

                            final sidebar = _SettingsSidebar(
                              isDarkMode: isDarkMode,
                              selected: _tab,
                              accentColor: AppTheme.instance.accentColor,
                              animDuration: AppTheme.instance.animDuration,
                              onSelect: (t) => setState(() => _tab = t),
                            );

                            final content = GlassContainer(
                              isDarkMode: isDarkMode,
                              radius: 24,
                              padding: const EdgeInsets.all(28),
                              child: AnimatedSwitcher(
                                duration: AppTheme.instance.animDuration,
                                child: switch (_tab) {
                                  _SettingsTab.appearance => _AppearancePane(
                                    key: const ValueKey("appearance"),
                                    isDarkMode: isDarkMode,
                                    themeMode: AppTheme.instance.themeMode,
                                    onThemeModeChanged:
                                        AppTheme.instance.setThemeMode,
                                    accentColor: AppTheme.instance.accentColor,
                                    onAccentColorChanged:
                                        AppTheme.instance.setAccentColor,
                                    showAnimations:
                                        AppTheme.instance.showAnimations,
                                    onShowAnimationsChanged:
                                        AppTheme.instance.setShowAnimations,
                                  ),
                                  _SettingsTab.profile => _ProfilePane(
                                    key: const ValueKey("profile"),
                                    isDarkMode: isDarkMode,
                                    accentColor: AppTheme.instance.accentColor,
                                    avatarBytes: _avatarBytes,
                                    nameController: _nameController,
                                    emailController: _emailController,
                                    passwordController: _passwordController,
                                    onAvatarTap: () {
                                      showAvatarUploadDialog(
                                        context: context,
                                        isDarkMode: isDarkMode,
                                        currentImageBytes: _avatarBytes,
                                        onConfirm: (bytes) {
                                          setState(() => _avatarBytes = bytes);
                                        },
                                      );
                                    },
                                    onSaveName: _saveName,
                                    onUpdateEmail: () {
                                      showGlassFieldDialog(
                                        context: context,
                                        isDarkMode: isDarkMode,
                                        title: "Update Email",
                                        description:
                                            "Enter the new email address for your account.",
                                        hintText: "Email",
                                        icon: CupertinoIcons.mail_solid,
                                        initialValue: _emailController.text,
                                        confirmLabel: "Update",
                                        onConfirm: (value) {
                                          setState(
                                            () => _emailController.text = value,
                                          );
                                        },
                                      );
                                    },
                                    onUpdatePassword: () {
                                      showGlassFieldDialog(
                                        context: context,
                                        isDarkMode: isDarkMode,
                                        title: "Update Password",
                                        description:
                                            "Enter a new password for your account.",
                                        hintText: "New password",
                                        icon: CupertinoIcons.lock_fill,
                                        obscureText: true,
                                        confirmLabel: "Update",
                                        onConfirm: (value) {},
                                      );
                                    },
                                  ),
                                  _SettingsTab.playback => _PlaybackPane(
                                    key: const ValueKey("playback"),
                                    isDarkMode: isDarkMode,
                                    accentColor: AppTheme.instance.accentColor,
                                  ),
                                  _SettingsTab.account => _AccountPane(
                                    key: const ValueKey("account"),
                                    isDarkMode: isDarkMode,
                                    onSignOutAllDevices:
                                        _confirmSignOutAllDevices,
                                    onDeleteAccount: _confirmDeleteAccount,
                                  ),
                                },
                              ),
                            );

                            if (isWide) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: 230, child: sidebar),
                                  const SizedBox(width: 24),
                                  Expanded(child: content),
                                ],
                              );
                            }

                            return Column(
                              children: [
                                sidebar,
                                const SizedBox(height: 20),
                                content,
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Sidebar

class _SettingsSidebar extends StatelessWidget {
  final bool isDarkMode;
  final _SettingsTab selected;
  final Color accentColor;
  final Duration animDuration;
  final ValueChanged<_SettingsTab> onSelect;

  const _SettingsSidebar({
    required this.isDarkMode,
    required this.selected,
    required this.accentColor,
    required this.animDuration,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = AppColors.textPrimary(isDarkMode);

    return GlassContainer(
      isDarkMode: isDarkMode,
      radius: 22,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              "Preferences",
              style: GoogleFonts.spaceGrotesk(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _SidebarTile(
            isDarkMode: isDarkMode,
            icon: CupertinoIcons.person_crop_circle,
            label: "Profile",
            selected: selected == _SettingsTab.profile,
            accentColor: accentColor,
            animDuration: animDuration,
            onTap: () => onSelect(_SettingsTab.profile),
          ),
          _SidebarTile(
            isDarkMode: isDarkMode,
            icon: CupertinoIcons.gear_alt,
            label: "Account",
            selected: selected == _SettingsTab.account,
            accentColor: accentColor,
            animDuration: animDuration,
            onTap: () => onSelect(_SettingsTab.account),
          ),
          _SidebarTile(
            isDarkMode: isDarkMode,
            icon: CupertinoIcons.circle_lefthalf_fill,
            label: "Appearance",
            selected: selected == _SettingsTab.appearance,
            accentColor: accentColor,
            animDuration: animDuration,
            onTap: () => onSelect(_SettingsTab.appearance),
          ),
          _SidebarTile(
            isDarkMode: isDarkMode,
            icon: CupertinoIcons.waveform,
            label: "Playback",
            selected: selected == _SettingsTab.playback,
            accentColor: accentColor,
            animDuration: animDuration,
            onTap: () => onSelect(_SettingsTab.playback),
          ),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatefulWidget {
  final bool isDarkMode;
  final IconData icon;
  final String label;
  final bool selected;
  final Color accentColor;
  final Duration animDuration;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.isDarkMode,
    required this.icon,
    required this.label,
    required this.selected,
    required this.accentColor,
    required this.animDuration,
    required this.onTap,
  });

  @override
  State<_SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<_SidebarTile> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || hovered;
    final Color baseText = AppColors.textSecondary(widget.isDarkMode);
    final Color activeText = AppColors.textPrimary(widget.isDarkMode);
    final Color hoverFill = AppColors.glassSurface(
      widget.isDarkMode,
      darkAlpha: 0.06,
      lightAlpha: 0.04,
    );
    final Color selectedBorder = AppColors.glassBorder(
      widget.isDarkMode,
      darkAlpha: 0.2,
      lightAlpha: 0.12,
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: widget.animDuration,
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: widget.selected
                ? LinearGradient(
                    colors: AppColors.accentGradient(
                      widget.accentColor,
                    ).map((c) => c.withValues(alpha: 0.28)).toList(),
                  )
                : null,
            color: !widget.selected && hovered ? hoverFill : null,
            border: widget.selected ? Border.all(color: selectedBorder) : null,
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: active ? activeText : baseText,
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: GoogleFonts.spaceGrotesk(
                  color: active ? activeText : baseText,
                  fontSize: 13.5,
                  fontWeight: widget.selected
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Appearance pane

class _AppearancePane extends StatefulWidget {
  final bool isDarkMode;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final Color accentColor;
  final ValueChanged<Color> onAccentColorChanged;
  final bool showAnimations;
  final ValueChanged<bool> onShowAnimationsChanged;

  const _AppearancePane({
    super.key,
    required this.isDarkMode,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.accentColor,
    required this.onAccentColorChanged,
    required this.showAnimations,
    required this.onShowAnimationsChanged,
  });

  @override
  State<_AppearancePane> createState() => _AppearancePaneState();
}

class _AppearancePaneState extends State<_AppearancePane> {
  static const List<Color> _presets = [
    Color(0xFF15131C),
    Color(0xFFE05A5A),
    Color(0xFF34C77A),
    Color(0xFF3E8BFF),
    Color(0xFFB15CDE),
  ];

  late final TextEditingController _hexController;

  @override
  void initState() {
    super.initState();
    _hexController = TextEditingController(
      text: _colorToHex(widget.accentColor),
    );
  }

  @override
  void didUpdateWidget(covariant _AppearancePane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.accentColor != widget.accentColor) {
      _hexController.text = _colorToHex(widget.accentColor);
    }
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  String _colorToHex(Color c) {
    return c
        .toARGB32()
        .toRadixString(16)
        .padLeft(8, '0')
        .substring(2)
        .toUpperCase();
  }

  void _submitHex(String value) {
    var hex = value.trim().replaceAll('#', '');
    if (hex.length == 3) {
      hex = hex.split('').map((c) => '$c$c').join();
    }
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length != 8) return;
    final parsed = int.tryParse(hex, radix: 16);
    if (parsed == null) return;
    widget.onAccentColorChanged(Color(parsed));
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = AppColors.textPrimary(widget.isDarkMode);
    final Color subTextColor = AppColors.textSecondary(widget.isDarkMode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Appearance",
          style: GoogleFonts.spaceGrotesk(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Choose your style or customize your theme.",
          style: GoogleFonts.spaceGrotesk(color: subTextColor, fontSize: 13),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 170,
              child: _ThemeOptionCard(
                label: "Light Mode",
                selected: widget.themeMode == ThemeMode.light,
                isDarkModeUi: widget.isDarkMode,
                accentColor: widget.accentColor,
                preview: const _MiniPreview(isDark: false),
                onTap: () => widget.onThemeModeChanged(ThemeMode.light),
              ),
            ),
            SizedBox(
              width: 170,
              child: _ThemeOptionCard(
                label: "Dark Mode",
                selected: widget.themeMode == ThemeMode.dark,
                isDarkModeUi: widget.isDarkMode,
                accentColor: widget.accentColor,
                preview: const _MiniPreview(isDark: true),
                onTap: () => widget.onThemeModeChanged(ThemeMode.dark),
              ),
            ),
            SizedBox(
              width: 170,
              child: _ThemeOptionCard(
                label: "System",
                selected: widget.themeMode == ThemeMode.system,
                isDarkModeUi: widget.isDarkMode,
                accentColor: widget.accentColor,
                preview: const _MiniPreview(isDark: true, split: true),
                onTap: () => widget.onThemeModeChanged(ThemeMode.system),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Divider(
          color: AppColors.glassBorder(
            widget.isDarkMode,
            darkAlpha: 0.1,
            lightAlpha: 0.1,
          ),
          height: 1,
        ),
        const SizedBox(height: 22),
        Text(
          "Accent Color",
          style: GoogleFonts.spaceGrotesk(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Pick an accent used across buttons and highlights.",
          style: GoogleFonts.spaceGrotesk(color: subTextColor, fontSize: 12.5),
        ),
        const SizedBox(height: 14),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            ..._presets.map(
              (c) => _AccentSwatch(
                color: c,
                selected: widget.accentColor.toARGB32() == c.toARGB32(),
                onTap: () => widget.onAccentColorChanged(c),
              ),
            ),
            Container(
              width: 1,
              height: 26,
              color: AppColors.glassBorder(
                widget.isDarkMode,
                darkAlpha: 0.15,
                lightAlpha: 0.15,
              ),
            ),
            _AccentSwatch(
              color: widget.accentColor,
              selected: true,
              onTap: () {},
            ),
            SizedBox(
              width: 112,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.glassSurface(
                    widget.isDarkMode,
                    darkAlpha: 0.05,
                    lightAlpha: 0.04,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.glassBorder(
                      widget.isDarkMode,
                      darkAlpha: 0.12,
                      lightAlpha: 0.1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      "#",
                      style: GoogleFonts.spaceGrotesk(
                        color: subTextColor,
                        fontSize: 12.5,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _hexController,
                        maxLength: 6,
                        style: GoogleFonts.spaceGrotesk(
                          color: textColor,
                          fontSize: 12.5,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          counterText: "",
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: _submitHex,
                        onChanged: (v) {
                          if (v.length == 6) _submitHex(v);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Divider(
          color: AppColors.glassBorder(
            widget.isDarkMode,
            darkAlpha: 0.1,
            lightAlpha: 0.1,
          ),
          height: 1,
        ),
        const SizedBox(height: 8),
        _PlaybackToggleRow(
          isDarkMode: widget.isDarkMode,
          icon: CupertinoIcons.sparkles,
          title: "Show animations",
          subtitle: "Enable or disable UI animations.",
          value: widget.showAnimations,
          onChanged: widget.onShowAnimationsChanged,
        ),
      ],
    );
  }
}

class _MiniPreview extends StatelessWidget {
  final bool isDark;
  final bool split;

  const _MiniPreview({required this.isDark, this.split = false});

  Widget _face(bool dark) {
    final Color bg = dark ? const Color(0xFF15131C) : const Color(0xFFF4F2F8);
    final Color line = dark ? Colors.white24 : Colors.black12;
    final Color rail = dark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.05);

    return Container(
      color: bg,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 6,
            decoration: BoxDecoration(
              color: line,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 12,
                  decoration: BoxDecoration(
                    color: rail,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    children: List.generate(
                      3,
                      (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Container(
                          height: 7,
                          decoration: BoxDecoration(
                            color: line,
                            borderRadius: BorderRadius.circular(2),
                          ),
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
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 80,
        child: split
            ? Row(
                children: [
                  Expanded(child: _face(false)),
                  Expanded(child: _face(true)),
                ],
              )
            : _face(isDark),
      ),
    );
  }
}

class _ThemeOptionCard extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDarkModeUi;
  final Color accentColor;
  final Widget preview;
  final VoidCallback onTap;

  const _ThemeOptionCard({
    required this.label,
    required this.selected,
    required this.isDarkModeUi,
    required this.accentColor,
    required this.preview,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = AppColors.textPrimary(isDarkModeUi);
    final Color cardFill = AppColors.glassSurface(
      isDarkModeUi,
      darkAlpha: 0.05,
      lightAlpha: 0.04,
    );
    final Color border = selected
        ? accentColor
        : AppColors.glassBorder(
            isDarkModeUi,
            darkAlpha: 0.14,
            lightAlpha: 0.12,
          );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cardFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: selected ? 1.6 : 1),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            preview,
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  selected
                      ? CupertinoIcons.checkmark_alt_circle_fill
                      : CupertinoIcons.circle,
                  size: 16,
                  color: selected
                      ? accentColor
                      : AppColors.textSecondary(isDarkModeUi),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.spaceGrotesk(
                      color: textColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AccentSwatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _AccentSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: selected ? Colors.white : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.6),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: selected
            ? const Icon(
                CupertinoIcons.checkmark,
                size: 14,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}

// Profile pane

class _ProfilePane extends StatelessWidget {
  final bool isDarkMode;
  final Color accentColor;
  final Uint8List? avatarBytes;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onAvatarTap;
  final VoidCallback onSaveName;
  final VoidCallback onUpdateEmail;
  final VoidCallback onUpdatePassword;

  const _ProfilePane({
    super.key,
    required this.isDarkMode,
    required this.accentColor,
    required this.avatarBytes,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.onAvatarTap,
    required this.onSaveName,
    required this.onUpdateEmail,
    required this.onUpdatePassword,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = AppColors.textPrimary(isDarkMode);
    final Color subTextColor = AppColors.textSecondary(isDarkMode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Your Profile",
          style: GoogleFonts.spaceGrotesk(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Update your photo and account information.",
          style: GoogleFonts.spaceGrotesk(color: subTextColor, fontSize: 13),
        ),
        const SizedBox(height: 28),
        Builder(
          builder: (context) {
            final isWide = MediaQuery.sizeOf(context).width > 900;

            final avatar = _AvatarPicker(
              isDarkMode: isDarkMode,
              accentColor: accentColor,
              imageBytes: avatarBytes,
              displayName: nameController.text,
              onTap: onAvatarTap,
            );

            final fields = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingsField(
                  isDarkMode: isDarkMode,
                  accentColor: accentColor,
                  label: "Name",
                  controller: nameController,
                  trailing: "SAVE",
                  onTrailingTap: onSaveName,
                ),
                const SizedBox(height: 14),
                _SettingsField(
                  isDarkMode: isDarkMode,
                  accentColor: accentColor,
                  label: "Email",
                  controller: emailController,
                  trailing: "UPDATE",
                  onTrailingTap: onUpdateEmail,
                ),
                const SizedBox(height: 14),
                _SettingsField(
                  isDarkMode: isDarkMode,
                  accentColor: accentColor,
                  label: "Password",
                  controller: passwordController,
                  obscure: true,
                  trailing: "UPDATE",
                  onTrailingTap: onUpdatePassword,
                ),
              ],
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  avatar,
                  const SizedBox(width: 32),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: fields,
                  ),
                ],
              );
            }
            return Column(
              children: [
                avatar,
                const SizedBox(height: 24),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: fields,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 28),
        Divider(
          color: AppColors.glassBorder(
            isDarkMode,
            darkAlpha: 0.1,
            lightAlpha: 0.1,
          ),
          height: 1,
        ),
        const SizedBox(height: 28),
        _GenrePicker(isDarkMode: isDarkMode, accentColor: accentColor),
      ],
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  final bool isDarkMode;
  final Color accentColor;
  final Uint8List? imageBytes;
  final String displayName;
  final VoidCallback onTap;

  const _AvatarPicker({
    required this.isDarkMode,
    required this.accentColor,
    required this.imageBytes,
    required this.displayName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: imageBytes == null
                ? LinearGradient(colors: AppColors.accentGradient(accentColor))
                : null,
            border: Border.all(
              color: AppColors.glassBorder(
                isDarkMode,
                darkAlpha: 0.2,
                lightAlpha: 0.2,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: imageBytes != null
              ? ClipOval(
                  child: Image.memory(
                    imageBytes!,
                    width: 88,
                    height: 88,
                    fit: BoxFit.cover,
                  ),
                )
              : Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : "?",
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: isDarkMode ? Colors.white70 : AppColors.deepPurple,
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            "UPDATE",
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _GenrePicker extends StatefulWidget {
  final bool isDarkMode;
  final Color accentColor;
  const _GenrePicker({required this.isDarkMode, required this.accentColor});

  @override
  State<_GenrePicker> createState() => _GenrePickerState();
}

class _GenrePickerState extends State<_GenrePicker> {
  final List<String> allGenres = const [
    "Pop",
    "Hip-Hop",
    "R&B",
    "Indie",
    "Electronic",
    "Rock",
    "Jazz",
    "Lo-fi",
  ];

  final Set<String> selected = {"Pop", "Lo-fi"};

  void _toggle(String genre) {
    setState(() {
      if (selected.contains(genre)) {
        selected.remove(genre);
      } else {
        selected.add(genre);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = AppColors.textPrimary(widget.isDarkMode);
    final Color subTextColor = AppColors.textSecondary(widget.isDarkMode);
    final Color chipFill = AppColors.glassSurface(
      widget.isDarkMode,
      darkAlpha: 0.05,
      lightAlpha: 0.04,
    );
    final Color chipBorder = AppColors.glassBorder(
      widget.isDarkMode,
      darkAlpha: 0.15,
      lightAlpha: 0.10,
    );
    final Color chipTextInactive = widget.isDarkMode
        ? Colors.white70
        : Colors.black54;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Favorite Genres",
          style: GoogleFonts.spaceGrotesk(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Pick a few genres to shape your recommendations.",
          style: GoogleFonts.spaceGrotesk(color: subTextColor, fontSize: 12.5),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: allGenres.map((genre) {
            final isSelected = selected.contains(genre);
            return GestureDetector(
              onTap: () => _toggle(genre),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: isSelected
                      ? LinearGradient(
                          colors: AppColors.accentGradient(widget.accentColor),
                        )
                      : null,
                  color: isSelected ? null : chipFill,
                  border: Border.all(
                    color: isSelected ? Colors.transparent : chipBorder,
                  ),
                ),
                child: Text(
                  genre,
                  style: GoogleFonts.spaceGrotesk(
                    color: isSelected ? Colors.white : chipTextInactive,
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 42,
          child: Container(
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              gradient: LinearGradient(
                colors: AppColors.accentGradient(widget.accentColor),
              ),
            ),
            child: ElevatedButton(
              onPressed: () {
                // TODO: persist `selected` genres
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor:
                    (widget.isDarkMode ? Colors.white : Colors.black)
                        .withValues(alpha: 0.12),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11.5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: Text(
                "Apply",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsField extends StatelessWidget {
  final bool isDarkMode;
  final Color accentColor;
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  const _SettingsField({
    required this.isDarkMode,
    required this.accentColor,
    required this.label,
    required this.controller,
    this.obscure = false,
    this.trailing,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = AppColors.textPrimary(isDarkMode);
    final Color labelColor = AppColors.textSecondary(isDarkMode);
    final Color fieldFill = AppColors.glassSurface(
      isDarkMode,
      darkAlpha: 0.05,
      lightAlpha: 0.04,
    );
    final Color fieldBorder = AppColors.glassBorder(
      isDarkMode,
      darkAlpha: 0.12,
      lightAlpha: 0.10,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            color: labelColor,
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: fieldFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: fieldBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  style: GoogleFonts.spaceGrotesk(
                    color: textColor,
                    fontSize: 13.5,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (trailing != null)
                TextButton(
                  onPressed: onTrailingTap,
                  style: TextButton.styleFrom(
                    foregroundColor: accentColor,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    trailing!,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// Playback pane

class _PlaybackPane extends StatefulWidget {
  final bool isDarkMode;
  final Color accentColor;
  const _PlaybackPane({
    super.key,
    required this.isDarkMode,
    required this.accentColor,
  });

  @override
  State<_PlaybackPane> createState() => _PlaybackPaneState();
}

class _PlaybackPaneState extends State<_PlaybackPane> {
  String _quality = "High";
  bool _wifiOnlyDownloads = true;
  bool _crossfade = false;
  bool _gaplessPlayback = true;

  @override
  Widget build(BuildContext context) {
    final Color textColor = AppColors.textPrimary(widget.isDarkMode);
    final Color subTextColor = AppColors.textSecondary(widget.isDarkMode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Playback",
          style: GoogleFonts.spaceGrotesk(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Control how Lizzen streams and downloads music.",
          style: GoogleFonts.spaceGrotesk(color: subTextColor, fontSize: 13),
        ),
        const SizedBox(height: 24),
        Text(
          "Audio Quality",
          style: GoogleFonts.spaceGrotesk(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: ["Normal", "High", "Lossless"].map((q) {
            final isSelected = _quality == q;
            return GestureDetector(
              onTap: () => setState(() => _quality = q),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: isSelected
                      ? LinearGradient(
                          colors: AppColors.accentGradient(widget.accentColor),
                        )
                      : null,
                  color: isSelected
                      ? null
                      : AppColors.glassSurface(
                          widget.isDarkMode,
                          darkAlpha: 0.05,
                          lightAlpha: 0.05,
                        ),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : AppColors.glassBorder(
                            widget.isDarkMode,
                            darkAlpha: 0.12,
                            lightAlpha: 0.12,
                          ),
                  ),
                ),
                child: Text(
                  q,
                  style: GoogleFonts.spaceGrotesk(
                    color: isSelected
                        ? Colors.white
                        : (widget.isDarkMode ? Colors.white70 : Colors.black54),
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),
        Divider(
          color: AppColors.glassBorder(
            widget.isDarkMode,
            darkAlpha: 0.1,
            lightAlpha: 0.1,
          ),
          height: 1,
        ),
        const SizedBox(height: 14),
        _PlaybackToggleRow(
          isDarkMode: widget.isDarkMode,
          icon: CupertinoIcons.wifi,
          title: "Download over Wi-Fi only",
          subtitle: "Avoid using mobile data for offline downloads.",
          value: _wifiOnlyDownloads,
          accentColor: widget.accentColor,
          onChanged: (v) => setState(() => _wifiOnlyDownloads = v),
        ),
        _PlaybackToggleRow(
          isDarkMode: widget.isDarkMode,
          icon: CupertinoIcons.arrow_swap,
          title: "Crossfade",
          subtitle: "Smoothly blend between tracks.",
          value: _crossfade,
          accentColor: widget.accentColor,
          onChanged: (v) => setState(() => _crossfade = v),
        ),
        _PlaybackToggleRow(
          isDarkMode: widget.isDarkMode,
          icon: CupertinoIcons.infinite,
          title: "Gapless playback",
          subtitle: "Remove silence between consecutive tracks.",
          value: _gaplessPlayback,
          accentColor: widget.accentColor,
          onChanged: (v) => setState(() => _gaplessPlayback = v),
        ),
      ],
    );
  }
}

class _PlaybackToggleRow extends StatelessWidget {
  final bool isDarkMode;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Color? accentColor;
  final ValueChanged<bool> onChanged;

  const _PlaybackToggleRow({
    required this.isDarkMode,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    this.accentColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = AppColors.textPrimary(isDarkMode);
    final Color subTextColor = AppColors.textSecondary(isDarkMode);
    final Color iconFill = AppColors.glassSurface(
      isDarkMode,
      darkAlpha: 0.08,
      lightAlpha: 0.05,
    );
    final Color iconBorder = AppColors.glassBorder(
      isDarkMode,
      darkAlpha: 0.15,
      lightAlpha: 0.10,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconFill,
              border: Border.all(color: iconBorder),
            ),
            child: Icon(icon, size: 17, color: textColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.spaceGrotesk(
                    color: subTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: accentColor ?? AppColors.primaryPurple,
          ),
        ],
      ),
    );
  }
}

// Account pane

class _AccountPane extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onSignOutAllDevices;
  final VoidCallback onDeleteAccount;

  const _AccountPane({
    super.key,
    required this.isDarkMode,
    required this.onSignOutAllDevices,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = AppColors.textPrimary(isDarkMode);
    final Color subTextColor = AppColors.textSecondary(isDarkMode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Account",
          style: GoogleFonts.spaceGrotesk(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Manage your account status and data.",
          style: GoogleFonts.spaceGrotesk(color: subTextColor, fontSize: 13),
        ),
        const SizedBox(height: 24),
        Divider(
          color: AppColors.glassBorder(
            isDarkMode,
            darkAlpha: 0.1,
            lightAlpha: 0.1,
          ),
          height: 1,
        ),
        const SizedBox(height: 14),
        _AccountRow(
          isDarkMode: isDarkMode,
          icon: CupertinoIcons.arrow_right_square,
          title: "Sign out of all devices",
          subtitle: "You'll be signed out everywhere except here.",
          actionLabel: "Sign out",
          onTap: onSignOutAllDevices,
        ),
        Divider(
          color: AppColors.glassBorder(
            isDarkMode,
            darkAlpha: 0.1,
            lightAlpha: 0.1,
          ),
          height: 28,
        ),
        _AccountRow(
          isDarkMode: isDarkMode,
          icon: CupertinoIcons.trash,
          title: "Delete account",
          subtitle: "Permanently delete your account and all associated data.",
          actionLabel: "Delete",
          destructive: true,
          onTap: onDeleteAccount,
        ),
      ],
    );
  }
}

class _AccountRow extends StatelessWidget {
  final bool isDarkMode;
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;
  final bool destructive;

  const _AccountRow({
    required this.isDarkMode,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = AppColors.textPrimary(isDarkMode);
    final Color subTextColor = AppColors.textSecondary(isDarkMode);
    final Color accent = destructive ? const Color(0xffF87171) : textColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: destructive
                ? const Color(0xffF87171).withValues(alpha: 0.12)
                : AppColors.glassSurface(
                    isDarkMode,
                    darkAlpha: 0.08,
                    lightAlpha: 0.08,
                  ),
            border: Border.all(
              color: destructive
                  ? const Color(0xffF87171).withValues(alpha: 0.3)
                  : AppColors.glassBorder(
                      isDarkMode,
                      darkAlpha: 0.15,
                      lightAlpha: 0.15,
                    ),
            ),
          ),
          child: Icon(icon, size: 17, color: accent),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: GoogleFonts.spaceGrotesk(
                  color: subTextColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: destructive
                  ? const Color(0xffF87171).withValues(alpha: 0.4)
                  : AppColors.glassBorder(
                      isDarkMode,
                      darkAlpha: 0.2,
                      lightAlpha: 0.2,
                    ),
            ),
            backgroundColor: destructive
                ? const Color(0xffF87171).withValues(alpha: 0.08)
                : AppColors.glassSurface(
                    isDarkMode,
                    darkAlpha: 0.04,
                    lightAlpha: 0.04,
                  ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: Text(
            actionLabel,
            style: GoogleFonts.spaceGrotesk(
              color: accent,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
