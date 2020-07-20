import UIKit
import Flutter
import UserNotifications
import OktaStorage

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    let notificationCenter = UNUserNotificationCenter.current()
    
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
    let options: UNAuthorizationOptions = [.alert, .sound, .badge]
    notificationCenter.requestAuthorization(options: options) {
        (didAllow, error) in
        if !didAllow {
            print("User has declined notifications")
        }
    }
    UIApplication.shared.applicationIconBadgeNumber = 0
    if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    } else {
        /// Fallback on earlier versions
    }
    UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60*15))
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "eu.araulin.devinci/channel",
                                              binaryMessenger: controller.binaryMessenger)
    channel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        print(call.method);
        if call.method == "changeIcon1" {
            self.changeIcon1(result: result)
            return
        }
        else if call.method == "changeIcon2" {
            self.changeIcon2(result: result)
        }else if call.method == "changeIcon3" {
            self.changeIcon3(result: result)
        }else if call.method == "changeIcon4" {
            self.changeIcon4(result: result)
        }else if call.method == "s" {
            self.sendNotification(result: result)
        }
        else {
        result(FlutterMethodNotImplemented)
        return
      }
      
    })

    GeneratedPluginRegistrant.register(with: self)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    struct UpdateJson: Decodable {
        let last: String
    }
    
    struct NotificationJson: Decodable {
        let id: String
        let title: String
        let content: String
    }
    
    override func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
            // Create url which from we will get fresh data
        let oktaStorage = OktaSecureStorage()
        
        print("Background Fetch Running");
        
            if let url = URL(string: "https://photo.antoineraulin.com/devinci/n.json") {
                // Send request
                URLSession.shared.dataTask(with: url, completionHandler: { (data, respone, error) in
                    // Check Data
                    guard let `data` = data else { completionHandler(.failed); return }
                    // Get result from data
                    let result = String(data: data, encoding: .utf8)
                    // Parse json
                    let notificationJson: NotificationJson = try! JSONDecoder().decode(NotificationJson.self, from: (result?.data(using: .utf8)!)!)
                    print("got notification id : "+notificationJson.id)
                    var show = false
                    do {
                        let nid = try oktaStorage.get(key:"nid")
                        if nid != notificationJson.id {
                            show = true
                            do {
                                
                            
                            try oktaStorage.set(notificationJson.id, forKey: "nid")
                            }catch let error2 {
                                print(error2)
                                completionHandler(.failed); return
                            }
                        }
                    } catch let error {
                        // Handle error
                        print(error)
                        show = true
                        do {
                            
                        
                        try oktaStorage.set(notificationJson.id, forKey: "nid")
                        }catch let error2 {
                            print(error2)
                            completionHandler(.failed); return
                        }
                        
                    }
                    if show {
                        let content = UNMutableNotificationContent()
                        content.title = notificationJson.title
                        content.body = notificationJson.content
                        content.sound = UNNotificationSound.default
                        content.badge = 1
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
                        let identifier = "notification"
                        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

                        self.notificationCenter.add(request) { (error) in
                            if let error = error {
                                print("Error \(error.localizedDescription)")
                                completionHandler(.failed); return
                            }
                        }
                    }
                    
                    completionHandler(.newData)
                    
                    // Call background fetch completion with .newData result
                    
                }).resume()
            }
        
        
        
        
        }
    
    private func changeIcon1(result: FlutterResult){
        if #available(iOS 10.3, *) {
            if UIApplication.shared.supportsAlternateIcons {
                    UIApplication.shared.setAlternateIconName("iconwhitea"){ error in
                        if let error = error {
                            print(error.localizedDescription)
                            print("hello")
                        } else {
                            print("Done!")
                        }
                    }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func sendNotification(result: FlutterResult){
        print("hello 1");
        let content = UNMutableNotificationContent()
        
        content.title = "Test"
        content.body = "Hello World"
        content.sound = UNNotificationSound.default
        content.badge = 1
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let identifier = "Local Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
    
    private func changeIcon2(result: FlutterResult){
        if #available(iOS 10.3, *) {
            if UIApplication.shared.supportsAlternateIcons {
                    UIApplication.shared.setAlternateIconName("iconblacka"){ error in
                        if let error = error {
                            print(error.localizedDescription)
                            print("hello")
                        } else {
                            print("Done!")
                        }
                    }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func changeIcon3(result: FlutterResult){
        if #available(iOS 10.3, *) {
            if UIApplication.shared.supportsAlternateIcons {
                    UIApplication.shared.setAlternateIconName("iconwhiteb"){ error in
                        if let error = error {
                            print(error.localizedDescription)
                            print("hello")
                        } else {
                            print("Done!")
                        }
                    }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func changeIcon4(result: FlutterResult){
        if #available(iOS 10.3, *) {
            if UIApplication.shared.supportsAlternateIcons {
                    UIApplication.shared.setAlternateIconName("iconblackb"){ error in
                        if let error = error {
                            print(error.localizedDescription)
                            print("hello")
                        } else {
                            print("Done!")
                        }
                    }
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
