package io.emma.emma_flutter_sdk

import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull
import androidx.annotation.Nullable
import io.emma.android.EMMA
import io.emma.android.interfaces.EMMABatchNativeAdInterface
import io.emma.android.interfaces.EMMAInAppMessageInterface
import io.emma.android.interfaces.EMMANativeAdInterface
import io.emma.android.utils.EMMALog
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.emma.android.model.*
import kotlin.collections.ArrayList
import kotlin.collections.HashMap

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
        startSession(call, result)
      }
      "trackEvent" -> {
        trackEvent(call, result)
      }
      "trackExtraUserInfo" -> {
        trackExtraUserInfo(call, result)
      }
      "loginUser" -> {
        loginUser(call, result)
      }
      "registerUser" -> {
        registerUser(call, result)
      }
      "inAppMessage" -> {
        inappMessage(call, result)
      }
      "startPushSystem" -> {
        startPushSystem(call, result)
      }
      else -> {
        EMMALog.w("Method ${call.method} not implemented")
        Utils.runOnMainThread(Runnable { result.notImplemented() })
      }
    }
  }

  fun getInAppRequestTypeFromString(type: String): EMMACampaign.Type? {
    when(type) {
      "startview" -> {
        return EMMACampaign.Type.STARTVIEW
      }
      "nativeAd" -> {
        return EMMACampaign.Type.NATIVEAD
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
    // Not implemented
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    // Not implemented
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity;
    EMMA.getInstance().setCurrentActivity(activity)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    // Not implemented
  }

  private fun startSession(@NonNull call: MethodCall, @NonNull result: Result) {
    val sessionKey = call.argument<String>("sessionKey")
            ?: return returnError(result, call.method, "sessionKey")
    val debugEnabled = call.argument<Boolean>("debugEnabled")
            ?: return returnError(result, call.method, "debugEnabled")

    val configuration = EMMA.Configuration.Builder(applicationContext)
            .setSessionKey(sessionKey)
            .setQueueTime(25)
            .setDebugActive(debugEnabled)
            .build()

    EMMA.getInstance().startSession(configuration)
    result.success(null);
  }

  private fun trackEvent(@NonNull call: MethodCall, @NonNull result: Result) {
    val eventToken = call.argument<String>("eventToken")
            ?: return returnError(result, call.method, "eventToken")
    val eventRequest = EMMAEventRequest(eventToken)

    call.argument<HashMap<String, Any>>("eventAttributes").let { attributes ->
      eventRequest.attributes = attributes
    }

    EMMA.getInstance().trackEvent(eventRequest)
    result.success(null)
  }

  private fun trackExtraUserInfo(@NonNull call: MethodCall, @NonNull result: Result) {
    val userAttributes = call.argument<Map<String, String>>("extraUserInfo")
            ?: return returnError(result, call.method, "extraUserInfo")
    EMMA.getInstance().trackExtraUserInfo(userAttributes)
    result.success(null)
  }

  private fun loginUser(@NonNull call: MethodCall, @NonNull result: Result) {
    val userId = call.argument<String>("userId")
            ?: return returnError(result, call.method, "userId")
    val email = call.argument<String>("email") ?: ""
    EMMA.getInstance().loginUser(userId, email)
    result.success(null)
  }

  private fun registerUser(@NonNull call: MethodCall, @NonNull result: Result) {
    val userId = call.argument<String>("userId")
            ?: return returnError(result, call.method, "userId")
    val email = call.argument<String>("email") ?: ""
    EMMA.getInstance().registerUser(userId, email)
    result.success(null)
  }

  private fun inappMessage(@NonNull call: MethodCall, @NonNull result: Result) {
    val inAppRequestType = call.argument<String>("inAppType")
            ?: return returnError(result, call.method, "inAppType")

    val inappType = getInAppRequestTypeFromString(inAppRequestType)
    if (null == inappType) {
      EMMALog.w("Invalid inapp type $inAppRequestType. Skip request.")
      result.success(null)
      return
    }

    if (EMMACampaign.Type.NATIVEAD == inappType) {
      inappMessageNativeAd(call, result)
    } else {
      val request = EMMAInAppRequest(inappType)
      EMMA.getInstance().getInAppMessage(request)
      result.success(null)
    }
  }

  private fun inappMessageNativeAd(@NonNull call: MethodCall, @NonNull result: Result) {
    val request = EMMANativeAdRequest()
    request.templateId = call.argument<String>("templateId")?:
            return returnError(result, call.method, "templateId")
    request.isBatch = call.argument<Boolean>("batch")
            ?: false

    val listener: EMMAInAppMessageInterface
    if (request.isBatch) {
      listener = object : EMMABatchNativeAdInterface {
        override fun onShown(campaign: EMMACampaign) {
          // Not implemented
        }

        override fun onHide(campaign: EMMACampaign) {
          // Not implemented
        }

        override fun onClose(campaign: EMMACampaign) {
          // Not implemented
        }

        override fun onBatchReceived(nativeAds: List<EMMANativeAd>) {
          onReceiveNativeAds(nativeAds)
        }
      }
    } else {
      listener = object : EMMANativeAdInterface {
        override fun onShown(campaign: EMMACampaign) {
          // Not implemented
        }

        override fun onHide(campaign: EMMACampaign) {
          // Not implemented
        }

        override fun onClose(campaign: EMMACampaign) {
          // Not implemented
        }

        override fun onReceived(nativeAd: EMMANativeAd) {
          onReceiveNativeAds(listOf(nativeAd))
        }
      }
    }

    EMMA.getInstance().getInAppMessage(request, listener)
    result.success(null)
  }

  private fun onReceiveNativeAds(nativeAds: List<EMMANativeAd>) {
    val convertedNativeAds = convertNativeAdsToMap(nativeAds)
    Utils.executeOnMainThread(channel, "Emma#onReceiveNativeAds", convertedNativeAds)
  }

  private fun startPushSystem(@NonNull call: MethodCall, @NonNull result: Result) {
    val notificationIcon = call.argument<String>("notificationIcon")
            ?: return returnError(result, call.method, "notificationIcon")
    val pushIcon = Utils.getNotificationIcon(applicationContext, notificationIcon)

    val defaultChannel  = Utils.getAppName(applicationContext) ?: "EMMA"

    val channelName = call.argument<String>("notificationChannel") ?: defaultChannel
    val notificationChannelId = call.argument<String>("notificationChannelId")

    if (pushIcon == 0) {
      return returnError(result, call.method, "pushIcon")
    }

    val pushOpt = EMMAPushOptions.Builder(activity::class.java, pushIcon)
            .setNotificationChannelName(channelName)

    if (null == notificationChannelId) {
      pushOpt.setNotificationChannelId(notificationChannelId)
    }

    EMMA.getInstance().startPushSystem(pushOpt.build())
    result.success(null)
  }

  private fun convertNativeAdsToMap(@NonNull nativeAds: List<EMMANativeAd>): ArrayList<Map<String, Any>> {
    val mapNativeAds = arrayListOf<Map<String, Any>>()
    for (nativeAd in nativeAds) {
      val nativeAdMap = EmmaSerializer.nativeAdToMap(nativeAd)
      nativeAdMap?.let {
        mapNativeAds.add(nativeAdMap)
      }
    }
    return mapNativeAds
  }
}
