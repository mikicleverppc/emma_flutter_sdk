import 'dart:async';

import 'package:flutter/services.dart';

class EMMAConfig {
  final String sessionKey;

  EMMAConfig._builder(EMMAConfigBuilder builder)
      : sessionKey = builder.sessionKey;
}

class EMMAConfigBuilder {
  final String sessionKey;

  EMMAConfigBuilder(this.sessionKey);

  EMMAConfig build() {
    return EMMAConfig._builder(this);
  }
}

class EmmaFlutterSdk {
  static const MethodChannel _channel = const MethodChannel('emma_flutter_sdk');

  static Future<String> getEMMAVersion() async {
    final String version = await _channel.invokeMethod('getEMMAVersion');
    return version;
  }

  static Future<void> startSession(String sessionKey,
      {bool debugEnabled = false}) async {
    await _channel.invokeMethod(
      'startSession',
      {'sessionKey': sessionKey,
      'debugEnabled': debugEnabled
      }
    );
    return;
  }
}
