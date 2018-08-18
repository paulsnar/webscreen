import Foundation
import ScreenSaver
import WebKit

class WebscreenView: ScreenSaverView, WKNavigationDelegate {
    var webView: WKWebView?
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        
        self.wantsLayer = true
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
//        config.allowsInlineMediaPlayback = false // not available on Mac?
        config.mediaTypesRequiringUserActionForPlayback = .all
        
        self.webView = WKWebView(frame: .zero, configuration: config)
        if let webView = self.webView {
            webView.navigationDelegate = self
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let webView = self.webView, webView.alphaValue < 1.0 {
            let anim = webView.animator()
            anim.alphaValue = 1.0
        }
    }
    
    override func startAnimation() {
        super.startAnimation()

        self.layer?.backgroundColor = .black

        if let webView = self.webView {
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
                webView.frame = self.frame
                self.addSubview(webView)
            }

            webView.alphaValue = 0.0
        }
    }
    
    override func stopAnimation() {
        super.stopAnimation()
    }
    
    func resizeSubviews(_ oldSize: NSSize) {
        if let webView = self.webView {
            var bounds = self.frame
            if self.isPreview {
                bounds = bounds.applying(
                    CGAffineTransform.init(scaleX: 2, y: 2))
            }
            webView.frame = bounds
        }
    }
}
