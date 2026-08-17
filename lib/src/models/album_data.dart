import 'package:flutter/material.dart';
import 'package:landingpage/src/utils/colors.dart';
import 'package:landingpage/src/models/song_data.dart';

class Album {
  final String id;
  final String title;
  final String artist;
  final List<Color> colors;
  final List<Song> songs;

  const Album({
    required this.id,
    required this.title,
    required this.artist,
    required this.colors,
    required this.songs,
  });
}

List<Song> _tracks(
  String albumId,
  String artist,
  List<Color> colors,
  List<String> titles,
) {
  return List.generate(titles.length, (i) {
    return Song(
      id: '$albumId-t${i + 1}',
      title: titles[i],
      artist: artist,
      colors: colors,
    );
  });
}

const double _albumGradientAlpha = 0.18;

List<Color> _p(int albumIndex) {
  final base = albumIndex.isEven
      ? AppColors.songPalette[0]
      : AppColors.songPalette[4];
  return base.map((c) => c.withValues(alpha: _albumGradientAlpha)).toList();
}

final List<Album> allAlbums = [
  Album(
    id: 'alb-1989',
    title: '1989',
    artist: 'Taylor Swift',
    colors: _p(0),
    songs: _tracks('alb-1989', 'Taylor Swift', _p(0), [
      'Welcome To New York',
      'Blank Space',
      'Style',
      'Out Of The Woods',
      'Shake It Off',
      'Wildest Dreams',
    ]),
  ),
  Album(
    id: 'alb-afterhours',
    title: 'After Hours',
    artist: 'The Weeknd',
    colors: _p(1),
    songs: _tracks('alb-afterhours', 'The Weeknd', _p(1), [
      'Alone Again',
      'Too Late',
      'Hardest To Love',
      'Scared To Live',
      'Snowchild',
      'In Your Eyes',
    ]),
  ),
  Album(
    id: 'alb-scorpion',
    title: 'Scorpion',
    artist: 'Drake',
    colors: _p(2),
    songs: _tracks('alb-scorpion', 'Drake', _p(2), [
      'Survival',
      "Nonstop",
      'Elevate',
      "God's Plan",
      'In My Feelings',
      'Nice For What',
    ]),
  ),
  Album(
    id: 'alb-happierthanever',
    title: 'Happier Than Ever',
    artist: 'Billie Eilish',
    colors: _p(3),
    songs: _tracks('alb-happierthanever', 'Billie Eilish', _p(3), [
      'Getting Older',
      'I Didn\'t Change My Number',
      'Billie Bossa Nova',
      'my future',
      'Oxytocin',
      'NDA',
    ]),
  ),
  Album(
    id: 'alb-divide',
    title: '÷ (Divide)',
    artist: 'Ed Sheeran',
    colors: _p(4),
    songs: _tracks('alb-divide', 'Ed Sheeran', _p(4), [
      'Eraser',
      'Castle On The Hill',
      'Dive',
      'Shape Of You',
      'Perfect',
      'Galway Girl',
    ]),
  ),
  Album(
    id: 'alb-headfullofdreams',
    title: 'A Head Full of Dreams',
    artist: 'Coldplay',
    colors: _p(5),
    songs: _tracks('alb-headfullofdreams', 'Coldplay', _p(5), [
      'A Head Full of Dreams',
      'Birds',
      'Hymn For The Weekend',
      'Everglow',
      'Adventure Of A Lifetime',
      'Up&Up',
    ]),
  ),
  Album(
    id: 'alb-25',
    title: '25',
    artist: 'Adele',
    colors: _p(6),
    songs: _tracks('alb-25', 'Adele', _p(6), [
      'Hello',
      'Send My Love',
      'I Miss You',
      'When We Were Young',
      'Water Under The Bridge',
      'All I Ask',
    ]),
  ),
  Album(
    id: 'alb-damn',
    title: 'DAMN.',
    artist: 'Kendrick Lamar',
    colors: _p(7),
    songs: _tracks('alb-damn', 'Kendrick Lamar', _p(7), [
      'BLOOD.',
      'DNA.',
      'YAH.',
      'ELEMENT.',
      'HUMBLE.',
      'LOYALTY.',
    ]),
  ),
  Album(
    id: 'alb-renaissance',
    title: 'Renaissance',
    artist: 'Beyoncé',
    colors: _p(8),
    songs: _tracks('alb-renaissance', 'Beyoncé', _p(8), [
      "I'M THAT GIRL",
      'COZY',
      'ALIEN SUPERSTAR',
      'CUFF IT',
      'ENERGY',
      'BREAK MY SOUL',
    ]),
  ),
  Album(
    id: 'alb-24kmagic',
    title: '24K Magic',
    artist: 'Bruno Mars',
    colors: _p(9),
    songs: _tracks('alb-24kmagic', 'Bruno Mars', _p(9), [
      '24K Magic',
      "That's What I Like",
      'Versace On The Floor',
      "Finesse",
      'Perm',
      "Chunky",
    ]),
  ),
  Album(
    id: 'alb-futurenostalgia',
    title: 'Future Nostalgia',
    artist: 'Dua Lipa',
    colors: _p(10),
    songs: _tracks('alb-futurenostalgia', 'Dua Lipa', _p(10), [
      'Future Nostalgia',
      "Don't Start Now",
      'Cool',
      'Physical',
      'Levitating',
      'Break My Heart',
    ]),
  ),
  Album(
    id: 'alb-hollywoodsbleeding',
    title: "Hollywood's Bleeding",
    artist: 'Post Malone',
    colors: _p(11),
    songs: _tracks('alb-hollywoodsbleeding', 'Post Malone', _p(11), [
      "Hollywood's Bleeding",
      'Saint-Tropez',
      'Enemies',
      'Circles',
      'Sunflower',
      'Wow.',
    ]),
  ),
  Album(
    id: 'alb-positions',
    title: 'Positions',
    artist: 'Ariana Grande',
    colors: _p(12),
    songs: _tracks('alb-positions', 'Ariana Grande', _p(12), [
      'shut up',
      'positions',
      'motive',
      'just like magic',
      'off the table',
      '34+35',
    ]),
  ),
  Album(
    id: 'alb-notesonaconditionalform',
    title: 'Notes on a Conditional Form',
    artist: 'The 1975',
    colors: _p(13),
    songs: _tracks('alb-notesonaconditionalform', 'The 1975', _p(13), [
      'The 1975',
      'People',
      'Frail State Of Mind',
      'Me & You Together Song',
      'If You\'re Too Shy',
      'Guys',
    ]),
  ),
  Album(
    id: 'alb-evolve',
    title: 'Evolve',
    artist: 'Imagine Dragons',
    colors: _p(14),
    songs: _tracks('alb-evolve', 'Imagine Dragons', _p(14), [
      'I Don\'t Know Why',
      'Whatever It Takes',
      'Believer',
      'Thunder',
      'Walking The Wire',
      'Rise Up',
    ]),
  ),
  Album(
    id: 'alb-am',
    title: 'AM',
    artist: 'Arctic Monkeys',
    colors: _p(15),
    songs: _tracks('alb-am', 'Arctic Monkeys', _p(15), [
      'Do I Wanna Know?',
      'R U Mine?',
      'One For The Road',
      'Arabella',
      'Why\'d You Only Call Me',
      'No. 1 Party Anthem',
    ]),
  ),
  Album(
    id: 'alb-fineline',
    title: 'Fine Line',
    artist: 'Harry Styles',
    colors: _p(16),
    songs: _tracks('alb-fineline', 'Harry Styles', _p(16), [
      'Golden',
      'Watermelon Sugar',
      'Adore You',
      'Lights Up',
      'Falling',
      'Canyon Moon',
    ]),
  ),
  Album(
    id: 'alb-sour',
    title: 'SOUR',
    artist: 'Olivia Rodrigo',
    colors: _p(17),
    songs: _tracks('alb-sour', 'Olivia Rodrigo', _p(17), [
      'brutal',
      'traitor',
      'drivers license',
      '1 step forward, 3 steps back',
      'good 4 u',
      'happier',
    ]),
  ),
  Album(
    id: 'alb-astroworld',
    title: 'Astroworld',
    artist: 'Travis Scott',
    colors: _p(18),
    songs: _tracks('alb-astroworld', 'Travis Scott', _p(18), [
      'STARGAZING',
      'CAROUSEL',
      'SICKO MODE',
      'R.I.P. SCREW',
      'NC-17',
      'STOP TRYING TO BE GOD',
    ]),
  ),
  Album(
    id: 'alb-planether',
    title: 'Planet Her',
    artist: 'Doja Cat',
    colors: _p(19),
    songs: _tracks('alb-planether', 'Doja Cat', _p(19), [
      'Woman',
      'Naked',
      'Payday',
      'Need To Know',
      'Kiss Me More',
      'You Right',
    ]),
  ),
];

Album? albumById(String id) {
  try {
    return allAlbums.firstWhere((a) => a.id == id);
  } catch (_) {
    return null;
  }
}
