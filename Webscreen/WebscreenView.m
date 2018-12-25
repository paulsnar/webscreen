//
//  WebscreenView.m
//  Webscreen
//
//  Created by paulsnar on 2018-12-25.
//  Copyright © 2018 paulsnar. All rights reserved.
//

#import "WebscreenView.h"
#import "WSConfigurationPanel.h"

static NSString* const kWebscreenModuleName = @"lv.paulsnar.Webscreen";
static NSString* const kDefaultsKeyUrl = @"url";

@interface WebscreenView () <WKNavigationDelegate, WSConfigurationPanelDelegate>
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
  NSUserDefaults* defaults = [ScreenSaverDefaults defaultsForModuleWithName:kWebscreenModuleName];
  return [self initWithFrame:frame isPreview:isPreview withDefaults:defaults];
}

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview withDefaults:(NSUserDefaults*)defaults
{
  self = [super initWithFrame:frame isPreview:isPreview];
  if ( ! self) {
    return self;
  }
  
  _url = [defaults stringForKey:kDefaultsKeyUrl];
  if (_url == nil) {
    _url = @"https://masu.p22.co/~paulsnar/bounce.php";
    [defaults setObject:_url forKey:kDefaultsKeyUrl];
  }
  _defaults = defaults;
  
  self.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  self.autoresizesSubviews = YES;
  self.wantsLayer = YES;
  
  WKWebViewConfiguration* conf = [[WKWebViewConfiguration alloc] init];
  conf.suppressesIncrementalRendering = NO;
  conf.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeAll;
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
  return nil;
}

- (void)keyDown:(NSEvent *)event
{
  return;
}

- (void)keyUp:(NSEvent *)event
{
  return;
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

@end
