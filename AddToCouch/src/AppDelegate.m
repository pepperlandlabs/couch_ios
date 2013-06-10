//
//  AppDelegate.m
//  WikiSensei
//
//  Created by Rich Schiavi on 11/28/11.
//  Copyright (c) 2011 MOG. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [UIApplication sharedApplication].statusBarHidden = YES;

   // [[UIDevice currentDevice] performSelector:NSSelectorFromString(@"setOrientation:") withObject:(id)UIInterfaceOrientationLandscapeRight];
    /*  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,0,1024.0f,768.0f)];
    UIImageView*imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"couch-cushion-green"]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(0,0,1024,577);
    [view addSubview:imageView];
        UIButton *signin = [UIButton buttonWithType:UIButtonTypeCustom];

    UIViewController *firstViewController = [_window rootViewController];
    [[firstViewController view] addSubview:view];
    [[firstViewController view] addSubview:signin];
    [[firstViewController view] bringSubviewToFront:view];
    
    // as usual
    [self.window makeKeyAndVisible];
    
    //now fade out splash image
    [UIView transitionWithView:self.window duration:2.0f options:UIViewAnimationOptionTransitionNone animations:^(void){imageView.alpha=0.0f;} completion:^(BOOL finished){[imageView removeFromSuperview];}];*/
    return YES;
}
                                                        
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}





- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
  ViewController *c = [_window rootViewController];
    [c setBackground];
  
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    NSLog(@"app became active");
    ViewController *c = [_window rootViewController];
    [c fetchData];
//    [[_window rootViewController] fetchData];

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
