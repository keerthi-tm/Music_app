import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ArtistPhotoService {
  ArtistPhotoService._();

  static final Map<String, String?> _cache = {};

  static const Map<String, String> _titleOverrides = {
    'Drake': 'Drake (musician)',
  };

  static Future<String?> fetch(String artistName) async {
    if (_cache.containsKey(artistName)) return _cache[artistName];

    final wikiTitle = _titleOverrides[artistName] ?? artistName;
    final encodedTitle = Uri.encodeComponent(wikiTitle.replaceAll(' ', '_'));
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

      if (response.statusCode != 200) {
        debugPrint(
          'ArtistPhotoService: ${response.statusCode} for "$artistName" '
          '($uri)',
        );
        _cache[artistName] = null;
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['type'] == 'disambiguation') {
        debugPrint(
          'ArtistPhotoService: "$artistName" resolved to a disambiguation '
          'page — add a title override in _titleOverrides.',
        );
        _cache[artistName] = null;
        return null;
      }

      final original = data['originalimage'] as Map<String, dynamic>?;
      final thumb = data['thumbnail'] as Map<String, dynamic>?;
      final url = (original?['source'] ?? thumb?['source']) as String?;

      if (url == null) {
        debugPrint('ArtistPhotoService: no photo found for "$artistName"');
      }

      _cache[artistName] = url;
      return url;
    } catch (e) {
      debugPrint('ArtistPhotoService: error fetching "$artistName" — $e');
      _cache[artistName] = null;
      return null;
    }
  }
}
