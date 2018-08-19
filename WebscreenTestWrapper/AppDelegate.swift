import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
  @IBOutlet weak var window: NSWindow!
  var previousSize: NSSize?

  var screenSaverView: WebscreenView?

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
  
    if let contentView = window.contentView {
      let defaults = UserDefaults.standard
      let screenSaverView = WebscreenView.init(
        frame: contentView.bounds,
        isPreview: false,
        withDefaults: defaults)!
      self.screenSaverView = screenSaverView
    
      contentView.addSubview(screenSaverView)
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
    if let screenSaverView = self.screenSaverView {
      screenSaverView.stopAnimation()
    }
  }
  
  @IBAction func handlePreferencesMenuItem(_ sender: Any) {
    if let window = self.window, let screenSaverView = self.screenSaverView {
      window.beginSheet(screenSaverView.configureSheet!, completionHandler: nil)
    }
  }
}

