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
        
        result("")
      break
      default:
        result(FlutterMethodNotImplemented)
      break
    }
  }
}
