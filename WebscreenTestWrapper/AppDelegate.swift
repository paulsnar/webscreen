//
//  AppDelegate.swift
//  WebscreenTestWrapper
//
//  Created by paulsnar on 2018-08-18.
//  Copyright © 2018 paulsnar. All rights reserved.
//

import Cocoa
//import Webscreen

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    @IBOutlet weak var window: NSWindow!

    lazy var screenSaverView = WebscreenView(frame: NSZeroRect, isPreview: false)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window.delegate = self
        
        if let screenSaverView = self.screenSaverView {
            screenSaverView.frame = window.contentView!.bounds
            window.contentView!.addSubview(screenSaverView)
            screenSaverView.startAnimation()
        }
    }
    
    func windowDidResize(_ notification: Notification) {
        if let screenSaverView = self.screenSaverView {
            screenSaverView.handleResize(bounds: window.contentView!.bounds)
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // TODO
    }
}

