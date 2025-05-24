import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _albumsKey = 'cached_albums';
  static const String _photosKey = 'cached_photos_';
  static const Duration _cacheDuration = Duration(hours: 1);

  final SharedPreferences _prefs;

  CacheService(this._prefs);

  Future<void> cacheAlbums(String jsonString) async {
    try {
      final cacheData = {
        'timestamp': DateTime.now().toIso8601String(),
        'data': jsonString,
      };
      await _prefs.setString(_albumsKey, json.encode(cacheData));
      print('Albums cached successfully');
    } catch (e) {
      print('Error caching albums: $e');
    }
  }

  Future<String?> getCachedAlbums() async {
    try {
      final cachedString = _prefs.getString(_albumsKey);
      if (cachedString == null) {
        print('No cached albums found');
        return null;
      }

      final cacheData = json.decode(cachedString) as Map<String, dynamic>;
      final timestamp = DateTime.parse(cacheData['timestamp'] as String);
      
      if (DateTime.now().difference(timestamp) > _cacheDuration) {
        print('Cache expired for albums');
        await _prefs.remove(_albumsKey);
        return null;
      }

      print('Retrieved albums from cache');
      return cacheData['data'] as String;
    } catch (e) {
      print('Error retrieving cached albums: $e');
      return null;
    }
  }

  Future<void> cachePhotos(int albumId, String jsonString) async {
    try {
      final cacheData = {
        'timestamp': DateTime.now().toIso8601String(),
        'data': jsonString,
      };
      await _prefs.setString('$_photosKey$albumId', json.encode(cacheData));
      print('Photos cached successfully for album $albumId');
    } catch (e) {
      print('Error caching photos: $e');
    }
  }

  Future<String?> getCachedPhotos(int albumId) async {
    try {
      final cachedString = _prefs.getString('$_photosKey$albumId');
      if (cachedString == null) {
        print('No cached photos found for album $albumId');
        return null;
      }

      final cacheData = json.decode(cachedString) as Map<String, dynamic>;
      final timestamp = DateTime.parse(cacheData['timestamp'] as String);
      
      if (DateTime.now().difference(timestamp) > _cacheDuration) {
        print('Cache expired for photos of album $albumId');
        await _prefs.remove('$_photosKey$albumId');
        return null;
      }

      print('Retrieved photos from cache for album $albumId');
      return cacheData['data'] as String;
    } catch (e) {
      print('Error retrieving cached photos: $e');
      return null;
    }
  }

  Future<void> clearCache() async {
    try {
      await _prefs.clear();
      print('Cache cleared successfully');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
} 