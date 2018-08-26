import Foundation
import ScreenSaver
import WebKit

let WebscreenModuleName = "lv.paulsnar.Webscreen"

class WebscreenView: ScreenSaverView, WKNavigationDelegate, ConfigurationPanelDelegate {
  var webView: WKWebView
  var config: Configuration
  var configPanel: ConfigurationPanel?

  var configDirty = false

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
    let wkConfig = WKWebViewConfiguration()
    wkConfig.suppressesIncrementalRendering = false
    //wkConfig.allowsInlineMediaPlayback = false // not available on Mac?
    wkConfig.mediaTypesRequiringUserActionForPlayback = .all
    self.webView = WKWebView(frame: .zero, configuration: wkConfig)
    self.config = Configuration.init(fromDefaults: defaults)
    super.init(frame: frame, isPreview: isPreview)
  
    self.wantsLayer = true
    self.autoresizingMask = [.width, .height]
    self.autoresizesSubviews = true
    self.webView.navigationDelegate = self
  }

  override func draw(_ rect: NSRect) {
    super.draw(rect)
    NSColor.black.setFill()
    rect.fill()
  }

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    if self.webView.alphaValue < 1.0 {
      let anim = webView.animator()
      anim.alphaValue = 1.0
    }
  }

  override func startAnimation() {
    super.startAnimation()
    self.layer?.backgroundColor = .black

    self.loadURL(self.config.url)

    if self.isPreview {
      // do a hack to scale the view to half of its actual size
      let intermediate = NSView.init(frame: self.frame)
      intermediate.bounds = self.frame.applying(
        CGAffineTransform.init(scaleX: 2, y: 2))
      intermediate.addSubview(self.webView)
      self.webView.frame = intermediate.bounds
      self.addSubview(intermediate)
    } else {
      self.webView.frame = self.frame
      self.addSubview(self.webView)
    }

    self.webView.alphaValue = 0.0
  }

  func resizeSubviews(_ oldSize: NSSize) {
    var bounds = self.frame
    if self.isPreview {
      bounds = bounds.applying(
        CGAffineTransform.init(scaleX: 2, y: 2))
    }
    self.webView.frame = bounds
  }

  func configurationPanel(_: ConfigurationPanel, didChangeURLTo url: URL, from: URL?) {
    self.config.url = url
    self.loadURL(url)
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

  func loadURL(_ url: URL) {
    self.webView.animator().alphaValue = 0.0

    let url = self.config.url
    let rq = URLRequest(
      url: url,
      cachePolicy: .reloadRevalidatingCacheData,
      timeoutInterval: TimeInterval.init(exactly: 5)!)
    self.webView.load(rq)
  }
}
