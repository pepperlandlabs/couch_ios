#import "TwitterSettings.h"

@implementation TwitterSettings

+ (BOOL)hasAccounts {
    // For clarity
    NSLog(@"has Account: %d", [TWTweetComposeViewController canSendTweet]);
    return [TWTweetComposeViewController canSendTweet];
}

+ (void)openTwitterAccounts {
    
    
    TWTweetComposeViewController *ctrl = [[TWTweetComposeViewController alloc] init];
    if ([ctrl respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        NSLog(@"can invoke twitter");
        // Manually invoke the alert view button handler
        [(id <UIAlertViewDelegate>)ctrl alertView:nil
                             clickedButtonAtIndex:kTwitterSettingsButtonIndex];
    }

   // [ctrl release];
}



@end