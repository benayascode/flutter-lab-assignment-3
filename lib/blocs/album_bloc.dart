import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/album.dart';
import '../models/photo.dart';
import '../repositories/album_repository.dart';

// Events
abstract class AlbumEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchAlbums extends AlbumEvent {}

// States
abstract class AlbumState {}

class AlbumInitial extends AlbumState {}

class AlbumLoading extends AlbumState {}

class AlbumLoaded extends AlbumState {
  final List<Album> albums;
  final Map<int, Photo> thumbnails;
  final bool isOffline;

  AlbumLoaded(this.albums, this.thumbnails, {this.isOffline = false});

  @override
  List<Object?> get props => [albums, thumbnails, isOffline];
}

class AlbumError extends AlbumState {
  final String message;

  AlbumError(this.message);
}

// Bloc
class AlbumBloc extends Bloc<AlbumEvent, AlbumState> {
  final AlbumRepository _repository;

  AlbumBloc(this._repository) : super(AlbumInitial()) {
    on<FetchAlbums>(_onFetchAlbums);
  }

  Future<void> _onFetchAlbums(FetchAlbums event, Emitter<AlbumState> emit) async {
    try {
      emit(AlbumLoading());
      print('AlbumBloc: Fetching albums...');
      
      final result = await _repository.fetchAlbumsWithOfflineFlag();
      final albums = result.albums;
      final isOffline = result.isOffline;
      print('AlbumBloc: Fetched ${albums.length} albums (offline: $isOffline)');
      
      final thumbnails = <int, Photo>{};
      for (final album in albums) {
        try {
          final photo = await _repository.fetchFirstPhotoOfAlbum(album.id);
          if (photo != null) {
            thumbnails[album.id] = photo;
          }
        } catch (e) {
          print('AlbumBloc: Error fetching thumbnail for album ${album.id}: $e');
        }
      }
      
      emit(AlbumLoaded(albums, thumbnails, isOffline: isOffline));
      print('AlbumBloc: Emitted AlbumLoaded state');
    } catch (e) {
      print('AlbumBloc: Error fetching albums: $e');
      emit(AlbumError(e.toString()));
    }
  }
} 