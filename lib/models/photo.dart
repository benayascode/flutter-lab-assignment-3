import 'package:equatable/equatable.dart';

class Photo extends Equatable {
  final int id;
  final int albumId;
  final String title;
  final String url;
  final String thumbnailUrl;

  const Photo({
    required this.id,
    required this.albumId,
    required this.title,
    required this.url,
    required this.thumbnailUrl,
  });

  factory Photo.fromJson(Map<String, dynamic> json) => Photo(
        id: json['id'],
        albumId: json['albumId'],
        title: json['title'],
        url: json['url'],
        thumbnailUrl: json['thumbnailUrl'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'albumId': albumId,
        'title': title,
        'url': url,
        'thumbnailUrl': thumbnailUrl,
      };

  @override
  List<Object?> get props => [id, albumId, title, url, thumbnailUrl];
} 