# Webscreen

A simple screensaver, thinly wrapping [WKWebView][].

Inspired by, but shares no code with, [WebViewScreenSaver][], which uses
WebView which doesn't have the sort of performance WKWebView can offer.

[WKWebView]: https://developer.apple.com/documentation/webkit/wkwebview
[WebViewScreenSaver]: https://github.com/liquidx/webviewscreensaver

## Development

For developing your screensavers the WebscreenAppWrapper also allows
mouse interaction and developer tools. The URL preference sheet is
within the application preferences.

## WSKit

Webscreen exposes a simple API to the running webpage, called WSKit. It is
currently very limited (and intended to remain so), but it does provide
just enough additional information so the running webpage can adjust its
behaviour appropriately.

Right now the only available property is `configuration` – a promise which
resolves to an object containing two properties:

* `display` is the 1-based index of the display this instance of Webscreen
  is running on, and
* `totalDisplays` is the number of displays on this computer.

Currently the WSKit API is exposed to all pages loaded within Webscreen, so
if there exists a privacy concern due to which you don't want to share your
monitor count with the webpage. it's probably best to stick with version
[1.12][] instead.

[1.12]: https://github.com/paulsnar/webscreen/releases/tag/v1.12

## Distribution Tips

* The default URL can be changed via the `WSDefaultURL` Info.plist property.
  Note that this is effective only for the first installation, because then
  the URL will be persisted to preference storage. If this Info.plist property
  is changed, either a rebuild or a resigning is necessary – the distributive
  contains my code signature and that covers Info.plist.

## License

[X11](./LICENSE.txt)
