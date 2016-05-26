//
//  AppDelegate.swift
//  FollowButton
//
//  Created by Louis Tur on 5/26/16.
//  Copyright © 2016 cat.thoughts. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
    let profileViewController: ProfileViewController = ProfileViewController()
    self.window?.rootViewController = profileViewController
    
    self.window?.makeKeyAndVisible()
    
    return true
  }

  func applicationWillResignActive(application: UIApplication) {
  }

  func applicationDidEnterBackground(application: UIApplication) {
  }

  func applicationWillEnterForeground(application: UIApplication) {
  }

  func applicationDidBecomeActive(application: UIApplication) {
  }

  func applicationWillTerminate(application: UIApplication) {
  }


}

