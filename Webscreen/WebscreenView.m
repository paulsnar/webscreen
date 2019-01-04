#import "WebscreenView.h"
#import "WSConfigurationPanel.h"

static NSString* const kWebscreenModuleName = @"lv.paulsnar.Webscreen";
static NSString* const kDefaultsKeyUrl = @"url";
static NSString* const kPlistDefaultUrlKey = @"WSDefaultURL";

@interface WebscreenView () <
  WKNavigationDelegate,
  WKScriptMessageHandler,
  WSConfigurationPanelDelegate>

- (void)injectWSKitScriptInUserContentController:
    (WKUserContentController*)userContentController;

@end

@implementation WebscreenView
{
  NSUserDefaults* _defaults;
  NSString* _url;
  NSView* _intermediateView;
  WKWebView* _webView;
  BOOL _animationStarted;
  WSConfigurationPanel* _confPanel;
}

+ (BOOL)performGammaFade
{
  return YES;
}

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
  NSBundle* ownBundle = [NSBundle bundleForClass:[WebscreenView class]];
  return [self initWithFrame:frame isPreview:isPreview
    withDefaults:[ScreenSaverDefaults defaultsForModuleWithName:kWebscreenModuleName]
    withInfoDictionary:[ownBundle infoDictionary]];
}

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview withDefaults:(NSUserDefaults*)defaults withInfoDictionary:(NSDictionary*)plist
{
  self = [super initWithFrame:frame isPreview:isPreview];
  if ( ! self) {
    return self;
  }

  _url = [defaults stringForKey:kDefaultsKeyUrl];
  if (_url == nil) {
    _url = [plist valueForKey:kPlistDefaultUrlKey];
    [defaults setObject:_url forKey:kDefaultsKeyUrl];
  }
  _defaults = defaults;

  self.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  self.autoresizesSubviews = YES;
  self.wantsLayer = YES;

  WKWebViewConfiguration* conf = [[WKWebViewConfiguration alloc] init];
  conf.suppressesIncrementalRendering = NO;
  conf.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeAll;

  WKUserContentController* userContentController =
      [[WKUserContentController alloc] init];
  [self injectWSKitScriptInUserContentController:userContentController];
  [userContentController addScriptMessageHandler:self name:@"webscreen"];
  conf.userContentController = userContentController;

#ifdef WEBSCREEN_DEBUG
  NSLog(@"[Webscreen] Debug mode on");
  [conf.preferences setValue:@YES forKey:@"developerExtrasEnabled"];
#endif

  _webView = [[WKWebView alloc] initWithFrame:frame configuration:conf];
  _webView.navigationDelegate = self;

  if (isPreview) {
    _intermediateView = [[NSView alloc] initWithFrame:NSZeroRect];
    [_intermediateView addSubview:_webView];
    [self addSubview:_intermediateView];
  } else {
    [self addSubview:_webView];
  }

  [self resizeSubviewsWithOldSize:NSZeroSize];

  return self;
}

#pragma mark - screensaver implementation

- (void)startAnimation
{
  [super startAnimation];
  if (_animationStarted) {
    return;
  }
  _animationStarted = YES;

  self.layer.backgroundColor = CGColorGetConstantColor(kCGColorBlack);
  _webView.alphaValue = 0.0;

  NSURL *url = [NSURL URLWithString:_url];
  NSURLRequest *rq = [NSURLRequest requestWithURL:url];
  [_webView loadRequest:rq];
}

- (void)stopAnimation
{
  [super stopAnimation];
  _animationStarted = NO;
  _webView.animator.alphaValue = 0.0;
}

- (BOOL)hasConfigureSheet
{
  return YES;
}

