import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Looks up an album's cover art via Wikipedia's page-summary API.
///
/// Most album Wikipedia pages use the lead/infobox image as the album
/// cover, and are usually titled one of:
///   "<Album Title> (<Artist> album)"   e.g. "Scorpion (Drake album)"
///   "<Album Title> (album)"            e.g. "Views (album)"
///   "<Album Title>"                    e.g. "Thriller"
/// This tries each candidate in order and returns the first cover image
/// found, so most albums resolve automatically without any manual setup.
class AlbumCoverService {
  AlbumCoverService._();

  static final Map<String, String?> _cache = {};

  /// Manual overrides for albums whose Wikipedia page title doesn't
  /// match any of the automatic candidates above.
  /// Key format: "Album Title|Artist Name".
  static const Map<String, String> _titleOverrides = {
    // 'Some Album|Some Artist': 'Some Album (Some Artist 2019 album)',
  };

  static Future<String?> fetch(String albumTitle, String artistName) async {
    final cacheKey = '$albumTitle|$artistName';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey];

    final override = _titleOverrides[cacheKey];
    final candidates = <String>[
      if (override != null) override,
      '$albumTitle ($artistName album)',
      '$albumTitle (album)',
      albumTitle,
    ];

    for (final candidate in candidates) {
      final url = await _summaryImage(candidate);
      if (url != null) {
        _cache[cacheKey] = url;
        return url;
      }
    }

    debugPrint(
      'AlbumCoverService: no cover art found for "$albumTitle" by '
      '"$artistName" — add an entry to _titleOverrides if the Wikipedia '
      'page uses a different title.',
    );
    _cache[cacheKey] = null;
    return null;
  }

  static Future<String?> _summaryImage(String pageTitle) async {
    final encodedTitle = Uri.encodeComponent(pageTitle.replaceAll(' ', '_'));
    final uri = Uri.parse(
      'https://en.wikipedia.org/api/rest_v1/page/summary/$encodedTitle',
    );

    try {
      final response = await http
          .get(
            uri,
            headers: {
              'accept': 'application/json',
              'User-Agent':
                  'LizzenApp/1.0 (https://example.com/contact; contact@example.com)',
            },
          )
          .timeout(const Duration(seconds: 6));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // Disambiguation pages ("Scorpion" -> animal, movie, album...)
      // have no useful lead image — skip to the next candidate title
      // instead of showing the wrong picture.
      if (data['type'] == 'disambiguation') return null;

      final original = data['originalimage'] as Map<String, dynamic>?;
      final thumb = data['thumbnail'] as Map<String, dynamic>?;
      return (original?['source'] ?? thumb?['source']) as String?;
    } catch (e) {
      debugPrint('AlbumCoverService: error fetching "$pageTitle" — $e');
      return null;
    }
  }
}
