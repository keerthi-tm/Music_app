import 'package:flutter/material.dart';
import 'package:landingpage/src/models/song_data.dart';
import 'package:landingpage/src/models/album_data.dart';

class Artist {
  final String id;
  final String name;
  final List<Color> colors;
  final List<Song> songs;
  final String imageUrl;

  const Artist({
    required this.id,
    required this.name,
    required this.colors,
    required this.songs,
    this.imageUrl = '',
  });
}

String _slug(String name) => name
    .toLowerCase()
    .replaceAll(RegExp(r"[^a-z0-9]+"), '-')
    .replaceAll(RegExp(r"^-+|-+$"), '');

const Map<String, String> artistImageUrls = {
  'Taylor Swift': '',
  'The Weeknd': '',
  'Drake': '',
  'Billie Eilish': '',
  'Ed Sheeran': '',
  'Coldplay': '',
  'Adele': '',
  'Kendrick Lamar': '',
  'Beyoncé': '',
  'Bruno Mars': '',
  'Dua Lipa': '',
  'Post Malone': '',
  'Ariana Grande': '',
  'The 1975': '',
  'Imagine Dragons': '',
  'Arctic Monkeys': '',
  'Harry Styles': '',
  'Olivia Rodrigo': '',
  'Travis Scott': '',
  'Doja Cat': '',
};

final List<Artist> allArtists = () {
  final Map<String, List<Song>> songsByArtist = {};
  final Map<String, List<Color>> colorsByArtist = {};

  for (final album in allAlbums) {
    songsByArtist.putIfAbsent(album.artist, () => []).addAll(album.songs);
    colorsByArtist.putIfAbsent(album.artist, () => album.colors);
  }

  return songsByArtist.entries
      .map(
        (e) => Artist(
          id: 'art-${_slug(e.key)}',
          name: e.key,
          colors: colorsByArtist[e.key]!,
          songs: e.value,
          imageUrl: artistImageUrls[e.key] ?? '',
        ),
      )
      .toList();
}();

Artist? artistById(String id) {
  try {
    return allArtists.firstWhere((a) => a.id == id);
  } catch (_) {
    return null;
  }
}
