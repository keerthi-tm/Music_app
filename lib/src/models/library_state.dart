import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:landingpage/src/models/song_data.dart';

class LibraryState extends ChangeNotifier {
  LibraryState._();
  static final LibraryState instance = LibraryState._();

  Set<String> likedIds = {};
  Set<String> savedIds = {};
  List<String> recentIds = [];

  bool _loaded = false;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    likedIds = (prefs.getStringList(likedSongIdsKey) ?? []).toSet();
    savedIds = (prefs.getStringList(savedSongIdsKey) ?? []).toSet();
    recentIds = prefs.getStringList(recentlyPlayedIdsKey) ?? [];
    _loaded = true;
    notifyListeners();
  }

  Future<void> reload() async {
    _loaded = false;
    await load();
  }

  bool isLiked(String songId) => likedIds.contains(songId);
  bool isSaved(String songId) => savedIds.contains(songId);

  Future<void> toggleLiked(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    if (likedIds.contains(songId)) {
      likedIds.remove(songId);
    } else {
      likedIds.add(songId);
    }
    await prefs.setStringList(likedSongIdsKey, likedIds.toList());
    notifyListeners();
  }

  Future<void> toggleSaved(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    if (savedIds.contains(songId)) {
      savedIds.remove(songId);
    } else {
      savedIds.add(songId);
    }
    await prefs.setStringList(savedSongIdsKey, savedIds.toList());
    notifyListeners();
  }

  Future<void> markPlayed(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    recentIds.remove(songId);
    recentIds.insert(0, songId);
    if (recentIds.length > 25) {
      recentIds = recentIds.sublist(0, 25);
    }
    await prefs.setStringList(recentlyPlayedIdsKey, recentIds);
    notifyListeners();
  }

  Future<void> clearRecent() async {
    final prefs = await SharedPreferences.getInstance();
    recentIds = [];
    await prefs.remove(recentlyPlayedIdsKey);
    notifyListeners();
  }

  Future<bool> addToPlaylist(String playlistId, String songId) async {
    final added = await addSongToPlaylist(playlistId, songId);
    if (added) notifyListeners();
    return added;
  }
}
