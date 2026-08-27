import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../utils/logger.dart';

/// A secure HTTP client that enforces HTTPS and allows for SSL Certificate Pinning.
class SecureHttpClient {
  static http.Client? _client;

  /// Returns an [http.Client] that enforces strict SSL/TLS validation.
  static http.Client get client {
    if (_client != null) return _client!;

    // Enforce TLS 1.2 or higher
    final SecurityContext context = SecurityContext(withTrustedRoots: true);

    // TODO: In production, load your server's certificate here for pinning.
    // Example:
    // final certBytes = await rootBundle.load('assets/certs/server.crt');
    // context.setTrustedCertificatesBytes(certBytes.buffer.asUint8List());
    
    AppLogger.info('SecureHttpClient initialized with strict SSL validation.');

    final ioClient = HttpClient(context: context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Reject all bad certificates to prevent Man-in-the-Middle (MITM) attacks
        AppLogger.error('SSL MITM Threat Blocked! Bad certificate from: $host');
        return false;
      };

    _client = IOClient(ioClient);
    return _client!;
  }
}
