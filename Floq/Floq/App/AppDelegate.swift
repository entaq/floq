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
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var mainEngine:CliqEngine!
    var appUser:FLUser?
    var isSyncng = false
    var isWatching = false
    
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
        watchForUpdateChanges()
        //let sub = CMTSubscription()
        //sub.fetchALl()
        return true
        
    }
    
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        print("Memory Warning, Release resources")
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        isSyncng = false
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if let _ = UserDefaults.standard.string(forKey: Fields.uid.rawValue){
            //mainEngine.start()
            selfSync()
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        SDImageCache.shared.clearMemory()
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
            selfSync()
            mainEngine = CliqEngine()
            let home = UINavigationController(rootViewController: HomeVC())
            window?.rootViewController = home
            watchForUpdateChanges()
            
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
                        if UserDefaults.instanceToken != ""{return}
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
                /*DispatchQueue.main.async {
                    let alert = UIAlertController.createDefaultAlert("OOPS 😳😳😳!!", "Looks like you refused permissions to receive notifications for Floq. Please enable notifications to fully enjoy Floq!. You can always change these in settings",.alert, "OK",.default, nil)
                    alert.addAction(UIAlertAction(title: "Settings", style: .default){_ in UIApplication.openSettings()})
                    self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                }*/
                
            }
        }
       app.registerForRemoteNotifications()
    }
}



extension AppDelegate:UNUserNotificationCenterDelegate, MessagingDelegate{
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //let info = notification.request.content.userInfo
        let id = notification.request.content.userInfo[Fields.cliqID.rawValue] as? String ?? ""
        let title = notification.request.content.title
        let body = notification.request.content.body
        saveNotif(notification)
        showInAppAlert(title: title, body: body, id: id)
        
        completionHandler(.sound)
    }
    
    func saveNotif(_ notification:UNNotification){
        let info = notification.request.content.userInfo
        
        if let type = info["type"] as? String, let cliq = info[Fields.cliqID.rawValue] as? String, let photo = info[Fields.photoID.rawValue] as? String{
            let notifier = PhotoNotification()
            notifier.saveNotification(id: photo, cliq: cliq)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        saveNotif(response.notification)
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
        if prevTok != fcmToken || !UserDefaults.updatedtoken{
            DataService.main.saveNewUserInstanceToken(token: fcmToken) { (success, err) in
                if success{
                    UserDefaults.set(fcmToken, for: .instanceToken)
                    UserDefaults.set(true, for: .updatedtoken)
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


// MARK:- Update Changes

extension AppDelegate{
    
    func watchForUpdateChanges(){
        
        DataService.main.listenForUpdates { (update, err) in
            guard let update = update as? UpdateInfo else {return}
            if update.islessThanLeastSupport(){
                guard let vc = UIStoryboard.main.instantiateViewController(withIdentifier: ForceUpdateVC.identifier) as? ForceUpdateVC else{return}
                vc.info = update.forcedInfo
                vc.url = update.appUrl
                self.window?.rootViewController = vc
                DispatchQueue.main.async {
                     self.window?.makeKeyAndVisible()
                }
            }else{
                if update.notifyUpdate{
                    let alert = UIAlertController.createDefaultAlert("Update",update.updateInfo,.alert, "Cancel",.cancel, {_ in UserDefaults.standard.setValue(Date().timeIntervalSinceReferenceDate, forKey: Fields.lastChecked.rawValue)})
                    let action = UIAlertAction(title: "Update", style: .default, handler: { (action) in
                        UserDefaults.standard.setValue(Date().timeIntervalSinceReferenceDate, forKey: Fields.lastChecked.rawValue)
                        openAppStore(url:update.appUrl)
                    })
                    alert.addAction(action)
                    DispatchQueue.main.async {
                        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        
        isWatching = true
    }
    
    func selfSync(){
        if isSyncng{return}
        DataService.main.synchronizeSelf { (user, err) in
            guard let user = user as? FLUser else{return}
            self.appUser = user
            self.isSyncng = false
        }
        isSyncng = true
    }
    
}




extension AppDelegate{
    
    func showInAppAlert(title:String, body:String, id:String){
        let width = UIScreen.main.bounds.width
        let frame = CGRect(x: -width, y: 0, width: width, height: 90)
        let alert = NotificationAlertView(frame: frame)
        alert.subtitlelabel.text = body
        alert.titleLabel.text = title
        alert.method = { _ in
            if id == ""{return}
            if let nav = self.window?.rootViewController as? UINavigationController{
                
                DispatchQueue.main.async{
                    nav.pushViewController(PhotosVC(cliq: nil, id: id), animated: true)
                }
            }
        }
        DispatchQueue.main.async{ [weak self] in
            self?.window?.rootViewController?.view.addSubview(alert)
        }
    }

    
}







func openAppStore(url:URL?){
    guard let url = url else {return}
    if UIApplication.shared.canOpenURL(url){
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
