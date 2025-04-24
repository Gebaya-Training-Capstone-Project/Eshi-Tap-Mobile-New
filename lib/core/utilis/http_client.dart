import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as io_client;

http.Client getHttpClient() {
  if (kIsWeb) {
    // For web, the default http.Client uses BrowserHttpClientAdapter
    return http.Client();
  } else {
    // For mobile (Android, iOS), use IOHttpClientAdapter
    return io_client.IOClient();
  }
}