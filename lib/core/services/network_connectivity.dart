import 'dart:async';
import 'dart:io';
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
  late InternetConnectionChecker _connectionChecker;
  final EventBusService _eventBusService = EventBusService();

  bool _isInitialized = false;
  bool _hasInternetAccess = true;
  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _internetCheckerSubscription;
  Timer? _fallbackTimer;

  // Public getter for internet status
  bool get hasInternetAccess => _hasInternetAccess;

  void initialize() {
    if (!_isInitialized) {
      // Configure InternetConnectionChecker with more lenient settings
      _connectionChecker = InternetConnectionChecker.createInstance(
        checkTimeout: const Duration(seconds: 5),
        checkInterval: const Duration(seconds: 10),
      );

      // Add multiple addresses to check, including more reliable ones
      _connectionChecker.addresses = [
        AddressCheckOptions(
          address: InternetAddress('8.8.8.8'), // Google DNS
          port: 53,
          timeout: const Duration(seconds: 5),
        ),
        AddressCheckOptions(
          address: InternetAddress('1.1.1.1'), // Cloudflare DNS
          port: 53,
          timeout: const Duration(seconds: 5),
        ),
      ];

      // Listen for connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _updateConnectionStatus,
      );

      // Listen for actual internet connectivity with more lenient approach
      _internetCheckerSubscription = _connectionChecker.onStatusChange.listen(
        _updateInternetStatus,
      );

      // Initialize with current status
      checkConnectivity();

      _isInitialized = true;
      print('🌐 Network monitoring initialized with balanced settings');
    }
  }

  Future<void> checkConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    print('🔍 Checking connectivity: $connectivityResult');

    if (connectivityResult == ConnectivityResult.none) {
      _hasInternetAccess = false;
      _eventBusService.eventBus.fire(NetworkDisconnectedEvent());
      return;
    }

    // If we have basic connectivity, do a more lenient internet check
    try {
      final hasInternet = await _connectionChecker.hasConnection;
      print('🌐 Internet check result: $hasInternet');

      if (hasInternet != _hasInternetAccess) {
        _hasInternetAccess = hasInternet;
        if (hasInternet) {
          _eventBusService.eventBus.fire(NetworkConnectedEvent());
        } else {
          _eventBusService.eventBus.fire(NetworkDisconnectedEvent());
        }
      }
    } catch (e) {
      print(
        '⚠️ Internet check failed, but connectivity exists. Assuming connected: $e',
      );
      // If internet check fails but we have connectivity, assume we're connected
      if (!_hasInternetAccess) {
        _hasInternetAccess = true;
        _eventBusService.eventBus.fire(NetworkConnectedEvent());
      }
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    print('📡 Connectivity status changed: $result');
    if (result == ConnectivityResult.none) {
      if (_hasInternetAccess) {
        _hasInternetAccess = false;
        _eventBusService.eventBus.fire(NetworkDisconnectedEvent());
      }
    } else {
      // If we have basic connectivity but internet checker says no internet,
      // do a fallback check after a delay
      Future.delayed(const Duration(seconds: 2), () async {
        try {
          final hasInternet = await _connectionChecker.hasConnection;
          if (!hasInternet && !_hasInternetAccess) {
            // Try a simple HTTP request as fallback
            print('🔄 Trying fallback connectivity check...');
            _performFallbackCheck();
          }
        } catch (e) {
          print('🔄 Fallback: Assuming connected due to connectivity status');
          if (!_hasInternetAccess) {
            _hasInternetAccess = true;
            _eventBusService.eventBus.fire(NetworkConnectedEvent());
          }
        }
      });
    }
  }

  Future<void> _performFallbackCheck() async {
    try {
      // Simple HTTP check to a reliable endpoint
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final request = await client.getUrl(Uri.parse('https://www.google.com'));
      final response = await request.close();
      client.close();

      if (response.statusCode == 200 && !_hasInternetAccess) {
        print('✅ Fallback check successful - internet is available');
        _hasInternetAccess = true;
        _eventBusService.eventBus.fire(NetworkConnectedEvent());
      }
    } catch (e) {
      print('❌ Fallback check failed: $e');
      // If even fallback fails, but we have connectivity, wait a bit more
      if (!_hasInternetAccess) {
        Future.delayed(const Duration(seconds: 5), () {
          if (!_hasInternetAccess) {
            print('🔄 Final fallback: Assuming connected after delay');
            _hasInternetAccess = true;
            _eventBusService.eventBus.fire(NetworkConnectedEvent());
          }
        });
      }
    }
  }

  void _updateInternetStatus(InternetConnectionStatus status) {
    print('🌍 Internet status changed: $status');
    final bool hasInternet = status == InternetConnectionStatus.connected;

    // Only fire events on actual status change
    if (hasInternet != _hasInternetAccess) {
      _hasInternetAccess = hasInternet;
      if (hasInternet) {
        print('✅ Internet connection confirmed');
        _eventBusService.eventBus.fire(NetworkConnectedEvent());
      } else {
        print('❌ Internet connection lost');
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
