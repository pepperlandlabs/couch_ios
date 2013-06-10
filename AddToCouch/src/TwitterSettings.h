#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>

#define kTwitterSettingsButtonIndex 0

@interface TwitterSettings : NSObject

+ (BOOL)hasAccounts;
+ (void)openTwitterAccounts;

@end