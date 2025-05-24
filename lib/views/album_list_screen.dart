import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/album_bloc.dart';
import '../models/album.dart';

class AlbumListScreen extends StatefulWidget {
  @override
  State<AlbumListScreen> createState() => _AlbumListScreenState();
}

class _AlbumListScreenState extends State<AlbumListScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure we fetch albums when the screen is first created
    context.read<AlbumBloc>().add(FetchAlbums());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Albums'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              print('Manual refresh triggered');
              context.read<AlbumBloc>().add(FetchAlbums());
            },
          ),
        ],
      ),
      body: BlocBuilder<AlbumBloc, AlbumState>(
        builder: (context, state) {
          print('AlbumListScreen: Current state: ${state.runtimeType}');
          
          if (state is AlbumInitial) {
            print('AlbumListScreen: Initial state');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF1B5E20),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Initializing...',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          if (state is AlbumLoading) {
            print('AlbumListScreen: Loading state');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF1B5E20),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading albums...',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          if (state is AlbumError) {
            print('AlbumListScreen: Error state: ${state.message}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Color(0xFF1B5E20),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Error loading albums',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      print('AlbumListScreen: Retrying fetch albums...');
                      context.read<AlbumBloc>().add(FetchAlbums());
                    },
                    icon: Icon(Icons.refresh),
                    label: Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1B5E20),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is AlbumLoaded) {
            print('AlbumListScreen: Loaded state with ${state.albums.length} albums');
            return Column(
              children: [
                if (state.isOffline)
                  Container(
                    width: double.infinity,
                    color: Color(0xFF1B5E20).withOpacity(0.15),
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off, color: Color(0xFF1B5E20), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Offline Mode: Showing cached data',
                          style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    color: Color(0xFF1B5E20),
                    onRefresh: () async {
                      print('AlbumListScreen: Pull to refresh triggered');
                      context.read<AlbumBloc>().add(FetchAlbums());
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: state.albums.length,
                      itemBuilder: (context, index) {
                        final album = state.albums[index];
                        return Card(
                          elevation: 2,
                          margin: EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            onTap: () {
                              print('AlbumListScreen: Navigating to album ${album.id}');
                              context.go('/album/${album.id}');
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF1B5E20).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.photo_album,
                                      color: Color(0xFF1B5E20),
                                      size: 32,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          album.title,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Album ID: ${album.id}',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey[400],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }

          print('AlbumListScreen: Unknown state');
          return Center(
            child: Text('No albums found'),
          );
        },
      ),
    );
  }
} 