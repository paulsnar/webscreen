#import <ScreenSaver/ScreenSaver.h>
#import <WebKit/WebKit.h>

@protocol WebscreenViewDelegate;

@interface WebscreenView : ScreenSaverView

@property(nonatomic, strong) id<WebscreenViewDelegate> delegate;

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
                 withDefaults:(NSUserDefaults*)defaults
                 withInfoDictionary:(NSDictionary*)plist;
@end

@protocol WebscreenViewDelegate <NSObject>

- (NSUserDefaults*)defaultsForWebscreenView:(WebscreenView*)view;

@end
