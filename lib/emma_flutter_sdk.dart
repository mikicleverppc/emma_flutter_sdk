import 'dart:async';

import 'package:flutter/services.dart';

class EmmaFlutterSdk {
  static const MethodChannel _channel = const MethodChannel('emma_flutter_sdk');

  /// Retrieves current EMMA SDK Version
  static Future<String> getEMMAVersion() async {
    final String version = await _channel.invokeMethod('getEMMAVersion');
    return version;
  }

  /// Starts EMMA Session with a [sessionKey].
  ///
  /// You can use [debugEnabled] to enable logging on your device.
  /// This log is only visible on device consoles
  static Future<void> startSession(String sessionKey,
      {bool debugEnabled = false}) async {
    await _channel.invokeMethod('startSession',
        {'sessionKey': sessionKey, 'debugEnabled': debugEnabled});
    return;
  }

  /// Send an event to emma identified by [eventToken].
  /// You can also assign some attributtes to this event with [eventArguments]
  static Future<void> trackEvent(String eventToken,
      {Object eventArguments}) async {
    await _channel.invokeMethod('trackEvent',
        {'eventToken': eventToken, 'eventArguments': eventArguments});
    return;
  }
}
