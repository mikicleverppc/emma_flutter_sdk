import 'dart:async';

import 'package:flutter/services.dart';

enum InAppType { startview }

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
      {Map<String, String> eventArguments}) async {
    await _channel.invokeMethod('trackEvent',
        {'eventToken': eventToken, 'eventArguments': eventArguments});
    return;
  }

  /// You can complete user profile with extra parameters
  static Future<void> trackExtraUserInfo(
      Map<String, String> extraUserInfo) async {
    await _channel
        .invokeMethod('trackExtraUserInfo', {'extraUserInfo': extraUserInfo});
    return;
  }

  /// Sends a login to EMMA
  static Future<void> loginUser(String userId, String email) async {
    await _channel
        .invokeMethod('loginUser', {'userId': userId, 'email': email});
    return;
  }

  /// Sends register event to EMMA
  static Future<void> registerUser(String userId, String email) async {
    await _channel
        .invokeMethod('registerUser', {'userId': userId, 'email': email});
    return;
  }

  static Future<void> inAppMessage(InAppType inAppType) async {
    String type = inAppType.toString().split(".")[1];
    await _channel.invokeMethod('inAppMessage', {'inAppType': type});
    return;
  }
}
