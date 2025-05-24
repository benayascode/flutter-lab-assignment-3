import 'package:equatable/equatable.dart';

class Album extends Equatable {
  final int id;
  final String title;

  const Album({required this.id, required this.title});

  factory Album.fromJson(Map<String, dynamic> json) =>
      Album(id: json['id'], title: json['title']);

  Map<String, dynamic> toJson() => {'id': id, 'title': title};

  @override
  List<Object?> get props => [id, title];
} 