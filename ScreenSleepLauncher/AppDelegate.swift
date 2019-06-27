//
//  AppDelegate.swift
//  ScreenSleepLauncher
//
//  Created by Robert Gerlach on 24.06.19.
//  Copyright © 2019 Robert Gerlach. All rights reserved.
//
// thx to https://theswiftdev.com/2017/10/27/how-to-launch-a-macos-app-at-login/
// and https://blog.timschroeder.net/2012/07/03/the-launch-at-login-sandbox-project/

import Cocoa

extension Notification.Name {
    static let killLauncher = Notification.Name("killLauncher")
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  
    
    @objc func terminate() {
        NSApp.terminate(nil)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        let mainAppIdentifier   = "com.robertgerlach.ScreenSleep"
        let runningApps         = NSWorkspace.shared.runningApplications
        let isRunning           = !runningApps.filter { $0.bundleIdentifier == mainAppIdentifier }.isEmpty
        
        if !isRunning {
            DistributedNotificationCenter.default().addObserver(
                self,
                selector: #selector(self.terminate),
                name: .killLauncher,
                object: mainAppIdentifier
            )
            
            let path = Bundle.main.bundlePath as NSString
            var components = path.pathComponents
            components.removeLast()
            components.removeLast()
            components.removeLast()
            components.append("MacOS")
            components.append("ScreenSleep")
            
            let newPath = NSString.path(withComponents: components)
            
            NSWorkspace.shared.launchApplication(newPath)
            
        } else {
            self.terminate()
        }
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

