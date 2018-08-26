import Foundation
import ScreenSaver
import WebKit

let WebscreenModuleName = "lv.paulsnar.Webscreen"

class WebscreenView: ScreenSaverView, WKNavigationDelegate {
  var webView: WKWebView
  
  override var hasConfigureSheet: Bool { get { return false } }

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

    let url = URL.init(string: "https://masu.p22.co/~paulsnar/bounce.php")!
    let rq = URLRequest(
      url: url,
      cachePolicy: .reloadRevalidatingCacheData,
      timeoutInterval: TimeInterval.init(exactly: 5)!)
    self.webView.load(rq)
  
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
}
