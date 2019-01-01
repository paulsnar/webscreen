# Webscreen

A simple screensaver, thinly wrapping [WKWebView][].

Inspired by, but shares no code with, [WebViewScreenSaver][], which uses
WebView which doesn't have the sort of performance WKWebView can offer.

[WKWebView]: https://developer.apple.com/documentation/webkit/wkwebview
[WebViewScreenSaver]: https://github.com/liquidx/webviewscreensaver

## Distribution Tips

* The default URL can be changed via the `WSDefaultURL` Info.plist property.
  Note that this is effective only for the first installation, because then
  the URL will be persisted to preference storage. If this Info.plist property
  is changed, either a rebuild or a resigning is necessary -- the distributive
  contains my code signature and that covers Info.plist.

## License

[X11](./LICENSE.txt)
