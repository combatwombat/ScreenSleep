//
//  AppDelegate.swift
//  ScreenSleep
//
//  Created by Robert Gerlach on 23.06.19.
//  Copyright © 2019 Robert Gerlach. All rights reserved.
//
// thx to https://www.raywenderlich.com/450-menus-and-popovers-in-menu-bar-apps-for-macos

import Cocoa
import ServiceManagement

extension Notification.Name {
    static let killLauncher = Notification.Name("killLauncher")
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Register launcher, kill it on main app launch
        let launcherAppId   = "com.robertgerlach.ScreenSleepLauncher"
        let runningApps     = NSWorkspace.shared.runningApplications
        let isRunning       = !runningApps.filter { $0.bundleIdentifier == launcherAppId }.isEmpty
        
        SMLoginItemSetEnabled(launcherAppId as CFString, true)
        
        if isRunning {
            DistributedNotificationCenter.default().post(
                name: .killLauncher,
                object: Bundle.main.bundleIdentifier
            )
        }
        
        
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
            button.action = #selector(onMenuButtonPressed(_:))
        } else {
            print("Can't create status bar item. Try removing some items to make room")
            NSApp.terminate(nil)
            return
        }
        constructMenu()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func constructMenu() {
        let menu = NSMenu()
        menu.addItem(
            NSMenuItem(
                title: NSLocalizedString("Sleep Screen", comment: ""),
                action: #selector(sleepScreen),
                keyEquivalent: ""
            )
        )
        menu.addItem(NSMenuItem.separator())
        menu.addItem(
            NSMenuItem(
                title: NSLocalizedString("Quit", comment: ""),
                action: #selector(NSApplication.terminate(_:)),
                keyEquivalent: ""
            )
        )
        statusItem.menu = menu
    }
    
    @objc func sleepScreen(_ sender: Any?) {
        shell("pmset", "displaysleepnow")
    }
    
    @objc func onMenuButtonPressed(_ sender: Any?) {
        print("Menu button pressed")
    }
    
    
    // Execute shell command
    @discardableResult
    func shell(_ args: String...) -> Int32 {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
    }
    
}
