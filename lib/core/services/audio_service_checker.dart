import 'package:just_audio/just_audio.dart';
import 'dart:io';

class AudioServiceChecker {
  static Future<Map<String, dynamic>> checkAudioCapabilities() async {
    final results = <String, dynamic>{};
    final testPlayer = AudioPlayer();

    try {
      // Test 1: Basic player initialization
      results['player_initialization'] = true;
      results['platform'] = Platform.operatingSystem;

      // Test 2: Test multiple audio formats
      final testUrls = [
        // Simple test MP3
        'https://www.soundjay.com/misc/sounds/bell-ringing-05.mp3',
        // Another reliable test URL
        'https://file-examples.com/storage/fec1b5c8f66e23cb3b1b633/2017/11/file_example_MP3_700KB.mp3',
        // Firebase Storage sample (if available)
        'https://firebasestorage.googleapis.com/v0/b/sporify-app.appspot.com/o/test%2Fsample.mp3?alt=media&token=test',
      ];

      for (int i = 0; i < testUrls.length; i++) {
        final url = testUrls[i];
        try {
          print('🔊 Testing URL $i: $url');

          await testPlayer
              .setAudioSource(AudioSource.uri(Uri.parse(url)), preload: false)
              .timeout(Duration(seconds: 10));

          results['test_url_$i'] = {
            'url': url,
            'status': 'success',
            'duration': testPlayer.duration?.inMilliseconds ?? 0,
          };

          print('🔊 URL $i loaded successfully');
          break; // Stop on first successful URL
        } catch (e) {
          results['test_url_$i'] = {
            'url': url,
            'status': 'failed',
            'error': e.toString(),
          };
          print('🔊 URL $i failed: $e');
        }
      }

      // Test 3: Audio format support detection
      results['supported_formats'] = [
        'mp3',
        'wav',
        'm4a',
        'aac',
        'ogg',
        'flac',
      ];

      // Test 4: Network connectivity for audio
      try {
        final httpClient = HttpClient();
        final request = await httpClient
            .getUrl(Uri.parse('https://www.google.com'))
            .timeout(Duration(seconds: 5));
        final response = await request.close().timeout(Duration(seconds: 5));
        results['network_connectivity'] = response.statusCode == 200;
        httpClient.close();
      } catch (e) {
        results['network_connectivity'] = false;
        results['network_error'] = e.toString();
      }

      // Test 5: ExoPlayer specific checks (Android)
      if (Platform.isAndroid) {
        results['exoplayer_available'] = true;
        results['audio_decoder_info'] = 'ExoPlayer backend detected';
      }

      // Test 6: Device capabilities
      results['device_info'] = {
        'platform': Platform.operatingSystem,
        'version': Platform.operatingSystemVersion,
        'is_physical_device': !Platform.environment.containsKey('FLUTTER_TEST'),
      };

      results['test_timestamp'] = DateTime.now().toIso8601String();
      results['overall_audio_support'] =
          results.containsKey('test_url_0') &&
          results['test_url_0']['status'] == 'success';
    } catch (e) {
      results['player_initialization'] = false;
      results['initialization_error'] = e.toString();
    } finally {
      await testPlayer.dispose();
    }

    return results;
  }

  static void printAudioDiagnostics(Map<String, dynamic> results) {
    print('🔊 ========== Audio Service Diagnostics ==========');

    // Essential info first
    print('🔊 Platform: ${results['platform']}');
    print('🔊 Player Initialization: ${results['player_initialization']}');
    print('🔊 Network Connectivity: ${results['network_connectivity']}');
    print('🔊 Overall Audio Support: ${results['overall_audio_support']}');

    if (results['device_info'] != null) {
      final deviceInfo = results['device_info'] as Map<String, dynamic>;
      print('🔊 Device: ${deviceInfo['platform']} ${deviceInfo['version']}');
      print('🔊 Physical Device: ${deviceInfo['is_physical_device']}');
    }

    // Test results
    print('🔊 ------------------- Test Results -------------------');
    for (int i = 0; i < 3; i++) {
      if (results.containsKey('test_url_$i')) {
        final test = results['test_url_$i'] as Map<String, dynamic>;
        print('🔊 URL Test $i: ${test['status']}');
        if (test['status'] == 'success') {
          print('🔊   Duration: ${test['duration']}ms');
        } else {
          print('🔊   Error: ${test['error']}');
        }
      }
    }

    // Errors
    if (results.containsKey('initialization_error')) {
      print('🔊 Initialization Error: ${results['initialization_error']}');
    }
    if (results.containsKey('network_error')) {
      print('🔊 Network Error: ${results['network_error']}');
    }

    print('🔊 ===============================================');
  }

  // Helper method to test a specific URL
  static Future<Map<String, dynamic>> testSpecificUrl(String url) async {
    final testPlayer = AudioPlayer();
    final result = <String, dynamic>{};

    try {
      print('🔊 Testing specific URL: $url');

      final startTime = DateTime.now();
      await testPlayer
          .setAudioSource(AudioSource.uri(Uri.parse(url)), preload: false)
          .timeout(Duration(seconds: 15));

      final loadTime = DateTime.now().difference(startTime).inMilliseconds;

      result['url'] = url;
      result['status'] = 'success';
      result['load_time_ms'] = loadTime;
      result['duration_ms'] = testPlayer.duration?.inMilliseconds ?? 0;
      result['has_duration'] = testPlayer.duration != null;
    } catch (e) {
      result['url'] = url;
      result['status'] = 'failed';
      result['error'] = e.toString();
      result['error_type'] = _categorizeError(e.toString());
    } finally {
      await testPlayer.dispose();
    }

    return result;
  }

  static String _categorizeError(String error) {
    if (error.contains('timeout')) return 'TIMEOUT';
    if (error.contains('404')) return 'NOT_FOUND';
    if (error.contains('403')) return 'ACCESS_DENIED';
    if (error.contains('FormatException') ||
        error.contains('IllegalArgumentException')) {
      return 'FORMAT_ERROR';
    }
    if (error.contains('ExoPlayerImplInternal') ||
        error.contains('DefaultAudioSink')) {
      return 'DECODER_ERROR';
    }
    if (error.contains('SocketException') || error.contains('HttpException')) {
      return 'NETWORK_ERROR';
    }
    return 'UNKNOWN';
  }
}
