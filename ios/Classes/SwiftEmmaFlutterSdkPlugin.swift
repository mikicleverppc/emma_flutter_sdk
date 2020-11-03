import Flutter
import UIKit
import EMMA_iOS

extension FlutterAppDelegate : EMMAPushDelegate {
    public func onPushOpen(_ push: EMMAPush) {
        let _ = push.params
        // treat params
    }
    
    @objc
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound])
    }
    
    @objc
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}

/** This implementation replaces push methods on AppDelegate  */
class EMMAFlutterPushDelegate {

    let appDelegate = UIApplication.shared.delegate
    
    init() {
        
    }
    
    @objc
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        EMMA.registerToken(deviceToken)
        if appDelegate != nil && appDelegate!.responds(to: #selector(UIApplicationDelegate.application(_:didRegisterForRemoteNotificationsWithDeviceToken:))) {
            appDelegate?.application?(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        }
    }
    
    @objc
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        EMMA.handlePush(userInfo)
    }
    
    @objc
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    @objc
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NSLog("Error registering notifications " + error.localizedDescription);
    }
    
    @objc
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        EMMA.handlePush(notification.request.content.userInfo)
        completionHandler([.badge, .sound])
    }
    
    @objc
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        EMMA.handlePush(response.notification.request.content.userInfo)
        completionHandler()
    }
    
    @available(iOS 10.0, *)
    public func swizzlePushMethods() {
        let appDelegate = UIApplication.shared.delegate
        let appDelegateClass: AnyClass? = object_getClass(appDelegate)
        
        var swizzles = Array<(Selector, Selector)>()
        
        swizzles.append((#selector(FlutterAppDelegate.application(_:didRegisterForRemoteNotificationsWithDeviceToken:)),
                         #selector(EMMAFlutterPushDelegate.self.application(_:didRegisterForRemoteNotificationsWithDeviceToken:))))
        
        swizzles.append((#selector(FlutterAppDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)),
                         #selector(EMMAFlutterPushDelegate.self.application(_:didReceiveRemoteNotification:fetchCompletionHandler:))))
        
        swizzles.append((#selector(FlutterAppDelegate.application(_:didRegister:)),
                         #selector(EMMAFlutterPushDelegate.self.application(_:didRegister:))))
        
        swizzles.append((#selector(FlutterAppDelegate.application(_:didFailToRegisterForRemoteNotificationsWithError:)),
                         #selector(EMMAFlutterPushDelegate.self.application(_:didFailToRegisterForRemoteNotificationsWithError:))))
        
        swizzles.append((#selector(FlutterAppDelegate.userNotificationCenter(_:willPresent:withCompletionHandler:)),
                         #selector(EMMAFlutterPushDelegate.self.userNotificationCenter(_:willPresent:withCompletionHandler:))))
        
        swizzles.append((#selector(FlutterAppDelegate.userNotificationCenter(_:didReceive:withCompletionHandler:)),
                         #selector(EMMAFlutterPushDelegate.self.userNotificationCenter(_:didReceive:withCompletionHandler:))))
        
        for s in swizzles {
            
            let originalSelector = s.0
            let swizzledSelector = s.1
            
            guard let swizzledMethod = class_getInstanceMethod(EMMAFlutterPushDelegate.self, swizzledSelector) else {
                return
            }

            if let originalMethod = class_getInstanceMethod(appDelegateClass, originalSelector)  {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            } else {
                class_addMethod(appDelegateClass, swizzledSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            }
        }

        
    }
    
}

extension UIApplicationDelegate {
    // MARK: - EMMA Push Delegate
    

}

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
        result(nil)
        break
    case "loginUser":
        guard let args = call.arguments as? Dictionary<String, AnyObject> else {
            result(FlutterError.init(code: "BAD_ARGS",
                                    message: "Can't find args",
                                    details: nil))
            return
        }
        
        guard let userId = args["userId"] as? String else {
            result(FlutterError.init(code: "BAD_ARGS",
                                    message: "Can't get userId",
                                    details: nil))
            return
        }
        
        let email = args["email"] as? String ?? ""
        
        EMMA.loginUser(userId, forMail: email)
        result(nil)
        break
    case "registerUser":
        guard let args = call.arguments as? Dictionary<String, AnyObject> else {
            result(FlutterError.init(code: "BAD_ARGS",
                                    message: "Can't find args",
                                    details: nil))
            return
        }
        
        guard let userId = args["userId"] as? String else {
            result(FlutterError.init(code: "BAD_ARGS",
                                    message: "Can't get userId",
                                    details: nil))
            return
        }
        
        let email = args["email"] as? String ?? ""
        
        EMMA.registerUser(userId, forMail: email)
        result(nil)
        break
    case "inAppMessage":
        
        guard let args = call.arguments as? Dictionary<String, AnyObject> else {
            result(FlutterError.init(code: "BAD_ARGS",
                                    message: "Can't find args",
                                    details: nil))
            return
        }
        
        guard let inAppType = args["inAppType"] as? String else {
            result(FlutterError.init(code: "BAD_ARGS",
                                    message: "Can't get inAppType",
                                    details: nil))
            return
        }
        
        guard let requestType = getInAppTypeFromString(inAppType: inAppType) else {
            result(FlutterError.init(code: "BAD_INAPP_TYPE",
                                    message: "Unknown inapp type",
                                    details: nil))
            return
        }
        
        let request = EMMAInAppRequest(type: requestType)
        EMMA.inAppMessage(request)
        result(nil)
        break
    case "startPushSystem":
        EMMA.startPushSystem()
        
        if let applicationDelegate = UIApplication.shared.delegate as? FlutterAppDelegate {
            let pushDelegate = EMMAFlutterPushDelegate()
            if #available(iOS 10.0, *) {
                pushDelegate.swizzlePushMethods()
            }
            EMMA.setPushSystemDelegate(applicationDelegate)
        }
        result(nil)
        break
      default:
        result(FlutterMethodNotImplemented)
      break
    }
  }
    
    func getInAppTypeFromString(inAppType: String) -> InAppType? {
        switch inAppType {
        case "startview":
            return .Startview
        default:
            return nil
        }
    }
}
