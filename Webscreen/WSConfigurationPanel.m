//
//  WSConfigurationPanel.m
//  Webscreen
//
//  Created by paulsnar on 2018-12-25.
//  Copyright © 2018 paulsnar. All rights reserved.
//

#import "WSConfigurationPanel.h"

@interface WSConfigurationPanel () <NSWindowDelegate>
@end

@implementation WSConfigurationPanel
{
  NSString* _url;
  IBOutlet NSTextField* _urlField;
}

- (instancetype)initWithInitialURL:(NSString*)url
{
  _url = url;
  return [self initWithWindowNibName:@"WSConfigurationPanel"];
}

- (void)windowDidLoad {
  _urlField.stringValue = _url;
  [super windowDidLoad];
}

- (void)handleDismissRequested:(id)sender
{
  [self.delegate configurationPanelWasClosed:self];
}

- (void)handleURLFieldChanged:(NSTextField *)sender
{
  NSString* newUrl = sender.stringValue;
  if ([_url isEqualToString:newUrl] || [newUrl length] == 0) {
    // prevent duplicate events or empty urls
    return;
  }

  [self.delegate configurationPanel:self
                urlFieldChangedFrom:_url to:newUrl];
  _url = newUrl;
}

@end
