import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:3000/api';
      case TargetPlatform.iOS:
        return 'http://localhost:3000/api';
      default:
        return 'http://127.0.0.1:3000/api';
    }
  }
}
