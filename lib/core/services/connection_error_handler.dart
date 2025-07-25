import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sporify/core/services/event_bus_service.dart';
import 'package:sporify/core/services/simple_network_check.dart';
import 'package:sporify/core/events/network_events.dart';

class ConnectionErrorHandler {
  static final ConnectionErrorHandler _instance =
      ConnectionErrorHandler._internal();
  factory ConnectionErrorHandler() => _instance;
  ConnectionErrorHandler._internal();

  final EventBusService _eventBusService = EventBusService();
  final List<Function> _retryQueue = [];
  StreamSubscription? _networkConnectedSubscription;

  // Banner to show when offline
  OverlayEntry? _offlineBanner;
  bool _isShowingOfflineBanner = false;

  void initialize(BuildContext context) {
    // Listen for network reconnection to process retry queue
    _networkConnectedSubscription = _eventBusService.eventBus
        .on<NetworkConnectedEvent>()
        .listen((_) {
          _processRetryQueue();
          if (_isShowingOfflineBanner) {
            _hideOfflineBanner();
          }
        });

    // Listen for network disconnection to show banner
    _eventBusService.eventBus.on<NetworkDisconnectedEvent>().listen((_) {
      _showOfflineBanner(context);
    });
  }

  void addToRetryQueue(Function retryAction) {
    _retryQueue.add(retryAction);
    print('Added action to retry queue. Queue size: ${_retryQueue.length}');
  }

  Future<void> _processRetryQueue() async {
    print('Processing retry queue. Items: ${_retryQueue.length}');
    if (_retryQueue.isEmpty) return;

    // Create a copy of the queue to avoid modification during iteration
    final actionsToRetry = List<Function>.from(_retryQueue);
    _retryQueue.clear();

    // Delay a bit to ensure connection is stable
    await Future.delayed(const Duration(seconds: 1));

    // Process each retry action
    for (final action in actionsToRetry) {
      try {
        action();
      } catch (e) {
        print('Error executing retry action: $e');
      }
    }
  }

  void _showOfflineBanner(BuildContext context) {
    if (_isShowingOfflineBanner) return;

    _offlineBanner = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            color: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.wifi_off, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'No internet connection',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_offlineBanner!);
    _isShowingOfflineBanner = true;
  }

  void _hideOfflineBanner() {
    if (!_isShowingOfflineBanner) return;
    _offlineBanner?.remove();
    _offlineBanner = null;
    _isShowingOfflineBanner = false;
  }

  void dispose() {
    _networkConnectedSubscription?.cancel();
    _hideOfflineBanner();
    _retryQueue.clear();
  }

  bool get hasInternetAccess =>
      true; // Using simple check now, assume connected

  Future<bool> checkConnection(BuildContext context) async {
    final hasConnection = await SimpleNetworkCheck.hasWorkingConnection();
    if (!hasConnection) {
      _showOfflineBanner(context);
      return false;
    }
    return true;
  }
}
