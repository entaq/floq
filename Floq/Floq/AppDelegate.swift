//
//  AppDelegate.swift
//  Floq
//
//  Created by Arun Nagarajan on 3/26/17.
//  Copyright © 2017 Arun Nagarajan. All rights reserved.
//

import Firebase
import FacebookCore
import SDWebImage
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var photoEngine:PhotoEngine!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        if (UserDefaults.standard.string(forKey: Fields.uid.rawValue) != nil){
            application.registerForRemoteNotifications()
        }
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.isTranslucent = false
        navigationBarAppearace.tintColor = .white
        navigationBarAppearace.barTintColor = .barTint
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        setRootViewController()
        return true
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        SDImageCache.shared().clearMemory()
    }
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return SDKApplicationDelegate.shared.application(app, open: url, options: options)
    }
    
   
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("This is the user info sent: \(userInfo.debugDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("This is the user info sent: \(userInfo.debugDescription)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("The tokjen data: \(deviceToken.debugDescription)")
    }
    
    
    
    func setRootViewController(){
        if let _  = UserDefaults.standard.string(forKey: Fields.uid.rawValue){
            photoEngine = PhotoEngine()
            let home = UINavigationController(rootViewController: HomeVC())
            window?.rootViewController = home
        }else{
            let onboard = UIStoryboard.main.instantiateViewController(withIdentifier: HomeOnBaordVC.identifier) as! HomeOnBaordVC
            window?.rootViewController = onboard
        }
    }
    
    func registerRemoteNotifs(app:UIApplication){
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (succes, err) in
            if succes{
                //Print succesfully
                InstanceID.instanceID().instanceID(handler: { (result, err) in
                    if let result = result{
                        DataService.main.saveNewUserInstanceToken(token: result.token, complete: { (success, err) in
                            if success{
                                UserDefaults.set(result.token, for: .instanceToken)
                            }else{
                                
                                Logger.log(err)
                            }
                        })
                    }
                })
            }else{
                Logger.log(err)
                DispatchQueue.main.async {
                    let alert = UIAlertController.createDefaultAlert("OOPS!!", "Looks like you refused permissions to receives notifications for floq. Please reconsider if you or you can always change these in settings",.alert, "OK",.default, nil)
                    self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                }
                
            }
        }
       app.registerForRemoteNotifications()
    }
}



extension AppDelegate:UNUserNotificationCenterDelegate, MessagingDelegate{
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Will Present tne ")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Will Present the response: \(response.notification.request.content.userInfo.description)")
        let id = response.notification.request.content.userInfo[Fields.cliqID.rawValue] as? String ?? ""
        if let nav = window?.rootViewController as? UINavigationController{
            if id == ""{return}
            nav.pushViewController(PhotosVC(cliq: nil, id: id), animated: true)
        }
        completionHandler()
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        let prevTok = UserDefaults.instanceToken
        if prevTok != fcmToken{
            DataService.main.saveNewUserInstanceToken(token: fcmToken) { (success, err) in
                if success{
                    UserDefaults.set(fcmToken, for: .instanceToken)
                }else{
                    Logger.log(err)
                }
            }
        }
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received this message: \(remoteMessage.appData.debugDescription)")
    }
}


