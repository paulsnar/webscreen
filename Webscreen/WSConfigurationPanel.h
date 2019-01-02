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