- (NSWindow*)configureSheet
{
  if (_confPanel == nil) {
    _confPanel = [[WSConfigurationPanel alloc] initWithInitialURL:_url];
    _confPanel.delegate = self;
  }
  return _confPanel.window;
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize
{
  CGRect bounds = NSRectToCGRect(self.bounds);
  CGAffineTransform transform = CGAffineTransformIdentity;
  if (self.isPreview) {
    transform = CGAffineTransformScale(transform, 2.0, 2.0);
  }
  CGRect childBounds = CGRectApplyAffineTransform(bounds, transform);

  if (_intermediateView != nil) {
    _intermediateView.frame = bounds;
    _intermediateView.bounds = childBounds;
  }
  _webView.frame = childBounds;
}

#pragma mark - interaction interception

- (NSView*)hitTest:(NSPoint)point
{
#ifdef WEBSCREEN_DEBUG
  return [super hitTest:point];
#else
  return nil;
#endif
}

- (void)keyDown:(NSEvent *)event
{
#ifdef WEBSCREEN_DEBUG
  [super keyDown:event];
#endif
}

- (void)keyUp:(NSEvent *)event
{
#ifdef WEBSCREEN_DEBUG
  [super keyUp:event];
#endif
}

- (void)mouseDown:(NSEvent *)event
{
#ifdef WEBSCREEN_DEBUG
  [super mouseDown:event];
#endif
}

- (void)mouseUp:(NSEvent *)event
{
#ifdef WEBSCREEN_DEBUG
  [super mouseUp:event];
#endif
}

- (void)mouseDragged:(NSEvent *)event
{
#ifdef WEBSCREEN_DEBUG
  [super mouseDragged:event];
#endif
}

- (void)mouseEntered:(NSEvent *)event
{
#ifdef WEBSCREEN_DEBUG
  [super mouseEntered:event];
#endif
}

- (void)mouseExited:(NSEvent *)event
{
#ifdef WEBSCREEN_DEBUG
  [super mouseExited:event];
#endif
}

#pragma mark - navigation delegate

- (void) webView:(WKWebView*)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
  if (_webView.alphaValue < 1.0) {
    WKWebView* animator = [_webView animator];
    animator.alphaValue = 1.0;
  }
}

#pragma mark - configuration panel delegate

- (void)configurationPanel:(WSConfigurationPanel*)panel urlFieldChangedFrom:(NSString*)old to:(NSString*)current
{
  _url = current;
  [self stopAnimation];
  [self startAnimation];

  [_defaults setObject:current forKey:kDefaultsKeyUrl];
  [_defaults synchronize];
}

- (void)configurationPanelWasClosed:(WSConfigurationPanel*)panel
{
  if (panel.window.sheetParent != nil) {
    [panel.window.sheetParent endSheet:panel.window];
  } else {
    [NSApplication.sharedApplication endSheet:panel.window];
  }

  _confPanel = nil;
}

#pragma mark - WSKit implementation

- (void)injectWSKitScriptInUserContentController:
    (WKUserContentController*)userContentController
{
  NSBundle* bundle = [NSBundle bundleForClass:[WebscreenView class]];
  NSString* scriptLocation = [bundle pathForResource:@"webscreen" ofType:@"js"];
  NSString* scriptSource = [NSString stringWithContentsOfFile:scriptLocation
      encoding:NSUTF8StringEncoding error:nil];
  WKUserScript* userScript = [[WKUserScript alloc]
      initWithSource:scriptSource
      injectionTime:WKUserScriptInjectionTimeAtDocumentStart
      forMainFrameOnly:YES];

  [userContentController addUserScript:userScript];
}

- (NSDictionary*)configForWSKit
{
  NSArray* screens = [NSScreen screens];
  NSScreen* currentScreen = [NSScreen mainScreen];
  return @{
    @"display": [NSNumber numberWithUnsignedInteger:
        [screens indexOfObject:currentScreen] + 1],
    @"totalDisplays": [NSNumber numberWithUnsignedInteger:[screens count]],
  };
}

- (void)userContentController:(WKUserContentController*)userContentController
    didReceiveScriptMessage:(WKScriptMessage*)message
{
  // apparently message.name is the name passed to the registration function
  // and message.body is the argument to the postMessage function in JS
  // counterintuitive innit
  NSString* messageName = message.body;

  if ([messageName isEqualToString:@"obtainconfiguration"]) {
    NSError *err;
    NSDictionary* config = [self configForWSKit];
    NSData *json = [NSJSONSerialization dataWithJSONObject:config
        options:0 error:&err];
    if ( ! json) {
      NSLog(@"[Webscreen] WSKit configuration: error: %@",
          err.localizedDescription);
      return;
    }

    NSString* jsonStr = [NSString stringWithUTF8String:json.bytes];
    NSString* invocation = [NSString stringWithFormat:
      @"WSKit.dispatchEvent('configure', %@);", jsonStr];
    [_webView evaluateJavaScript:invocation completionHandler:nil];
  }
}

@end
