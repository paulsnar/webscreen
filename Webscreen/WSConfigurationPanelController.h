#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WSConfigurationDelegate;

@interface WSConfigurationPanelController : NSWindowController
  @property(nonatomic, strong) IBOutlet NSTextField *_urlField;

  @property(nonatomic, strong) id<WSConfigurationDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
