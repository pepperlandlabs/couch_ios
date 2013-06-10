//
//  ViewController.h
//  WikiSensei
//
//  Created by Rich Schiavi on 11/28/11.
//  Copyright (c) 2011 MOG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
//#import "ASIFormDataRequest.h"
#import "LBYouTubePlayerViewController.h"

#import "GMGridViewLayoutStrategies.h"

#import "GMGridView.h"
#import "FinderViewController.h"


@interface ViewController : UIViewController {
    LBYouTubePlayerViewController* controller;
    IBOutlet UIWebView *infoTextView;
    IBOutlet UILabel *video_title;
    IBOutlet UILabel *author;
    IBOutlet UILabel *video_source;
    IBOutlet UILabel *historyLabel;
    IBOutlet UIButton *shareButton;
    IBOutlet UIView *infoView;
    IBOutlet UIButton *settingsButton;
    IBOutlet UIView *mainView;
    IBOutlet UIButton *currentButton;
    IBOutlet UIButton *queueButton;
    IBOutlet UIButton *historyButton;
    IBOutlet UIView *shareView;
    IBOutlet UIView *buttonView;
    IBOutlet UIWebView *webView;
    IBOutlet UIImageView *profileImage;
    IBOutlet UIView *profileTabView;
    IBOutlet GMGridView *gridView;
    IBOutlet GMGridView *historyGridView;

    IBOutlet UIView *profileView;
    IBOutlet UIView *profileBackgroundView;
    IBOutlet UILabel *profileName, *profileScreenName;
    IBOutlet UILabel *profileVideos, *profileFollowers, *profileFollowing;
    IBOutlet UIActivityIndicatorView *activity;
    FinderViewController *finderViewController;

    NSMutableDictionary *profile;
    NSString *currentPlaying;
    NSLock *queueLock;
    UINavigationController *modalViewNavController;
    NSTimer *refreshTimer;
}
@property (nonatomic, retain) NSTimer *refreshTimer;

@property (nonatomic, retain) NSLock *queueLock;
@property (nonatomic, retain) NSMutableDictionary *profile;
@property (nonatomic, retain) FinderViewController *finderViewController;
@property (nonatomic, retain) NSString *currentPlaying;

@property (nonatomic, retain) IBOutlet ViewController *popupView;
@property (nonatomic, retain) IBOutlet UIView *profileBackgroundView;
@property (nonatomic, retain) IBOutlet GMGridView *gridView, *historyGridView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activity;


@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIImageView *profileImage;

@property (nonatomic, retain) IBOutlet UIWebView *infoTextView;
@property (nonatomic, retain) IBOutlet UILabel *video_title, *profileFollowers, *profileFollowing, *historyLabel, *video_source;
@property (nonatomic, retain) IBOutlet UILabel *author, *profileName, *profileScreenName, *profileVidoes;
@property (nonatomic, retain) IBOutlet UIView *infoView, *shareView,*buttonView, *profileView;
@property (nonatomic, retain) IBOutlet UIView *mainView, *profileTabView;
@property (nonatomic, retain) IBOutlet UIScrollView *infoScrollView;
@property (nonatomic, retain) IBOutlet UIButton *currentButton, *queueButton,*historyButton,*shareButton;



- (void)twitterAction:(id)sender;
- (void)facebookAction:(id)sender;
- (void)mailAction:(id)sender;

                              @property (nonatomic, retain) NSMutableArray *following_items, *followers_items;
@property (nonatomic, retain) NSMutableArray *queue_items;
@property (nonatomic, retain) NSMutableArray *played_items;
@property (nonatomic, retain) NSMutableDictionary *played_dict;
@property (nonatomic, retain) NSMutableDictionary *queued_dict;
                              @property (nonatomic, retain) NSMutableDictionary *following_dict, *followers_dict;

@property (nonatomic, retain) NSString *user_name;
@property (nonatomic, retain) NSDictionary *currently_playing;

@property (nonatomic, strong) LBYouTubePlayerViewController* controller;


-(void)post:(NSData *)data thumb:(NSData *)thumb params:(NSMutableArray *)params;
-(IBAction)tabChanged:(id)sender;
-(IBAction)currentSelected:(id)sender;
-(IBAction)queueSelected:(id)sender;
-(IBAction)historySelected:(id)sender;
-(IBAction)showFinder:(id)sender;
-(IBAction)share:(id)sender;
-(void)refreshProfile;
-(void)setBackground;
-(void)fetchData;
-(void)getQueue:(NSString *)u;
-(void)getPlayed:(NSString *)u;

@end
