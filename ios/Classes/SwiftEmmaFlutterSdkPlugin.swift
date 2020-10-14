import Flutter
import UIKit
import EMMA_iOS

public class SwiftEmmaFlutterSdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "emma_flutter_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftEmmaFlutterSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "getEMMAVersion":
        result(EMMA.getSDKVersion())
        break
      case "startSession":
        guard let args = call.arguments as? Dictionary<String, AnyObject> else {
            result(FlutterError.init(code: "BAD_ARGS",
                                    message: "Can't find args",
                                    details: nil))
            return
        }
        
        guard let sessionKey = args["sessionKey"] as? String else {
            result(FlutterError.init(code: "BAD_ARGS",
                                    message: "Can't find Session Key",
                                    details: nil))
            return
        }
        
        guard let debugEnabled = args["debugEnabled"] as? Bool else {
            result(FlutterError.init(code: "BAD_ARGS",
                                    message: "Debug Enabled is not boolean",
                                    details: nil))
            return
        }
        
        let configuration = EMMAConfiguration()
        configuration.debugEnabled = debugEnabled
        configuration.sessionKey = sessionKey
        EMMA.startSession(with: configuration)
        
        result(nil)
      break
    case "trackEvent":
        guard let args = call.arguments as? Dictionary<String, AnyObject> else {
            result(FlutterError.init(code: "BAD_ARGS",
                                    message: "Can't find args",
                                    details: nil))
            return
        }
        
        guard let eventToken = args["eventToken"] as? String else {
            result(FlutterError.init(code: "BAD_ARGS",
                                    message: "Can't find Event Token",
                                    details: nil))
            return
        }
        
        let eventRequest = EMMAEventRequest(token: eventToken)
        if let eventAttributes = args["eventAttributes"] as? Dictionary<String, AnyObject>  {
            eventRequest?.attributes = eventAttributes
        }
        EMMA.trackEvent(eventRequest)
        result(nil)
        break
    case "trackExtraUserInfo":
        guard let args = call.arguments as? Dictionary<String, AnyObject> else {
            result(FlutterError.init(code: "BAD_ARGS",
                                    message: "Can't find args",
                                    details: nil))
            return
        }
        guard let userAttributes = args["extraUserInfo"] as? Dictionary<String, String> else {
            result(FlutterError.init(code: "BAD_ARGS",
                                    message: "Can't user arguments",
                                    details: nil))
            return
        }
        EMMA.trackExtraUserInfo(userAttributes)
        break
      default:
        result(FlutterMethodNotImplemented)
      break
    }
  }
}
