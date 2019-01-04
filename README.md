# Webscreen

A simple screensaver, thinly wrapping [WKWebView][].

Inspired by, but shares no code with, [WebViewScreenSaver][], which uses
WebView which doesn't have the sort of performance WKWebView can offer.

[WKWebView]: https://developer.apple.com/documentation/webkit/wkwebview
[WebViewScreenSaver]: https://github.com/liquidx/webviewscreensaver

## Web-side API

There's a basic (currently read-only) API available within the screensaver
web context. The global `WSKit` currently contains two useful properties:

* `display` the 1-based index of the display the page is currently
  displayed on.
* `totalDisplays` the 1-based count of total displays attached to the machine
  the screensaver's running on.

Note that there are currently no limitations on what can access these
properties, so if you're privacy-conscious and don't want to leak the
information about how many monitors you have, perhaps version [1.12][] is
better for you.

[1.12]: https://github.com/paulsnar/webscreen/releases/tag/v1.12

## Distribution Tips

* The default URL can be changed via the `WSDefaultURL` Info.plist property.
  Note that this is effective only for the first installation, because then
  the URL will be persisted to preference storage. If this Info.plist property
  is changed, either a rebuild or a resigning is necessary – the distributive
  contains my code signature and that covers Info.plist.

## License

[X11](./LICENSE.txt)
