import 'dart:convert';
import 'dart:io';
import '../models/album.dart';
import '../models/photo.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';

class AlbumRepository {
  final ApiService apiService;
  final CacheService cacheService;

  AlbumRepository(this.apiService, this.cacheService);

  Future<List<Album>> fetchAlbums() async {
    try {
      print('Fetching albums...');
      // Try to get cached data first
      final cachedData = await cacheService.getCachedAlbums();
      if (cachedData != null) {
        print('Using cached albums data');
        final List<dynamic> jsonList = json.decode(cachedData);
        return jsonList.map((json) => Album.fromJson(json)).toList();
      }

      print('No cache found, fetching from API');
      // If no cache, fetch from API
      final data = await apiService.get('albums');
      final albums = data.map((json) => Album.fromJson(json)).toList();
      
      // Cache the new data
      await cacheService.cacheAlbums(json.encode(data));
      
      return albums;
    } catch (e) {
      print('Error in fetchAlbums: $e');
      throw _handleError(e);
    }
  }

  Future<List<Photo>> fetchPhotosByAlbumId(int albumId) async {
    try {
      print('Fetching photos for album $albumId...');
      // Try to get cached data first
      final cachedData = await cacheService.getCachedPhotos(albumId);
      if (cachedData != null) {
        print('Using cached photos data for album $albumId');
        final List<dynamic> jsonList = json.decode(cachedData);
        return jsonList.map((json) => Photo.fromJson(json)).toList();
      }

      print('No cache found, fetching photos from API for album $albumId');
      // If no cache, fetch from API
      final data = await apiService.get('photos?albumId=$albumId');
      final photos = data.map((json) => Photo.fromJson(json)).toList();
      
      // Cache the new data
      await cacheService.cachePhotos(albumId, json.encode(data));
      
      return photos;
    } catch (e) {
      print('Error in fetchPhotosByAlbumId: $e');
      throw _handleError(e);
    }
  }

  Future<Photo?> fetchFirstPhotoOfAlbum(int albumId) async {
    try {
      print('Fetching first photo for album $albumId...');
      final photos = await fetchPhotosByAlbumId(albumId);
      return photos.isNotEmpty ? photos.first : null;
    } catch (e) {
      print('Error in fetchFirstPhotoOfAlbum: $e');
      throw _handleError(e);
    }
  }

  Future<_AlbumsResult> fetchAlbumsWithOfflineFlag() async {
    try {
      print('Fetching albums...');
      // Check for internet connection
      bool hasConnection = true;
      try {
        final result = await InternetAddress.lookup('google.com');
        hasConnection = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } catch (_) {
        hasConnection = false;
      }
      if (!hasConnection) {
        final cachedData = await cacheService.getCachedAlbums();
        if (cachedData != null) {
          print('Using cached albums data (offline)');
          final List<dynamic> jsonList = json.decode(cachedData);
          return _AlbumsResult(
            albums: jsonList.map((json) => Album.fromJson(json)).toList(),
            isOffline: true,
          );
        } else {
          throw Exception('No internet connection and no cached data available.');
        }
      }
      // If online, fetch from API
      final data = await apiService.get('albums');
      final albums = data.map((json) => Album.fromJson(json)).toList();
      await cacheService.cacheAlbums(json.encode(data));
      return _AlbumsResult(albums: albums, isOffline: false);
    } catch (e) {
      print('Error in fetchAlbumsWithOfflineFlag: $e');
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is SocketException) {
      return Exception('No internet connection. Please check your network settings.');
    } else if (error is HttpException) {
      return Exception('Server error: ${error.message}');
    } else if (error is FormatException) {
      return Exception('Invalid data format received from server.');
    } else {
      return Exception('An unexpected error occurred: ${error.toString()}');
    }
  }
}

class _AlbumsResult {
  final List<Album> albums;
  final bool isOffline;
  _AlbumsResult({required this.albums, required this.isOffline});
} 