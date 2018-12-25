//
//  AppDelegate.m
//  WebscreenAppWrapper
//
//  Created by paulsnar on 2018-12-25.
//  Copyright © 2018 paulsnar. All rights reserved.
//

#import "AppDelegate.h"
#import "WebscreenView.h"

@interface AppDelegate () <NSWindowDelegate>

@property (weak) IBOutlet NSWindow *window;

-(IBAction)handleConfigureAction:(id)sender;

@end

@implementation AppDelegate
{
  WebscreenView* _wv;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
  return YES;
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
  self.window.minSize = NSMakeSize(1024, 768);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  self.window.delegate = self;
  
  NSRect frame = self.window.frame;
  if (frame.size.width < 1024 || frame.size.height < 768) {
    NSRect target = NSMakeRect(frame.origin.x, frame.origin.y, 1024, 768);
    [self.window setFrame:target display:YES animate:YES];
  }
  
  if (self.window.contentView != nil) {
    NSView* contentView = self.window.contentView;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    _wv = [[WebscreenView alloc] initWithFrame:contentView.bounds
                                  isPreview:NO
                                  withDefaults:defaults];
    [contentView addSubview:_wv];
    [_wv startAnimation];
  }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  if (_wv != nil) {
    [_wv stopAnimation];
  }
}

- (void)windowDidResize:(NSNotification *)notification
{
  
}

- (void)handleConfigureAction:(id)sender
{
  NSWindow* panel = _wv.configureSheet;
  [self.window beginSheet:panel completionHandler:nil];
}


@end
