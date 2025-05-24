import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';
import 'services/cache_service.dart';
import 'repositories/album_repository.dart';
import 'blocs/album_bloc.dart';
import 'blocs/photo_bloc.dart';
import 'views/album_list_screen.dart';
import 'views/album_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final apiService = ApiService();
  final cacheService = CacheService(prefs);
  final albumRepository = AlbumRepository(apiService, cacheService);
  runApp(MyApp(albumRepository: albumRepository));
}

class MyApp extends StatelessWidget {
  final AlbumRepository albumRepository;
  MyApp({required this.albumRepository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AlbumBloc>(
          create: (context) => AlbumBloc(albumRepository)..add(FetchAlbums()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Albums App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(0xFF1B5E20), // Dark green primary color
            primary: Color(0xFF1B5E20),
            secondary: Color(0xFF2E7D32),
            surface: Color(0xFFF5F5F5),
            background: Color(0xFFFFFFFF),
            error: Color(0xFFB00020),
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: Colors.black87,
            onBackground: Colors.black87,
            onError: Colors.white,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF1B5E20),
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1B5E20),
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          iconTheme: IconThemeData(
            color: Color(0xFF1B5E20),
          ),
        ),
        routerConfig: GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => AlbumListScreen(),
            ),
            GoRoute(
              path: '/album/:id',
              builder: (context, state) {
                final albumId = int.parse(state.pathParameters['id']!);
                return BlocProvider(
                  create: (context) => PhotoBloc(albumRepository)..add(FetchPhotos(albumId)),
                  child: AlbumDetailScreen(
                    albumId: albumId,
                    albumTitle: 'Album $albumId',
                  ),
                );
              },
            ),
          ],
          errorBuilder: (context, state) => Scaffold(
            body: Center(
              child: Text('Error: ${state.error}'),
            ),
          ),
        ),
      ),
    );
  }
}
