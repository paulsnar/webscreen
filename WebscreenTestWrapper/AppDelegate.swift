//
//  AppDelegate.swift
//  WebscreenTestWrapper
//
//  Created by paulsnar on 2018-08-18.
//  Copyright © 2018 paulsnar. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    @IBOutlet weak var window: NSWindow!
    var previousSize: NSSize?

    lazy var screenSaverView = WebscreenView(frame: NSZeroRect, isPreview: false)

    func applicationWillFinishLaunching(_ notification: Notification) {
        window.minSize = NSSize(width: 1024, height: 768)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window.delegate = self

        let frame = window.frame
        if frame.size.width < 1024 || frame.size.height < 768 {
            let target = NSRect.init(x: frame.origin.x, y: frame.origin.y,
                width: 1024, height: 768)
            window.setFrame(target, display: true, animate: true)
        }
        
        if let screenSaverView = self.screenSaverView {
            screenSaverView.frame = window.contentView!.bounds
            window.contentView!.addSubview(screenSaverView)
            screenSaverView.startAnimation()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func windowWillResize(_ sender: NSWindow, to: NSSize) -> NSSize {
        self.previousSize = window.frame.size
        return to
    }
    
    func windowDidResize(_ notification: Notification) {
        if let previousSize = self.previousSize {
            if let screenSaverView = self.screenSaverView {
                screenSaverView.resizeSubviews(previousSize)
            }
            self.previousSize = nil
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // TODO
    }
}

