import 'package:flutter/services.dart';

class PlatformChannel {
  static const MethodChannel _channel = MethodChannel('focus_app');

  static Future<void> closeOtherApps() async {
    try {
      await _channel.invokeMethod('closeOtherApps');
    } on PlatformException catch (e) {
      print('Failed to close apps: ${e.message}');
    }
  }
}
