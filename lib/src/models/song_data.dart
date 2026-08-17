import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:landingpage/src/utils/colors.dart';

const String likedSongIdsKey = 'liked_song_ids';
const String recentlyPlayedIdsKey = 'recently_played_ids';
const String savedSongIdsKey = 'saved_song_ids';

class Song {
  final String id;
  final String title;
  final String artist;
  final List<Color> colors;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.colors,
  });
}

const List<(String, String)> _catalogData = [
  ("Midnight Waves", "Chill Mix"),
  ("Solar Drift", "Focus Flow"),
  ("Neon Pulse", "Party Mix"),
  ("Golden Hour", "Aria Bloom"),
  ("Static Bloom", "The Wavelengths"),
  ("Echo Chamber", "Nova Ray"),
  ("Velvet Skyline", "Juno Park"),
  ("Paper Planets", "Kai Ventura"),
  ("Glass Horizon", "The Wavelengths"),
  ("Afterglow", "Mira Sol"),
  ("Wildfire Heart", "Rook & Ivy"),
  ("Low Tide", "Aria Bloom"),
  ("Electric Bloom", "Nova Ray"),
  ("Halcyon Nights", "Kai Ventura"),
  ("Sundown Alley", "Mira Sol"),
  ("Static & Stars", "Juno Park"),
  ("Rewind", "Rook & Ivy"),
  ("Amber Skies", "The Wavelengths"),
  ("Frequency", "Nova Ray"),
  ("Slow Bloom", "Aria Bloom"),
];

final List<Song> allSongs = List<Song>.generate(_catalogData.length, (i) {
  final (title, artist) = _catalogData[i];
  return Song(
    id: 's${i + 1}',
    title: title,
    artist: artist,
    colors: AppColors.songPalette[i % AppColors.songPalette.length],
  );
});

Song? songById(String id) {
  for (final s in allSongs) {
    if (s.id == id) return s;
  }
  return null;
}

class Playlist {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final List<String> songIds;

  const Playlist({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.songIds,
  });
}

const List<Playlist> playlists = [
  Playlist(
    id: 'p1',
    title: 'Chill Mix',
    description: 'Slow it down',
    icon: Icons.nightlight_round,
    gradient: AppColors.primaryGradient,
    songIds: ['s1', 's9', 's12', 's20'],
  ),
  Playlist(
    id: 'p2',
    title: 'Focus Flow',
    description: 'Heads down',
    icon: Icons.center_focus_strong_rounded,
    gradient: [AppColors.cyan, AppColors.blue],
    songIds: ['s2', 's8', 's19'],
  ),
  Playlist(
    id: 'p3',
    title: 'Party Mix',
    description: 'Turn it up',
    icon: Icons.celebration_rounded,
    gradient: [AppColors.violet, AppColors.indigo],
    songIds: ['s3', 's11', 's13'],
  ),
  Playlist(
    id: 'p4',
    title: 'Night Drive',
    description: 'Late & moody',
    icon: Icons.dark_mode_rounded,
    gradient: [AppColors.orange, AppColors.primaryPink],
    songIds: ['s5', 's16', 's18'],
  ),
];

String _playlistExtraSongsKey(String playlistId) =>
    'playlist_extra_songs_$playlistId';

Future<List<String>> extraSongIdsForPlaylist(String playlistId) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList(_playlistExtraSongsKey(playlistId)) ?? [];
}

Future<List<String>> songIdsForPlaylist(Playlist playlist) async {
  final extra = await extraSongIdsForPlaylist(playlist.id);
  return {...playlist.songIds, ...extra}.toList();
}

Future<bool> addSongToPlaylist(String playlistId, String songId) async {
  final playlist = playlists.firstWhere((p) => p.id == playlistId);
  if (playlist.songIds.contains(songId)) return false;

  final prefs = await SharedPreferences.getInstance();
  final key = _playlistExtraSongsKey(playlistId);
  final current = (prefs.getStringList(key) ?? []).toSet();
  if (!current.add(songId)) return false; // already added previously
  await prefs.setStringList(key, current.toList());
  return true;
}
