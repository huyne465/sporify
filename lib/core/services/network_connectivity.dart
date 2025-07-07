import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:sporify/core/events/network_events.dart';
import 'package:sporify/core/services/event_bus_service.dart';

class NetworkConnectivity {
  // Singleton pattern
  static final NetworkConnectivity _instance = NetworkConnectivity._internal();
  factory NetworkConnectivity() => _instance;
  NetworkConnectivity._internal();

  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _connectionChecker =
      InternetConnectionChecker();
  final EventBusService _eventBusService = EventBusService();

  bool _isInitialized = false;
  bool _hasInternetAccess = true;
  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _internetCheckerSubscription;

  // Public getter for internet status
  bool get hasInternetAccess => _hasInternetAccess;

  void initialize() {
    if (!_isInitialized) {
      // Listen for connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _updateConnectionStatus,
      );

      // Listen for actual internet connectivity
      _internetCheckerSubscription = _connectionChecker.onStatusChange.listen(
        _updateInternetStatus,
      );

      // Initialize with current status
      checkConnectivity();

      _isInitialized = true;
    }
  }

  Future<void> checkConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    _updateConnectionStatus(connectivityResult);

    final hasInternet = await _connectionChecker.hasConnection;
    _updateInternetStatus(
      hasInternet
          ? InternetConnectionStatus.connected
          : InternetConnectionStatus.disconnected,
    );
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    print('Connectivity status changed: $result');
    if (result == ConnectivityResult.none) {
      _hasInternetAccess = false;
      _eventBusService.eventBus.fire(NetworkDisconnectedEvent());
    } else {
      // Don't immediately assume connected - InternetConnectionChecker will verify
      _connectionChecker.hasConnection.then((hasInternet) {
        if (hasInternet && !_hasInternetAccess) {
          _hasInternetAccess = true;
          _eventBusService.eventBus.fire(NetworkConnectedEvent());
        }
      });
    }
  }

  void _updateInternetStatus(InternetConnectionStatus status) {
    print('Internet status changed: $status');
    final bool hasInternet = status == InternetConnectionStatus.connected;

    // Only fire events on actual status change
    if (hasInternet != _hasInternetAccess) {
      _hasInternetAccess = hasInternet;
      if (hasInternet) {
        _eventBusService.eventBus.fire(NetworkConnectedEvent());
      } else {
        _eventBusService.eventBus.fire(NetworkDisconnectedEvent());
      }
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _internetCheckerSubscription?.cancel();
    _isInitialized = false;
  }
}
