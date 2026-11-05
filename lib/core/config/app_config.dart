import 'dart:io' show Platform, HttpClient;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../preferences/preferences.dart';

/// Runtime configuration for Impact Loop mobile client.
class AppConfig {
  AppConfig._();

  static const String _envUrl = String.fromEnvironment('IMPACT_LOOP_API_URL');
  static String? _overrideUrl;

  /// Deployed production server base URL (publicly reachable from any device)
  static const String defaultProductionUrl = 'https://api.impact-loop.dawava.me/api/v1';

  /// Set to true only if running with an offline local Node.js development server
  static const bool useLocalServer = bool.fromEnvironment(
    'USE_LOCAL_SERVER',
    defaultValue: false,
  );

  /// Dynamic runtime override (can be set during test or UI)
  static void setOverrideUrl(String url) {
    _overrideUrl = url;
  }

  /// Normalizes any input URL to ensure proper scheme and ends with '/api/v1' without trailing slash
  static String normalizeUrl(String url) {
    var trimmed = url.trim();
    if (trimmed.isEmpty) return defaultProductionUrl;
    while (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    if (!trimmed.endsWith('/api/v1')) {
      trimmed = '$trimmed/api/v1';
    }
    return trimmed;
  }

  /// Automatically tests candidate local hosts on app startup (only active if useLocalServer is enabled)
  static Future<void> autoDetectHost() async {
    if (kIsWeb || !useLocalServer) return;
    final candidates = [
      '127.0.0.1',
      '10.0.2.2',
      '192.168.1.5',
    ];
    for (final host in candidates) {
      try {
        final client = HttpClient()..connectionTimeout = const Duration(milliseconds: 400);
        final request = await client.getUrl(Uri.parse('http://$host:$defaultLocalPort/api/v1/health'));
        final response = await request.close();
        if (response.statusCode == 200) {
          setOverrideUrl('http://$host:$defaultLocalPort/api/v1');
          client.close();
          return;
        }
        client.close();
      } catch (_) {}
    }
  }

  /// Developer machine LAN IP (used only in local server development mode)
  static const String defaultLocalHost = '127.0.0.1';
  static const String defaultLocalPort = '3000';

  /// Resolves the default host based on platform for local development:
  /// - Windows / macOS / Linux / Web: localhost (127.0.0.1)
  /// - Android Emulator: 10.0.2.2
  static String get _platformDefaultHost {
    if (kIsWeb) return 'localhost';
    try {
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        return '127.0.0.1';
      }
      if (Platform.isAndroid) {
        return '10.0.2.2';
      }
    } catch (_) {}
    return '127.0.0.1';
  }

  /// Resolves the API Base URL:
  /// 1. Dynamic in-memory override (if set)
  /// 2. User preference saved in SharedPreferences
  /// 3. Compile-time `--dart-define=IMPACT_LOOP_API_URL=...`
  /// 4. If USE_LOCAL_SERVER=true -> Platform-based localhost / LAN host
  /// 5. Default -> Live Production Cloud Server: https://api.impact-loop.dawava.me/api/v1
  static String get apiBaseUrl {
    if (_overrideUrl != null && _overrideUrl!.isNotEmpty) {
      return normalizeUrl(_overrideUrl!);
    }
    try {
      final saved = Preferences.instance.getCustomApiUrl();
      if (saved != null && saved.isNotEmpty) {
        return normalizeUrl(saved);
      }
    } catch (_) {
      // Preferences not yet initialized during early bootstrap
    }
    if (_envUrl.isNotEmpty) return normalizeUrl(_envUrl);

    if (useLocalServer) {
      return 'http://$_platformDefaultHost:$defaultLocalPort/api/v1';
    }

    return defaultProductionUrl;
  }

  /// When false, repositories communicate with the live API server.
  /// Set to true only if running without any backend server.
  static const bool useMockApi = bool.fromEnvironment(
    'USE_MOCK_API',
    defaultValue: false,
  );

  static const bool enableOpsPanel = bool.fromEnvironment(
    'ENABLE_OPS_PANEL',
    defaultValue: true,
  );

  static const int defaultPageLimit = 20;
}
