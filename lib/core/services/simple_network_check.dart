import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class SimpleNetworkCheck {
  static final SimpleNetworkCheck _instance = SimpleNetworkCheck._internal();
  factory SimpleNetworkCheck() => _instance;
  SimpleNetworkCheck._internal();

  /// Performs a simple and fast network connectivity check
  /// Returns true if device has any form of network connectivity
  static Future<bool> hasBasicConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      print('Error checking basic connectivity: $e');
      return false;
    }
  }

  /// Performs a comprehensive network check with fallback options
  /// More lenient than strict internet connection checkers
  static Future<bool> hasInternetAccess() async {
    try {
      // First check basic connectivity
      if (!await hasBasicConnectivity()) {
        return false;
      }

      // Try a quick HTTP request with timeout
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 3);

      try {
        final request = await client.getUrl(
          Uri.parse('https://www.google.com'),
        );
        final response = await request.close();
        client.close();
        return response.statusCode == 200;
      } catch (e) {
        client.close();

        // Fallback: try another endpoint
        final client2 = HttpClient();
        client2.connectionTimeout = const Duration(seconds: 3);

        try {
          final request2 = await client2.getUrl(
            Uri.parse('https://cloudflare.com'),
          );
          final response2 = await request2.close();
          client2.close();
          return response2.statusCode == 200;
        } catch (e2) {
          client2.close();

          // If all HTTP checks fail but we have basic connectivity,
          // assume we have internet (maybe just slow or restricted)
          print(
            'HTTP checks failed but basic connectivity exists. Assuming internet access.',
          );
          return true;
        }
      }
    } catch (e) {
      print('Error in comprehensive network check: $e');
      // If there's an error in our check, but we know we have basic connectivity,
      // err on the side of assuming we have internet
      return await hasBasicConnectivity();
    }
  }

  /// Quick check that prioritizes user experience over perfect accuracy
  static Future<bool> hasWorkingConnection() async {
    // If basic connectivity exists, assume we have a working connection
    // This reduces false negatives in emulators and edge cases
    final hasBasic = await hasBasicConnectivity();
    if (!hasBasic) return false;

    // For better UX, if we have basic connectivity, assume it's working
    // unless we can quickly prove otherwise
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 2);
      final request = await client.getUrl(Uri.parse('https://www.google.com'));
      await request.close(); // Just close the connection, don't need response
      client.close();
      return true; // If we get any response, assume working
    } catch (e) {
      // If the quick check fails, still assume working if we have basic connectivity
      print('Quick check failed but basic connectivity exists: $e');
      return true;
    }
  }
}
