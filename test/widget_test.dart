// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled1/main.dart';
import 'package:untitled1/repositories/album_repository.dart';
import 'package:untitled1/services/api_service.dart';
import 'package:untitled1/services/cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final apiService = ApiService();
    final cacheService = CacheService(prefs);
    final albumRepository = AlbumRepository(apiService, cacheService);

    await tester.pumpWidget(MyApp(albumRepository: albumRepository));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
