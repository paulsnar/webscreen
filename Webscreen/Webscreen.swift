import Foundation
import ScreenSaver
import WebKit

class WebscreenView: ScreenSaverView {
    var webView: WKWebView?
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        
        self.autoresizingMask = [.width, .height]
        self.autoresizesSubviews = true
        
        self.createWebview()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.createWebview()
    }
    
    func createWebview() {
        let config = WKWebViewConfiguration()
        config.suppressesIncrementalRendering = false
        
        self.webView = WKWebView(frame: .zero, configuration: config)
    }
    
    override func startAnimation() {
        super.startAnimation()

        if let webView = self.webView {
            webView.frame = self.frame
            
            let url = URL(string: "https://5d025718.neocities.org/bounce.html?screensaver")!
            let rq = URLRequest(
                url: url,
                cachePolicy: .reloadRevalidatingCacheData,
                timeoutInterval: TimeInterval.init(exactly: 5)!)
            webView.load(rq)
            
            if self.isPreview {
                // do a hack to scale the view to half of its actual size
                let intermediate = NSView.init(frame: self.frame)
                intermediate.bounds = self.frame.applying(
                    CGAffineTransform.init(scaleX: 2, y: 2))
                intermediate.addSubview(webView)
                webView.frame = intermediate.bounds
                self.addSubview(intermediate)
            } else {
                self.addSubview(webView)
            }
        }
    }
    
    override func stopAnimation() {
        super.stopAnimation()
    }
    
    func handleResize(bounds: NSRect) {
        self.frame = bounds
        self.bounds = bounds
        if let webView = self.webView {
            webView.frame = bounds
        }
    }
    
    func resizeSubviews(_ oldSize: NSSize) {
        if let webView = self.webView {
            webView.frame = self.bounds
        }
    }
}
