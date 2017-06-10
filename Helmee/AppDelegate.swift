    //
//  AppDelegate.swift
//  Helmee
//
//  Created by Antoine Payan on 10/06/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var user: User = User.verifyUserArchived()
    private var timer: Timer?
    private let factory = Factory()
    private var retries = 0

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        UserDefaults.standard.set(nil, forKey: "errorMessage")
        UserDefaults.standard.synchronize()
        var homeViewController: UIViewController
        if user.id == 0 {
            homeViewController = HomeViewController(factory: factory)
        } else {
            homeViewController = TabBarViewController(factory: factory)
        }
        window?.backgroundColor = .clear
        window?.set(rootViewController: homeViewController)
        window?.makeKeyAndVisible()
        return true
    }
    
    func launchTimerConnection() {
        user = User.verifyUserArchived()
        guard user.id != 0 else {
            return
        }
        timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(verifyConnection), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        launchTimerConnection()
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    func verifyConnection() {
        LoginRepositoryImplementation.checkConnection(user: user, callback: { result in
            switch result {
            case .value(_):
                UserDefaults.standard.set(nil, forKey: "errorMessage")
                UserDefaults.standard.synchronize()
                self.retries = 0
                break
            case .error(_):
                guard self.user.id != 0 else {
                    self.retries = 0
                    return
                }
                if self.retries > 5 {
                    self.user.id = 0
                    let data = NSKeyedArchiver.archivedData(withRootObject: self.user)
                    UserDefaults.standard.set(data, forKey: "user")
                    UserDefaults.standard.set("Vous avez été déconnecté", forKey: "errorMessage")
                    UserDefaults.standard.synchronize()
                    DispatchQueue.main.async {
                        if let transitionViewClass = NSClassFromString("UITransitionView") {
                            for subview in (self.window?.subviews)! where subview.isKind(of: transitionViewClass) {
                                subview.removeFromSuperview()
                            }
                        }
                        self.window?.rootViewController = HomeViewController(factory: self.factory)
                        self.stopTimer()
                    }
                }
                self.retries += 1
                break
            }
            
        })
    }
    
}

