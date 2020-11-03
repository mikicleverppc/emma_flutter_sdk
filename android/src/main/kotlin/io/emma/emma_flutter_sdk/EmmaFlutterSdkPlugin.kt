package io.emma.emma_flutter_sdk

import android.app.Activity
import android.content.Context
import android.content.res.Resources
import androidx.annotation.DrawableRes
import androidx.annotation.NonNull
import androidx.annotation.Nullable
import io.emma.android.EMMA
import io.emma.android.model.EMMACampaign
import io.emma.android.model.EMMAEventRequest
import io.emma.android.model.EMMAInAppRequest
import io.emma.android.model.EMMAPushOptions
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** EmmaFlutterSdkPlugin */
class EmmaFlutterSdkPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine anad unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel

  private lateinit var applicationContext: Context

  private lateinit var activity: Activity

  private lateinit var assets: FlutterPlugin.FlutterAssets

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    applicationContext = flutterPluginBinding.applicationContext
    assets = flutterPluginBinding.flutterAssets
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
                ?: return returnError(result, call.method, "sessionKey")
        var debugEnabled = call.argument<Boolean>("debugEnabled")
                ?: return returnError(result, call.method, "debugEnabled")

        val configuration = EMMA.Configuration.Builder(applicationContext)
                .setSessionKey(sessionKey)
                .setQueueTime(25)
                .setDebugActive(debugEnabled)
                .build()

        EMMA.getInstance().startSession(configuration)

        result.success(null);
      }
      "trackEvent" -> {
        var eventToken = call.argument<String>("eventToken")
                ?: return returnError(result, call.method, "eventToken")
        var eventRequest = EMMAEventRequest(eventToken)

        call.argument<HashMap<String, Any>>("eventAttributes").let { attributes ->
          eventRequest.attributes = attributes
        }

        EMMA.getInstance().trackEvent(eventRequest)
        result.success(null)
      }
      "trackExtraUserInfo" -> {
        var userAttributes = call.argument<Map<String, String>>("extraUserInfo")
                ?: return returnError(result, call.method, "extraUserInfo")
        EMMA.getInstance().trackExtraUserInfo(userAttributes)
        result.success(null)
      }
      "loginUser" -> {
        var userId = call.argument<String>("userId")
                ?: return returnError(result, call.method, "userId")
        var email = call.argument<String>("email") ?: ""
        EMMA.getInstance().loginUser(userId, email)
      }
      "registerUser" -> {
        var userId = call.argument<String>("userId")
                ?: return returnError(result, call.method, "userId")
        var email = call.argument<String>("email") ?: ""
        EMMA.getInstance().registerUser(userId, email)
      }
      "inAppMessage" -> {
        var inAppRequestType = call.argument<String>("inAppType")
                ?: return returnError(result, call.method, "inAppType")

        getInAppRequestTypeFromString(inAppRequestType).let {
          var request = EMMAInAppRequest(it!!)
          EMMA.getInstance().getInAppMessage(request)
        }

      }
      "startPushSystem" -> {

        var pushIcon = getNotificationIcon(applicationContext, "notification_icon")

        if (pushIcon == 0) {
          return returnError(result, call.method, "pushIcon")
        }

        val pushOpt = EMMAPushOptions.Builder(activity::class.java, pushIcon)
                .setNotificationChannelName("Mi custom channel")
                .build()

        EMMA.getInstance().startPushSystem(pushOpt)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  fun getInAppRequestTypeFromString(type: String): EMMACampaign.Type? {
    when(type) {
      "startview" -> {
        return EMMACampaign.Type.STARTVIEW
      }
      else -> {
        return null
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun returnError(@NonNull result: Result, methodName: String, @Nullable parameter: String? = null) {
    result.error("METHOD_ERROR", "Error in: $methodName", "Error in parameter: $parameter" ?: null)
  }

  override fun onDetachedFromActivity() {
    TODO("Not yet implemented")
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    TODO("Not yet implemented")
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity;
    EMMA.getInstance().setCurrentActivity(activity)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    TODO("Not yet implemented")
  }

  @DrawableRes
  private fun getNotificationIcon(context: Context, imageName: String): Int {
    val res: Resources = context.resources
    return res.getIdentifier(imageName, "drawable", context.packageName)
  }
}
