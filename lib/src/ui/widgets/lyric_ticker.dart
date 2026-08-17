import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const List<List<String>> lyricSets = [
  [
    "city lights are calling your name",
    "turn the volume up tonight",
    "lost in the rhythm of right now",
    "every beat feels like home",
    "chase the sound till morning comes",
    "we don't need a reason to dance",
  ],
  [
    "heartbeats sync with the bassline",
    "stars keep time with the melody",
    "let the music find you first",
    "echoes linger long after dark",
    "close your eyes, feel the wave",
    "sound waves carry us away",
  ],
  [
    "static turns to symphony",
    "we're just noise until we're not",
    "every skip becomes a memory",
    "play it loud, play it slow",
    "the speakers know before we do",
    "this is the sound of right now",
  ],
];

class LyricTicker extends StatefulWidget {
  final int cardIndex;
  final bool big;
  const LyricTicker({super.key, required this.cardIndex, this.big = false});

  @override
  State<LyricTicker> createState() => _LyricTickerState();
}

class _LyricTickerState extends State<LyricTicker> {
  late final List<String> _lines;
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _lines = lyricSets[widget.cardIndex % lyricSets.length];
    Future.delayed(Duration(milliseconds: 200 * widget.cardIndex), () {
      if (!mounted) return;
      _timer = Timer.periodic(const Duration(seconds: 2, milliseconds: 200), (
        _,
      ) {
        if (!mounted) return;
        setState(() => _index = (_index + 1) % _lines.length);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _lineAt(int offset) {
    final len = _lines.length;
    final i = ((_index + offset) % len + len) % len;
    return _lines[i];
  }

  @override
  Widget build(BuildContext context) {
    final double fadedSize = widget.big ? 11 : 8.5;
    final double mainSize = widget.big ? 19 : 11.5;
    final double gap = widget.big ? 6 : 3;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _line(_lineAt(-1), opacity: 0.28, fontSize: fadedSize, bold: false),
        SizedBox(height: gap),
        _line(_lineAt(0), opacity: 1.0, fontSize: mainSize, bold: true),
        SizedBox(height: gap),
        _line(_lineAt(1), opacity: 0.28, fontSize: fadedSize, bold: false),
      ],
    );
  }

  Widget _line(
    String text, {
    required double opacity,
    required double fontSize,
    required bool bold,
  }) {
    return ClipRect(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 420),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.4),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        child: Text(
          text,
          key: ValueKey(text),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.spaceGrotesk(
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: Colors.white.withValues(alpha: opacity),
            letterSpacing: 0.2,
            shadows: bold
                ? [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}
