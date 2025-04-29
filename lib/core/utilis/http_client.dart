import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as io_client;

http.Client getHttpClient() {
  if (kIsWeb) {
    return http.Client();
  } else {
    return io_client.IOClient();
  }
}