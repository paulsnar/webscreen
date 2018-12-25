//
//  WSConfigurationPanel.h
//  Webscreen
//
//  Created by paulsnar on 2018-12-25.
//  Copyright © 2018 paulsnar. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WSConfigurationPanelDelegate;

@interface WSConfigurationPanel : NSWindowController

@property(nonatomic, strong) id<WSConfigurationPanelDelegate> delegate;

- (IBAction)handleURLFieldChanged:(NSTextField*)sender;
- (IBAction)handleDismissRequested:(id)sender;

- (instancetype)initWithInitialURL:(NSString*)url;

@end

@protocol WSConfigurationPanelDelegate <NSObject>

- (void)configurationPanel:(WSConfigurationPanel*)panel urlFieldChangedFrom:(NSString*)old to:(NSString*)current;
- (void)configurationPanelWasClosed:(WSConfigurationPanel*)panel;

@end

NS_ASSUME_NONNULL_END
