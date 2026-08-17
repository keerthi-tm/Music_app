import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:landingpage/src/utils/colors.dart';

class UpdatePhotoSheet extends StatefulWidget {
  final bool isDarkMode;
  final void Function(Uint8List imageBytes) onConfirm;

  const UpdatePhotoSheet({
    super.key,
    required this.isDarkMode,
    required this.onConfirm,
  });

  @override
  State<UpdatePhotoSheet> createState() => _UpdatePhotoSheetState();
}

class _UpdatePhotoSheetState extends State<UpdatePhotoSheet> {
  Uint8List? _preview;
  String? _error;
  bool _picking = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    // Guard against double-taps while the browser file dialog is open.
    if (_picking) return;

    debugPrint('[UpdatePhotoSheet] pickImage tapped');
    setState(() {
      _picking = true;
      _error = null;
    });

    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        // Downscale a bit so huge photos don't blow up memory or
        // upload size — tweak/remove if you want full res.
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      debugPrint('[UpdatePhotoSheet] picker returned: ${picked?.name}');

      if (picked == null) {
        // User closed the file dialog without choosing anything.
        if (mounted) setState(() => _picking = false);
        return;
      }

      final bytes = await picked.readAsBytes();
      debugPrint('[UpdatePhotoSheet] read ${bytes.length} bytes');

      if (!mounted) return;
      setState(() {
        _preview = bytes;
        _picking = false;
      });
    } catch (e, st) {
      debugPrint('[UpdatePhotoSheet] pickImage failed: $e\n$st');
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
    final Color textColor = widget.isDarkMode ? Colors.white : Colors.black87;
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
            color: _error != null ? Colors.redAccent : subTextColor,
            fontSize: 12,
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
                child: Text("Cancel", style: TextStyle(color: subTextColor)),
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
                    color: textColor == Colors.black87
                        ? Colors.white
                        : Colors.white,
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
