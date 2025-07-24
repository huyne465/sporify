import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sporify/core/services/event_bus_service.dart';
import 'package:sporify/core/services/connection_error_handler.dart';
import 'package:sporify/core/events/network_events.dart';
import 'package:sporify/di/service_locator.dart';

class SpotifySearchWidget extends StatefulWidget {
  const SpotifySearchWidget({super.key});

  @override
  State<SpotifySearchWidget> createState() => _SpotifySearchWidgetState();
}

class _SpotifySearchWidgetState extends State<SpotifySearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String? _lastQuery;
  StreamSubscription? _networkConnectedSubscription;
  final ConnectionErrorHandler _connectionErrorHandler =
      sl<ConnectionErrorHandler>();

  @override
  void initState() {
    super.initState();

    // Listen for network reconnection to retry last search
    _networkConnectedSubscription = sl<EventBusService>().eventBus
        .on<NetworkConnectedEvent>()
        .listen((_) {
          // If we have a last query that failed, retry it
          if (_lastQuery != null && _lastQuery!.isNotEmpty) {
            _searchSpotify(_lastQuery!);
          }
        });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _networkConnectedSubscription?.cancel();
    super.dispose();
  }

  Future<void> _searchSpotify(String query) async {
    // Skip empty queries
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Check network connectivity first
      if (!await _connectionErrorHandler.checkConnection(context)) {
        // Store the query to retry when network is restored
        _lastQuery = query;

        // Add to retry queue
        _connectionErrorHandler.addToRetryQueue(() {
          _searchSpotify(query);
        });

        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Perform search...
      // Clear last query since this one succeeded
      _lastQuery = null;
    } catch (e) {
      // Store the query that failed
      _lastQuery = query;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Search failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search Spotify...',
            suffixIcon: _isLoading
                ? const CircularProgressIndicator()
                : IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _searchSpotify(_searchController.text),
                  ),
          ),
          onSubmitted: _searchSpotify,
        ),
        // Rest of the search UI...
      ],
    );
  }
}
