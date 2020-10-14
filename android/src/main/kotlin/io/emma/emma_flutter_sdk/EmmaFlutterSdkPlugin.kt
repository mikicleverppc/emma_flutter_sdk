package io.emma.emma_flutter_sdk

import android.app.Application
import android.content.Context
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.emma.android.EMMA
import java.lang.Exception

/** EmmaFlutterSdkPlugin */
class EmmaFlutterSdkPlugin : FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine anad unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel

  private lateinit var applicationContext: Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    applicationContext = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "emma_flutter_sdk")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getEMMAVersion" -> {
        result.success(EMMA.getInstance().sdkVersion)
      }
      "startSession" -> {
        var sessionKey = call.argument<String>("sessionKey")
        var debugEnabled = call.argument<Boolean>("debugEnabled")

        try {
          val configuration = EMMA.Configuration.Builder(applicationContext)
                  .setSessionKey(sessionKey)
                  .setQueueTime(25)
                  .setDebugActive(debugEnabled!!)
                  .build()

          EMMA.getInstance().startSession(configuration)

          result.success("");
        } catch (error: Exception) {
          result.error("START_SESSION", "Error starting session", "Start session method throw an error")
        }
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
