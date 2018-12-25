//
//  WebscreenView.h
//  Webscreen
//
//  Created by paulsnar on 2018-12-25.
//  Copyright © 2018 paulsnar. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import <WebKit/WebKit.h>

@protocol WebscreenViewDelegate;

@interface WebscreenView : ScreenSaverView

@property(nonatomic, strong) id<WebscreenViewDelegate> delegate;

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
                 withDefaults:(NSUserDefaults*)defaults;
@end

@protocol WebscreenViewDelegate <NSObject>

- (NSUserDefaults*)defaultsForWebscreenView:(WebscreenView*)view;

@end
