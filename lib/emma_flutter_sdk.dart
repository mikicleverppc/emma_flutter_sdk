import 'dart:async';
import 'package:flutter/services.dart';
import 'src/inapp_message_request.dart';
import 'src/native_ad.dart';

export 'src/defines.dart';
export 'src/native_ad.dart';
export 'src/inapp_message_request.dart';


typedef void ReceivedNativeAdsHandler(List<EmmaNativeAd> nativeAds);

class EmmaFlutterSdk {
  static EmmaFlutterSdk shared = new EmmaFlutterSdk();

  // method channels
  MethodChannel _channel = const MethodChannel('emma_flutter_sdk');

  // event handlers
  ReceivedNativeAdsHandler _onReceivedNativeAds;

  EmmaFlutterSdk() {
    this._channel.setMethodCallHandler(_manageCallHandler);
  }

  Future<Null> _manageCallHandler(MethodCall call) async {
    switch (call.method) {
      case "Emma#onReceiveNativeAds":
        List<dynamic> nativeAdsMap = call.arguments;
        this._onReceivedNativeAds(nativeAdsMap.map((nativeAdMap) =>
              new EmmaNativeAd.fromMap(nativeAdMap.cast<String, dynamic>())).toList());
        break;
    }
    return null;
  }

  void setReceivedNativeAdsHandler(ReceivedNativeAdsHandler handler) =>
      _onReceivedNativeAds = handler;

  /// Retrieves current EMMA SDK Version
  Future<String> getEMMAVersion() async {
    final String version = await _channel.invokeMethod('getEMMAVersion');
    return version;
  }

  /// Starts EMMA Session with a [sessionKey].
  ///
  /// You can use [debugEnabled] to enable logging on your device.
  /// This log is only visible on device consoles
  Future<void> startSession(String sessionKey,
      {bool debugEnabled = false}) async {
    await _channel.invokeMethod('startSession',
        {'sessionKey': sessionKey, 'debugEnabled': debugEnabled});
    return;
  }

  /// Send an event to emma identified by [eventToken].
  /// You can also assign some attributtes to this event with [eventArguments]
  Future<void> trackEvent(String eventToken,
      {Map<String, String> eventArguments}) async {
    await _channel.invokeMethod('trackEvent',
        {'eventToken': eventToken, 'eventArguments': eventArguments});
    return;
  }

  /// You can complete user profile with extra parameters
  Future<void> trackExtraUserInfo(
      Map<String, String> extraUserInfo) async {
    await _channel
        .invokeMethod('trackExtraUserInfo', {'extraUserInfo': extraUserInfo});
    return;
  }

  /// Sends a login to EMMA
  /// [userId] is your customer id for this user
  /// [email] is a unique email of this user
  Future<void> loginUser(String userId, String email) async {
    await _channel
        .invokeMethod('loginUser', {'userId': userId, 'email': email});
    return;
  }

  /// Sends register event to EMMA
  /// [userId] is your customer id for this user
  /// [email] is a unique email of this user
  Future<void> registerUser(String userId, String email) async {
    await _channel
        .invokeMethod('registerUser', {'userId': userId, 'email': email});
    return;
  }

  /// Checks for an InApp Message
  /// You must pass [EmmaInAppMessageRequest] of message you're expecting
  Future<void> inAppMessage(EmmaInAppMessageRequest request) async {
    await _channel.invokeMethod('inAppMessage', request.toMap());
    return;
  }

  /// Init EMMA Push system
  /// You must define [notificationIcon] for Android OS
  /// Optional param [notificationChannel] to define notification channel name for Android OS. Default app name.
  /// Optional param [notificationChannelId] to subscribe an existent channel.
  Future<void> startPushSystem(String notificationIcon,
      {String notificationChannel = null, String notificationChannelId = null} ) async {
    await _channel.invokeMethod('startPushSystem', {'notificationIcon': notificationIcon,
      'notificationChannel': notificationChannel, 'notificationChannelId': notificationChannelId});
    return;
  }
}
