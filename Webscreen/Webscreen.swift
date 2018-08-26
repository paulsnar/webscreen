import Foundation
import ScreenSaver
import WebKit

let WebscreenModuleName = "lv.paulsnar.Webscreen"

class WebscreenView: ScreenSaverView, WKNavigationDelegate, ConfigurationPanelDelegate {
  var intermediate: NSView?
  var webView: WKWebView
  var config: Configuration
  var configPanel: ConfigurationPanel?

  var configDirty = false
  var animationStarted = false

  override var hasConfigureSheet: Bool { get { return true } }
  override var configureSheet: NSWindow? {
    get {
      if self.configPanel == nil {
        self.configPanel = ConfigurationPanel.init(fromURL: self.config.url)
      }

      let configPanel = self.configPanel!
      configPanel.delegate = self
      if !configPanel.isWindowLoaded {
        configPanel.loadWindow()
      }
      return configPanel.window
    }
  }

  override convenience init?(frame: NSRect, isPreview: Bool) {
    let defaults = ScreenSaverDefaults.init(
      forModuleWithName: WebscreenModuleName)!
    self.init(frame: frame, isPreview: isPreview, withDefaults: defaults)
  }

  required init?(coder decoder: NSCoder) {
    fatalError("init(coder:) not implemented")
  }

  init?(frame: NSRect, isPreview: Bool, withDefaults defaults: UserDefaults) {
    self.config = Configuration.init(fromDefaults: defaults)

    let wkConfig = WKWebViewConfiguration()
    wkConfig.suppressesIncrementalRendering = false
    //wkConfig.allowsInlineMediaPlayback = false // not available on Mac?
    wkConfig.mediaTypesRequiringUserActionForPlayback = .all
    self.webView = WKWebView(frame: .zero, configuration: wkConfig)

    super.init(frame: frame, isPreview: isPreview)

    self.wantsLayer = true
    self.autoresizingMask = [.width, .height]
    self.autoresizesSubviews = true
    self.webView.navigationDelegate = self

    if isPreview {
      let intermediate = NSView.init(frame: .zero)
      self.intermediate = intermediate
      intermediate.addSubview(self.webView)
      self.addSubview(intermediate)
    } else {
      self.addSubview(self.webView)
    }

    self.resizeSubviews(.zero)
  }

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    if self.webView.alphaValue < 1.0 {
      self.webView.animator().alphaValue = 1.0
    }
  }

  override func startAnimation() {
    super.startAnimation()
    if self.animationStarted {
      // This is a bit hacky, but this shall fix System Preferences restarting
      // animation upon basically every interaction imaginable, causing
      // unnecessary reloading of the webview.
      return
    }
    self.animationStarted = true

    self.layer?.backgroundColor = .black
    self.webView.alphaValue = 0.0
    self.loadCurrentURL()
  }

  func resizeSubviews(_ oldSize: NSSize) {
    let bounds = self.bounds
    var transform = CGAffineTransform.identity
    if self.isPreview {
      transform = transform.scaledBy(x: 2, y: 2)
    }
    let childBounds = bounds.applying(transform)

    if let intermediate = self.intermediate {
      intermediate.frame = bounds
      intermediate.bounds = childBounds
    }
    self.webView.frame = childBounds
  }

  func configurationPanel(_: ConfigurationPanel, didChangeURLTo url: URL, from: URL?) {
    self.config.url = url
    self.loadCurrentURL()
  }

  func configurationPanel(_ panel: ConfigurationPanel, didClose: Void) {
    if let sheetParent = panel.window!.sheetParent {
      sheetParent.endSheet(panel.window!)
    } else {
      // ScreenSaver is showing its age a bit at this point because this should
      // be done via window.sheetParent.endSheet(window) but the engine hasn't
      // been updated to show the sheet over the window instead of over the
      // application main window therefore we have to use the deprecated way :)
      NSApplication.shared.endSheet(panel.window!)
    }
  }

  func loadCurrentURL() {
    if self.webView.alphaValue > 0.0 {
      self.webView.animator().alphaValue = 0.0
    }

    let url = self.config.url
    let rq = URLRequest(
      url: url,
      cachePolicy: .reloadRevalidatingCacheData,
      timeoutInterval: TimeInterval.init(exactly: 5)!)
    self.webView.load(rq)
  }
}
