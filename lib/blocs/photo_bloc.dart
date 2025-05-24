import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/photo.dart';
import '../repositories/album_repository.dart';

// Events
abstract class PhotoEvent {}

class FetchPhotos extends PhotoEvent {
  final int albumId;

  FetchPhotos(this.albumId);
}

// States
abstract class PhotoState {}

class PhotoInitial extends PhotoState {}

class PhotoLoading extends PhotoState {}

class PhotoLoaded extends PhotoState {
  final List<Photo> photos;

  PhotoLoaded(this.photos);
}

class PhotoError extends PhotoState {
  final String message;

  PhotoError(this.message);
}

// Bloc
class PhotoBloc extends Bloc<PhotoEvent, PhotoState> {
  final AlbumRepository _repository;

  PhotoBloc(this._repository) : super(PhotoInitial()) {
    on<FetchPhotos>(_onFetchPhotos);
  }

  Future<void> _onFetchPhotos(FetchPhotos event, Emitter<PhotoState> emit) async {
    try {
      emit(PhotoLoading());
      print('PhotoBloc: Fetching photos for album ${event.albumId}...');
      
      final photos = await _repository.fetchPhotosByAlbumId(event.albumId);
      print('PhotoBloc: Fetched ${photos.length} photos');
      
      emit(PhotoLoaded(photos));
      print('PhotoBloc: Emitted PhotoLoaded state');
    } catch (e) {
      print('PhotoBloc: Error fetching photos: $e');
      emit(PhotoError(e.toString()));
    }
  }
} 