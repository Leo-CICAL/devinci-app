import UIKit
import Flutter
import UserNotifications
import WidgetKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    let notificationCenter = UNUserNotificationCenter.current()
    
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        WidgetCenter.shared.reloadAllTimelines()
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "eu.araulin.devinci/channel",
                                           binaryMessenger: controller.binaryMessenger)
        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            print(call.method);
            switch call.method {
            case "changeIcon":
                let iconId = call.arguments as! Int
                self.changeIcon(iconId:iconId, result: result)
                return
            case "showDialog":
                let dic = call.arguments as! Dictionary<String, String>
                self.showDialog(result:result, dic:dic)
                return
            default:
                result(FlutterMethodNotImplemented)
                return
            }
            
        })
        
        GeneratedPluginRegistrant.register(with: self)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func changeIcon(iconId: Intresult: @escaping FlutterResult,){
        if UIApplication.shared.supportsAlternateIcons {
                var iconName = "iconwhitea"
                switch iconId {
                    case 1:
                        iconName = "iconblacka"
                    case 2: 
                        iconName = "iconwhiteb"
                    case 3: 
                        iconName = "iconblackb"
                    default:
                        iconName = "iconwhitea"
                }
                UIApplication.shared.setAlternateIconName(iconName){ error in
                    if let error = error {
                        print(error.localizedDescription)
                        result(FlutterError(code: "ERROR",
                        message: error.localizedDescription,
                        details: nil))
                    } else {
                        result(true)
                    }
                }
            }
    }

    private func showDialog(result: @escaping FlutterResult, dic: Dictionary<String, String>){
        
        let alert = UIAlertController(title: dic["title"], message: dic["content"], preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: dic["ok"], style: .default, handler: { action in
    result(true)
}))
        alert.addAction(UIAlertAction(title: dic["cancel"], style: .cancel, handler: { action in
    result(false)
}))

        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
        
    }
}
