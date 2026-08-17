import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:landingpage/src/utils/colors.dart';

Future<void> showGlassFieldDialog({
  required BuildContext context,
  required String title,
  required String description,
  required String hintText,
  required IconData icon,
  required bool isDarkMode,
  String initialValue = "",
  bool obscureText = false,
  String confirmLabel = "Save",
  required ValueChanged<String> onConfirm,
}) async {
  final TextEditingController controller = TextEditingController(
    text: initialValue,
  );

  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: "dismiss",
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _GlassPopupScaffold(
        isDarkMode: isDarkMode,
        badgeIcon: icon,
        child: _GlassFieldContent(
          title: title,
          description: description,
          hintText: hintText,
          controller: controller,
          obscureText: obscureText,
          confirmLabel: confirmLabel,
          isDarkMode: isDarkMode,
          onConfirm: () {
            final value = controller.text.trim();
            if (value.isNotEmpty) onConfirm(value);
            Navigator.of(context).pop();
          },
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
}

Future<void> showAvatarUploadDialog({
  required BuildContext context,
  required bool isDarkMode,
  Uint8List? currentImageBytes,
  required ValueChanged<Uint8List> onConfirm,
}) async {
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: "dismiss",
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _GlassPopupScaffold(
        isDarkMode: isDarkMode,
        badgeIcon: Icons.photo_camera_rounded,
        child: _AvatarUploadContent(
          isDarkMode: isDarkMode,
          currentImageBytes: currentImageBytes,
          onConfirm: (bytes) {
            onConfirm(bytes);
            Navigator.of(context).pop();
          },
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
}

class _GlassPopupScaffold extends StatelessWidget {
  final bool isDarkMode;
  final IconData badgeIcon;
  final Widget child;

  const _GlassPopupScaffold({
    required this.isDarkMode,
    required this.badgeIcon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = isDarkMode
        ? AppColors.lavenderAccent
        : AppColors.deepPurple;
    final Color cardColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.90);
    final Color borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.black.withValues(alpha: 0.08);

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
                    child: child,
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
                      colors: [
                        AppColors.lavenderAccent,
                        AppColors.primaryPurple,
                        AppColors.deepPurple,
                      ],
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
                  child: Icon(badgeIcon, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassFieldContent extends StatelessWidget {
  final String title;
  final String description;
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final String confirmLabel;
  final bool isDarkMode;
  final VoidCallback onConfirm;

  const _GlassFieldContent({
    required this.title,
    required this.description,
    required this.hintText,
    required this.controller,
    required this.obscureText,
    required this.confirmLabel,
    required this.isDarkMode,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = isDarkMode
        ? AppColors.lavenderAccent
        : AppColors.deepPurple;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color subTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    final Color fieldFill = isDarkMode
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.04);
    final Color fieldBorder = isDarkMode
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.10);

    return Column(
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
        const SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            color: subTextColor,
            fontSize: 12.5,
            height: 1.35,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: fieldFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: fieldBorder),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: GoogleFonts.spaceGrotesk(color: textColor, fontSize: 14),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.spaceGrotesk(color: subTextColor),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: fieldBorder),
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
    );
  }
}

class _AvatarUploadContent extends StatefulWidget {
  final bool isDarkMode;
  final Uint8List? currentImageBytes;
  final ValueChanged<Uint8List> onConfirm;

  const _AvatarUploadContent({
    required this.isDarkMode,
    required this.currentImageBytes,
    required this.onConfirm,
  });

  @override
  State<_AvatarUploadContent> createState() => _AvatarUploadContentState();
}

class _AvatarUploadContentState extends State<_AvatarUploadContent> {
  Uint8List? _preview;
  String? _error;
  bool _picking = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _preview = widget.currentImageBytes;
  }

  // THIS was the bug — it used to be `Future<void> _pickImage() async {}`,
  // an empty stub that did nothing when tapped. Now it actually calls the
  // image_picker plugin to open the OS/browser file picker.
  Future<void> _pickImage() async {
    if (_picking) return; // guard against double-taps

    debugPrint('[AvatarUpload] pickImage tapped');
    setState(() {
      _picking = true;
      _error = null;
    });

    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      debugPrint('[AvatarUpload] picker returned: ${picked?.name}');

      if (picked == null) {
        // User closed the file dialog without picking anything.
        if (mounted) setState(() => _picking = false);
        return;
      }

      final bytes = await picked.readAsBytes();
      debugPrint('[AvatarUpload] read ${bytes.length} bytes');

      if (!mounted) return;
      setState(() {
        _preview = bytes;
        _picking = false;
      });
    } catch (e, st) {
      // No ScaffoldMessenger here on purpose — this widget is shown via
      // showGeneralDialog(), which has no Scaffold ancestor. Calling
      // ScaffoldMessenger.of(context) in that case throws silently.
      debugPrint('[AvatarUpload] pickImage failed: $e\n$st');
      if (!mounted) return;
      setState(() {
        _error = 'Could not load that image: $e';
        _picking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = widget.isDarkMode
        ? AppColors.lavenderAccent
        : AppColors.deepPurple;
    final Color subTextColor = widget.isDarkMode
        ? Colors.white70
        : Colors.black54;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "UPDATE PHOTO",
          style: GoogleFonts.spaceGrotesk(
            color: accent,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.2,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 18),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _preview == null
                  ? LinearGradient(
                      colors: [
                        AppColors.lavenderAccent,
                        AppColors.primaryPurple,
                      ],
                    )
                  : null,
              border: Border.all(color: accent.withValues(alpha: 0.4)),
            ),
            child: _picking
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    ),
                  )
                : (_preview != null
                      ? ClipOval(
                          child: Image.memory(
                            _preview!,
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(
                          Icons.add_a_photo_rounded,
                          color: Colors.white,
                          size: 28,
                        )),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _error ?? "Tap to choose a new photo",
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            color: _error != null ? const Color(0xFFE05A5A) : subTextColor,
            fontSize: 12,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: widget.isDarkMode
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
                onPressed: _preview == null
                    ? null
                    : () => widget.onConfirm(_preview!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Save",
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
