//
//  ViewController.m
//  WikiSensei
//
//  Created by Rich Schiavi on 11/28/11.
//  Copyright (c) 2011 MOG. All rights reserved.
//

#import "ViewController.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "LBYouTube.h"
#import "SlidingTabsControl.h"
#import "MessageUI/MessageUI.h"
#import "TwitterSettings.h"
#import "ASIFormDataRequest.h"

@implementation ViewController

@synthesize queueLock;
@synthesize profile;
@synthesize video_source;
@synthesize profileBackgroundView;
@synthesize historyLabel;
@synthesize refreshTimer;

@synthesize finderViewController;
@synthesize controller, user_name,infoView, author,video_title,mainView;
@synthesize currentButton,queueButton,historyButton, shareButton;
@synthesize shareView;
@synthesize profileView, profileTabView;
@synthesize queue_items,queued_dict;
@synthesize played_items,played_dict, following_dict,followers_dict;
@synthesize following_items, followers_items;
@synthesize currently_playing;
@synthesize gridView, historyGridView;
@synthesize buttonView;
@synthesize webView;
@synthesize profileFollowers,profileFollowing, profileName,profileScreenName;
@synthesize activity;
@synthesize currentPlaying;
@synthesize infoTextView;

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

int current_mode = 0;
int current_index = -1;
int current_play_mode = 0;
int profile_view_tab = 0;
int LOADED = NO;
int prev = -1;

BOOL background = NO;

SlidingTabsControl *tabs;

BOOL isAirplay = NO;
BOOL ignoreOnChangeFinish = NO;

int played_length = 0;
BOOL historyScrolling = NO;
BOOL queueScrolling = NO;

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Release any cached data, images, etc that aren't in use.
  NSLog(@"GOT MEMORY WARNING");
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];


  //  [mainView setBackgroundColor:[UIColor colorWithRed:.26 green:.26 blue:.26 alpha:1.0]];
  //  [settingsButton setBackgroundColor:[UIColor colorWithRed:.26 green:.26 blue:.26 alpha:1.0]];
  //    [shareView setBackgroundColor:[UIColor colorWithRed:.26 green:.26 blue:.26 alpha:1.0]];

  [self.webView setHidden:YES];
  queueLock = [[NSLock alloc] init];
    NSLog(@"VIEW DID LOAD");
  webView.allowsInlineMediaPlayback = YES;
  webView.mediaPlaybackRequiresUserAction = NO;
  webView.delegate = self;
  [webView setOpaque:NO];

  [profileView setHidden:YES];
  [profileBackgroundView setHidden:YES];
  webView.backgroundColor = [UIColor clearColor];

  self.queue_items = [NSMutableArray array];
  self.following_items = [NSMutableArray array];
  self.followers_items = [NSMutableArray array];
  self.played_items = [NSMutableArray array];
  self.queued_dict = [NSMutableDictionary dictionary];
  self.played_dict = [NSMutableDictionary dictionary];
  self.following_dict = [NSMutableDictionary dictionary];
  self.followers_dict = [NSMutableDictionary dictionary];
  self.infoTextView.delegate = self;
  [self.shareButton setHidden:YES];
  // [self currentSelected:queueButton];
  [self queueSelected:queueButton];
 // [self fetchData];

  [self.gridView setHidden:YES];
  [self.historyGridView setHidden:YES];
  self.gridView.clipsToBounds = YES;
  self.historyGridView.clipsToBounds = YES;

  //gridView.pagingEnabled = NO;
  gridView.actionDelegate = self;
  gridView.sortingDelegate = self;
  gridView.dataSource = self;
  gridView.delegate = self;
  gridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutHorizontal];
 // self.gridView.frame = CGRectMake(64,1,960,190);

  historyGridView.actionDelegate = self;
  historyGridView.sortingDelegate = self;
  historyGridView.dataSource = self;
  historyGridView.delegate = self;
  //    historyGridView.frame = CGRectMake(260, 3,765,188); //CGRectMake(360, /*422,*/3,665,188);
  historyGridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutHorizontal];

  CGRect screenBounds = [[UIScreen mainScreen] bounds];
  if (screenBounds.size.height < 760){
    gridView.itemSpacing = 1;
    historyGridView.itemSpacing =1;
    gridView.minEdgeInsets = UIEdgeInsetsMake(1, 1, 1, 1);
    historyGridView.minEdgeInsets = UIEdgeInsetsMake(1, 1, 1, 1);
  }
    
  //tabs = [[SlidingTabsControl alloc] initWithTabCount:3 delegate:self];
    
  //[profileTabView addSubview:tabs];
  //    [self currentSelected:queueButton];
  //[self queueSelected:queueButton];
  /*          CGRect screenBounds = [[UIScreen mainScreen] bounds];
          if (screenBounds.size.height < 760){
            buttonView.frame = CGRectMake(0,0,32,100);
            }*/

       /*   dispatch_async(dispatch_get_main_queue(),^{
              @autoreleasepool {
                  refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshData) userInfo:nil     repeats:YES];
                  refreshTimer = nil;
              }
          });*/

    // 1:38 3MB

}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }

    return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

  if (scrollView == historyGridView)
    historyScrolling = YES;
  else if (scrollView == gridView)
    queueScrolling = YES;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  if (scrollView == historyGridView)
    historyScrolling = NO;
  else if (scrollView == gridView)
    queueScrolling = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  //  NSLog(@"end dragging");
  if (scrollView == historyGridView)
    historyScrolling = NO;
  else if (scrollView == gridView)
    queueScrolling = NO;
    
}

- (UILabel*) labelFor:(SlidingTabsControl*)slidingTabsControl atIndex:(NSUInteger)tabIndex;
{
  //  NSLog(@"GET LABEL FOR %@", profile);
  UILabel* label = [[UILabel alloc] init];
  [label setNumberOfLines:2];
  if (profile){
    if (tabIndex == 0){
      //NSObject *played = [profile objectForKey:@"played"];
      label.text = [NSString stringWithFormat:@"Videos\r\n %d", played_length]; //[played objectForKey:@"length"]];
    } else if (tabIndex == 1){
      label.text = [NSString stringWithFormat:@"Following\r\n %@", [profile objectForKey:@"following"]];
    } else if (tabIndex == 2){
      label.text = [NSString stringWithFormat:@"Followers\r\n %@", [profile objectForKey:@"followers"]];
    }} else {
    label.text = @"initializing";
  }
    
  return label;
}

- (void) touchUpInsideTabIndex:(NSUInteger)tabIndex
{
  //    NSLog(@"Profile view tab: %d", tabIndex);
  profile_view_tab = tabIndex;
  if (profile_view_tab == 1){
  } else if (profile_view_tab ==2){
  } else {
    // show history for now
    profile_view_tab = 0;
    [self refresh];
  
  }

}

- (void) touchDownAtTabIndex:(NSUInteger)tabIndex
{
    
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
  //  NSLog(@"POPUP DID DISMISS");
  if (!isAirplay){
    //NSLog(@"PLAY");
    [self.controller play];
  }
}


-(IBAction)showFinder:(id)sender {

  // if we are NOT in airplay mode, pause video
  if (!isAirplay){
    //    NSLog(@"pause video");
    [self.controller pause];
  }

    if (self.finderViewController != nil){
         [self presentModalViewController:modalViewNavController animated:YES];
        return;
        
    }
      modalViewNavController = nil;
  self.finderViewController = [FinderViewController alloc];

  [self.finderViewController setUser:self.user_name];
  modalViewNavController = [[UINavigationController alloc] initWithRootViewController:finderViewController];
  modalViewNavController.modalTransitionStyle =  UIModalTransitionStyleCoverVertical;  //UIModalTransitionStyleCrossDissolve;
  modalViewNavController.modalPresentationStyle = UIModalPresentationCurrentContext;    //UIModalPresentationFullScreen;
  [self presentModalViewController:modalViewNavController animated:YES];
    [modalViewNavController setDelegate:self];
  //  CGRect rect = CGRectMake(0,0,1024,768); //,1,1); //1024/2, 768/2, 1, 1);
  //  modalViewNavController.view.superview.frame = rect;
  //  modalViewNavController.view.frame =rect;
  //    modalViewNavController.view.superview.center = CGPointMake(0,0);
  //modalViewNavController.view.superview.center = self.view.center;

  
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSLog(@"****will show view controller %@", viewController);
}


- (void)fetchData
{
  background = NO;
    NSLog(@"fetch twitter called");
    
  // if os5.0??
  /*  if (![TwitterSettings hasAccounts]) {
      dispatch_async(dispatch_get_main_queue(),^{
      NSLog(@"open twitter accounts");
      [TwitterSettings openTwitterAccounts];
      });
      return;
      }*/
    __block BOOL found_one = NO;
  ACAccountStore *accountStore = [[ACAccountStore alloc] init];
  ACAccountType *accountTypeTwitter = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
  [accountStore requestAccessToAccountsWithType:accountTypeTwitter withCompletionHandler:^(BOOL granted, NSError *error) {
   // NSLog(@"---->granted: %d", granted);
      if(granted && !found_one) {
          found_one = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      
            NSArray *accounts = [accountStore accountsWithAccountType:accountTypeTwitter];
            if (accounts.count){
              ACAccount *account = [accounts objectAtIndex:0];
              //NSLog(@"--->account: %@", account);
              //              NSString *set_twitter_user = [[NSString alloc]initWithFormat:@"set_twitter_user('%@')", account.username];
              NSLog(@"Got twitter: %@", account.username);
              //                [self.webView stringByEvaluatingJavaScriptFromString:set_twitter_user];
              //                [self loadHome:@"aloharich"]; //account.username];
              self.user_name =  account.username; //@"aloharich";// account.username;
              // self.user_name = @"tywhite";
              //[self getQueue];
              NSString *imageURL = [NSString stringWithFormat:@"https://api.twitter.com/1/users/profile_image?screen_name=%@&size=bigger", self.user_name];
             
                
              dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                  NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
                  UIImage *image = [UIImage imageWithData:imageData];
                  dispatch_async(dispatch_get_main_queue(),^{
                      self.profileImage.image = image;
                      [self.profileScreenName setText:[NSString stringWithFormat:@"@%@",self.user_name]];
                      [self getTwitterProfile:self.user_name];
                      [self refresh];
                      [self refreshData];
                     /* [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(refreshData) userInfo:nil     repeats:YES];*/
                    });
                });
                
               
              // [self refreshData];

              //[self getProfile:self.user_name];
            } else {
              dispatch_async(dispatch_get_main_queue(),^{
                  SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                  tweetSheet.view.hidden=TRUE;
                    
                  [self presentViewController:tweetSheet animated:NO completion:^{
                      [tweetSheet.view endEditing:YES];
                    }];

               
                });
            }
          });
      } else {
        //        NSLog(@"show alert no twitter");
        dispatch_async(dispatch_get_main_queue(),^{
            SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            tweetSheet.view.hidden=TRUE;
            
            [self presentViewController:tweetSheet animated:NO completion:^{
                [tweetSheet.view endEditing:YES];

              }];

            //         UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Hello" message:@"Please click okay to link your twitter account." delegate:self
            //                                                 cancelButtonTitle:@"Cancel" otherButtonTitles:nil] autorelease];
            //        [alert show];
          });
      }
    }];
    
}


-(void)getTwitterProfile:(NSString *)name {
  NSString *profileURL = [NSString stringWithFormat:@"https://api.twitter.com/1/users/show.json?screen_name=%@&include_entities=false", name];
  //    NSLog(@"get wtitter profile %@", profileURL);
  NSURLRequest *request = [NSURLRequest requestWithURL:
                                  [NSURL URLWithString:profileURL]];

  [[NSURLConnection alloc] initWithRequest:request delegate:self];
  NSURLResponse *theResponse =[[NSURLResponse alloc]init];
  NSError *errorReturned = nil;
  NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&theResponse error:&errorReturned];
    
    
  if (errorReturned) {
    // Handle error.
    NSLog(@"ERROR: %@", errorReturned);
  }
  else
    {
      NSError *jsonParsingError = nil;
      NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonParsingError];
//      NSLog(@"response %@", res);
      NSString *user = [res objectForKey:@"name"];
   //   NSLog(@"set twitter PROFILE USER name: %@", user);
      [self.profileName setText:user];
    }
}

-(void)refreshData {
  if (!background){
     NSLog(@"****refresh data");// can probably stop refreshing if video is playing full screen?
      NSString *q = [NSString stringWithFormat:@"http://dev.werhi.com/%@/queued",self.user_name];
      [self getQueue:q];
       NSString *p = [NSString stringWithFormat:@"http://dev.werhi.com/%@/played",self.user_name];

      [self getPlayed:p];
  }
}

-(void)getQueue:(NSString *)u {
    NSLog(@"****GET QUEUE***");
  //   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    @autoreleasepool {


  //  NSLog(@"GET QUEUE: %@", self.user_name);
  //  NSString *u = [NSString stringWithFormat:@"http://dev.werhi.com/%@/queued",self.user_name];
    //    NSLog(@"QUEUE: %@", u);
    NSURLRequest *request = [NSURLRequest requestWithURL:
                                    [NSURL URLWithString:u]];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];

        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             if (error){
                 dispatch_async(dispatch_get_main_queue(),^{
                     NSString *q = [NSString stringWithFormat:@"http://dev.werhi.com/%@/queued",self.user_name];
                     [self performSelector:@selector(getQueue:) withObject:q afterDelay:5.0];
                 });
                 return;
             }
        NSError *jsonParsingError = nil;
        NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonParsingError];
          data = nil;
             if (jsonParsingError){
                 dispatch_async(dispatch_get_main_queue(),^{
                     NSString *q = [NSString stringWithFormat:@"http://dev.werhi.com/%@/queued",self.user_name];
                     [self performSelector:@selector(getQueue:) withObject:q afterDelay:5.0];
                 });
                 return;
             }
        NSArray *arr_data = [res objectForKey:@"data"];
        //        NSLog(@"queueu items data size: %d", [data count]);
        int found_new = NO;
        NSEnumerator *e = [arr_data reverseObjectEnumerator];
        id object;
        [queueLock lock];
        while (object = [e nextObject]){
          NSString *video_id = [object objectForKey:@"video_id"];
          NSString *type = [object objectForKey:@"t"];
          NSObject *e = [queued_dict objectForKey:video_id];
          if (video_id){
            if ((!e) && (!([type isEqualToString:@"undefined"]))){
                if ([type isEqualToString:@"youtube"] || [type isEqualToString:@"vimeo"]){
                    [queue_items insertObject:object atIndex:0];
                    found_new = YES;
                    [queued_dict setObject:object forKey:video_id];
                }

            }
          }
        }
        [queueLock unlock];
          arr_data = nil;
          res = nil;
          e = nil;
        dispatch_async(dispatch_get_main_queue(),^{
            if (found_new) { [self.gridView reloadData]; }
//            NSLog(@"call select get queue");
            NSString *q = [NSString stringWithFormat:@"http://dev.werhi.com/%@/queued",self.user_name];

            [self performSelector:@selector(getQueue:) withObject:q afterDelay:5.0];

//               [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getQueue) userInfo:nil     repeats:NO];
          });
        //        NSDictionary *video = [data objectAtIndex:0];
        //        NSLog(@"video %@", [video objectForKey:@"thumbnail"]);
         }];
    }
 //    });
}

-(NSString *)getShorty {

  NSString *video_id = [currently_playing objectForKey:@"video_id"];
  NSString *u = [NSString stringWithFormat:@"http://dev.werhi.com/share/%@/%@",self.user_name, video_id];
//  NSLog(@"Get shorty %@", u);
  NSURLRequest *request = [NSURLRequest requestWithURL:
                                  [NSURL URLWithString:u]];

  [[NSURLConnection alloc] initWithRequest:request delegate:self];
  NSURLResponse *theResponse =[[NSURLResponse alloc]init];
  NSError *errorReturned = nil;
  NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&theResponse error:&errorReturned];
  NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//      NSLog(@"String sent from server %@",responseString);
  return responseString;

}

-(void)getPlayed:(NSString *)u {
 //      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
           @autoreleasepool {

    NSLog(@"--------->GET PLAYED: %@", self.user_name);
   // NSString *u = [NSString stringWithFormat:@"http://dev.werhi.com/%@/played",self.user_name];
    NSURLRequest *request = [NSURLRequest requestWithURL:
                                    [NSURL URLWithString:u]];
    
    //NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
   // NSURLResponse *theResponse =[[NSURLResponse alloc]init];

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];

    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
               {
                   
                   if (error){
                       dispatch_async(dispatch_get_main_queue(),^{
                           NSString *q = [NSString stringWithFormat:@"http://dev.werhi.com/%@/played",self.user_name];
                           [self performSelector:@selector(getPlayed:) withObject:q afterDelay:5.0];
                       });
                       return;
                   }
      NSError *jsonParsingError = nil;
      NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonParsingError];
      // NSLog(@"RES: %@", res);
                   if (jsonParsingError){
                       dispatch_async(dispatch_get_main_queue(),^{
                           NSString *q = [NSString stringWithFormat:@"http://dev.werhi.com/%@/played",self.user_name];
                           [self performSelector:@selector(getPlayed:) withObject:q afterDelay:5.0];
                       });
                       return;
                   }
        data = nil;
      NSArray *arr_data = [res objectForKey:@"data"];
      int found_new = NO;

      NSEnumerator *e = [arr_data objectEnumerator];
      id object;
      int index = 0;
      while (object = [e nextObject]){
        NSString *video_id = [object objectForKey:@"video_id"];
        NSObject *e = [played_dict objectForKey:video_id];
        NSString *type = [object objectForKey:@"t"];
        if (video_id){
          if ((!e) && (!([type isEqualToString:@"undefined"]))){
            //                NSLog(@"add played: %d %@", index, [object valueForKey:@"video_id"]);
            index++;
            [played_items addObject:object];
            [played_dict setObject:object forKey:video_id];
            found_new = YES;
          }}
      }
        arr_data = nil;
                   data = nil;
        res = nil;
        e = nil;
      dispatch_async(dispatch_get_main_queue(),^{
          if (found_new) {
            [self.historyGridView reloadData];
          } // only if on our segment
          [historyLabel setText:[NSString stringWithFormat:@"%d views", [played_items count]]];
          NSString *p = [NSString stringWithFormat:@"http://dev.werhi.com/%@/played",self.user_name];
          [self performSelector:@selector(getPlayed:) withObject:p afterDelay:5.0];

        });

      //        NSLog(@"data size: %d", [data count]);
      //        NSDictionary *video = [data objectAtIndex:0];
      //        NSLog(@"video %@", [video objectForKey:@"thumbnail"]);
               }];

   //    });
           }

}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

-(void)youTubePlayerViewController:(LBYouTubePlayerViewController *)controller didSuccessfullyExtractYouTubeURL:(NSURL *)videoURL {
  //    NSLog(@"Extracted video %@", videoURL);
}

-(void)youTubePlayerViewController:(LBYouTubePlayerViewController *)controller failedExtractingYouTubeURLWithError:(NSError *)error {
  //NSLog(@"Failed to get embed video: %@", error);
  //    ignoreOnChangeFinish = YES;
  [self playYouTube:current_index];
  /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"I'm sorry Dave, I'm afraid I can't do that." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
  [alert setTag:12];
  [alert show];*/

    
}

-(void)youTubePlayerViewController:(LBYouTubePlayerViewController *)controller movieFinished:(MPMoviePlayerController *)videoController {
  /*  if (ignoreOnChangeFinish){
      NSLog(@"*************Ignore manual press finish*************");
      ignoreOnChangeFinish = NO;
      return;
      }*/
    
  // todo: avoid double finished on buffer underrun
  /*  NSLog(@"********* main app movie finished, play next ***********");
      if (current_play_mode == 1){
      int count = [self.queue_items count];
      current_index++;
      if (current_index < count){
      [self playVideo:current_index mode:current_play_mode];
      }
      }*/
  /* else {
     int count = [self.played_items count];
     current_index++;
     if (current_index < count){
     [self playVideo:current_index mode:current_play_mode];
     }
     }*/
}

-(void)youTubePlayerViewController:(LBYouTubePlayerViewController *)controller videoStateChanged:(MPMoviePlayerController *)videoController {
  //    NSLog(@"*******Main app video changed********");

  if (videoController.isAirPlayVideoActive){
    // adjust our view to go fullscreen
    isAirplay = YES;
  } else {
    // adjust it back if it isn't
    isAirplay = NO;
  }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
  if ([alertView tag] == 12) {    // it's the Error alert
    if (buttonIndex == 0) {     // and they clicked OK.
      // do stuff
    }
  } else if ([alertView tag] == 13){
    // link with twitter
  }
}

-(void)hackVideo:(int)video_id {
  [self.view bringSubviewToFront:activity];
  [self.activity setHidden:NO];
  [self.activity startAnimating];
//  NSLog(@"******************HACK VIDEO");
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

      NSString *videoURL = [NSString stringWithFormat:@"http://dev.werhi.com/video/%@", video_id];
      //        NSLog(@"get video %@", videoURL);
      NSURLRequest *request = [NSURLRequest requestWithURL:
                                      [NSURL URLWithString:videoURL]];
      NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
      NSURLResponse *theResponse =[[NSURLResponse alloc]init];
      NSError *errorReturned = nil;
      NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&theResponse error:&errorReturned];
      //        NSLog(@"got: %@", data);
      NSString *hack = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; 

      /*    NSString *hack = @"http://av.vimeo.com/26175/172/75419512.mp4?aksessionid=6836bfd47266267fe9f6923d03b97d2a&token=1353200427_72c53e8a786e62c601cec6ca58f5c3fc";*/
      //    NSLog(@"HACK: %@", hack);
      dispatch_async(dispatch_get_main_queue(),^{
          if (self.controller.delegate){
              [self.controller end];
          }
          self.controller.delegate = nil;
          //[self.controller release];
          self.controller = [[LBYouTubePlayerViewController alloc] initWithString:hack];
//                  NSLog(@"INIT WITH STRING RETURNS");
          self.controller.delegate = self;
          [self.webView setHidden:YES];
          [self.controller.view removeFromSuperview];
          CGRect screenBounds = [[UIScreen mainScreen] bounds];
          if (screenBounds.size.height > 760){
            self.controller.view.frame = CGRectMake(0,0,1024, 576);//960,540);
          } else {
            self.controller.view.frame = CGRectMake(0,0,320,200); //screenBounds.size.height,220);
          }
          [self.view addSubview:self.controller.view];
          [self.view bringSubviewToFront:self.controller.view];
          [self.activity stopAnimating];
          [self.activity setHidden:YES];
          //        NSLog(@"HERE FINAL");
        });
    });
}

-(void)playVimeo:(int)index {
  [self.controller.view removeFromSuperview];
  [self.webView setHidden:NO];
  NSString *video_id;
  if (current_mode == 1){
    video_id = [[self.queue_items objectAtIndex:index] objectForKey:@"video_id"];
  } else if (current_mode == 2){
    video_id =   [[self.played_items objectAtIndex:index] objectForKey:@"video_id"];
  }
  NSString *htmlString = [NSString stringWithFormat:@"<html>"
                                   @"<head>"
                                   @"<meta name = \"viewport\" content =\"initial-scale = 1.0, user-scalable = no, width = 1024\"/></head>"
                              @"<body style='margin:0'>"
                                   @"<iframe id=\"movie\" src=\"http://player.vimeo.com/video/%@?title=0&byline=0&autoplay=1&x-web-kit-airplay=allow\" webkit-playsinline x-webkit-airplay=\"allow\" width=\"1024\" height=\"576\" frameborder=\"0\"></iframe></body>"
                                   @"</html>",video_id];
    
  //    NSLog(@"HTML: %@", htmlString);
  self.webView.mediaPlaybackAllowsAirPlay = YES;
  [webView loadHTMLString:htmlString baseURL:nil];

}

-(void)playYouTube:(int)index {
  [self.controller.view removeFromSuperview];
  [self.webView setHidden:NO];
  [self.view bringSubviewToFront:self.webView];
  //  [self.view addSubview:self.controller.view];
  //[self.view bringSubviewToFront:self.controller.view];
  NSString *video_id;
  if (current_mode == 1){
    video_id = [[self.queue_items objectAtIndex:index] objectForKey:@"video_id"];
  } else if (current_mode == 2){
    video_id =   [[self.played_items objectAtIndex:index] objectForKey:@"video_id"];
  }
  NSString *htmlString;
   CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height > 760){
      htmlString = [NSString stringWithFormat:@"<html>"
                                   @"<head>"
                                   @"<meta name = \"viewport\" content =\"initial-scale = 1.0, user-scalable = no, width = 1024\"/></head>"
                              @"<body style='margin:0;background:black;'>"
                                   @"<iframe id=\"movie\" src=\"http://youtube.com/embed/%@?autoplay=1\" webkit-playsinline  x-webkit-airplay=\"allow\" width=\"1024\" height=\"576\" frameborder=\"0\"></iframe></body>"
                                   @"</html>",video_id];
    } else {
htmlString = [NSString stringWithFormat:@"<html>"
                                   @"<head>"
                                   @"<meta name = \"viewport\" content =\"initial-scale = 1.0, user-scalable = no, width = 320\"/></head>"
                              @"<body style='margin:0;background:black;'>"
                                   @"<iframe id=\"movie\" src=\"http://youtube.com/embed/%@?autoplay=1\" webkit-playsinline  x-webkit-airplay=\"allow\" width=\"320\" height=\"220\" frameborder=\"0\"></iframe></body>"
                                   @"</html>",video_id];
    }
    
  //    NSLog(@"HTML: %@", htmlString);
    [webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"http://www.youtube.com"]];
    
}


-(void)playVideo:(int)index mode:(int)current_mode{
  //  NSLog(@"Play at index %d", index);
  //  NSLog(@"currently playing %@", currentPlaying);
   
  current_index = index;
  current_play_mode = current_mode;
  NSString *video_id;
  NSString *type;
  NSObject *currentVid;
    
  if (current_mode == 1){
    currentVid = [self.queue_items objectAtIndex:index];
    video_id = [[self.queue_items objectAtIndex:index] objectForKey:@"video_id"];
    type = [[self.queue_items objectAtIndex:index] objectForKey:@"t"];
    // post play
    currently_playing = [self.queued_dict objectForKey:video_id];
        
  } else {
    currentVid = [self.played_items objectAtIndex:index];
    video_id = [[self.played_items objectAtIndex:index] objectForKey:@"video_id"];
    type = [[self.played_items objectAtIndex:index] objectForKey:@"t"];
    currently_playing = [self.played_dict objectForKey:video_id];

  }
  if (currentPlaying != nil){
    //NSLog(@"previous playing is: %@", currentPlaying);
    int remove_index = -1;
    [queueLock lock];
    for (int i = 0; i < [self.queue_items count]; i++){
      NSDictionary *obj = [self.queue_items objectAtIndex:i];
      NSString *vid = [obj objectForKey:@"video_id"];
      if ([vid isEqualToString:currentPlaying]){
        remove_index = i;
        break;
      }
    }
    if (remove_index > -1){
      [self.queue_items removeObjectAtIndex:remove_index];
    }
    [queueLock unlock];
  }
    

    
  if (video_id){
    currentPlaying = video_id;
    // [currentPlaying retain];
  }
  if (type == nil){
    return;
  }
    
  if ([type isEqualToString:@"youtube"]){
    //  [self playYouTube:index];
    [self.webView setHidden:YES];
    [self.controller.view removeFromSuperview];
    self.controller.delegate = nil;
      self.controller = nil;
    //[self.controller release];
    self.controller = [[LBYouTubePlayerViewController alloc] initWithYouTubeID:video_id quality:LBYouTubeVideoQualityLarge];
    self.controller.delegate = self;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height > 760){
      self.controller.view.frame = CGRectMake(0,0,1024, 576);//960,540);
    } else {
      self.controller.view.frame = CGRectMake(0,0,320,220); //screenBounds.size.height,220);
    }
    [self.view addSubview:self.controller.view];
    [self.view bringSubviewToFront:self.controller.view];
  } else if ([type isEqualToString:@"vimeo"]){
    [self hackVideo:video_id];
   //         [self playVimeo:index];
  }
    
    
  if (current_mode == 1){ 
    //  [self postPlay:self.user_name video_id:video_id];
    // remove this video from queue and add to head of play_history?
    // remove at index from play queue
    // we can push to history or it will just update magically from server
        
    NSObject *e = [played_dict objectForKey:video_id];
    if (!e){
      [played_items insertObject:currentVid atIndex:0];
      [played_dict setObject:currentVid forKey:video_id];
    }

    [self.gridView reloadData];
  }
  [self postPlay:self.user_name video_id:video_id];
  [self refresh];
}

-(void)postPlay:(NSString *)user video_id:(NSString *)video_id {
  //    NSLog(@"POST Play");
  // user_name - video_id
  NSString *urlString = [NSString stringWithFormat:@"http://dev.werhi.com/%@/played?id=%@", user, video_id];
  // NSString *urlString = @"http://app.werhi.com/";
  //    NSLog(@" video post: %@", urlString);
  NSURL* url = [[NSURL alloc] initWithString:urlString];

  NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
  [request setHTTPMethod:@"POST"];

    ASIFormDataRequest *requestP = [[ASIFormDataRequest alloc] initWithURL:url];
      [requestP startSynchronous];

     NSError *error = [requestP error];
      if (!error) {
          NSString *response = [requestP responseString];
//   NSLog(@"RESPONSE: %@", response);
      }

  /*
    NSMutableDictionary *played = [self.profile objectForKey:@"played"];
    NSMutableDictionary *length =  [played objectForKey:@"length"];
    NSNumber *number = [NSNumber numberWithInteger:[length integerValue]];
    number = [NSNumber numberWithInteger:[number intValue]+1];
  */
  played_length += 1;

  /*    dispatch_async(dispatch_get_main_queue(),^{
        [tabs removeFromSuperview];
        tabs = [[SlidingTabsControl alloc] initWithTabCount:3 delegate:self];
        [profileTabView addSubview:tabs];
        });*/

}

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
  NSLog(@"Did tap at index %d", position);
}

- (void)GMGridViewDidTapOnEmptySpace:(GMGridView *)gridView
{
  NSLog(@"Tap on empty space");
}

-(IBAction)videoSelected:(id)sender{
  UIButton *v = sender;
  //  always set mode to current mode on select
  // auto play uses whatever manual queue initiated the series

  // we also have to ignore the finish of the previous video
  /*    if (current_index > -1){
        ignoreOnChangeFinish = YES;
        }*/
  [self playVideo:v.tag mode:current_mode];
  // if queue is queue, move to first of played queue
}


-(IBAction)currentSelected:(id)sender {
  if (historyScrolling){
    [historyGridView setContentOffset:historyGridView.contentOffset animated:NO];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(currentSelected:) userInfo:nil     repeats:NO];
    return;
        
  }
  if (queueScrolling){
    [gridView setContentOffset:gridView.contentOffset animated:NO];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(currentSelected:) userInfo:nil     repeats:NO];
    return;
        
  }
  historyScrolling = NO;
  queueScrolling = NO;
  current_mode = 0;
  [shareButton setHidden:NO];
  [currentButton setSelected:YES];
  [queueButton setSelected:NO];
  [historyButton setSelected:NO];
  //  [currentButton setBackgroundColor:[UIColor colorWithRed:.22 green:.62 blue:.05 alpha:1.0]];
  //    [queueButton setBackgroundColor:[UIColor colorWithRed:.26 green:.26 blue:.26 alpha:1.0]];
  //    [historyButton setBackgroundColor:[UIColor colorWithRed:.26 green:.26 blue:.26 alpha:1.0]];
  [profileView setHidden:YES];
  [profileBackgroundView setHidden:YES];

  [self refresh];
}
-(IBAction)queueSelected:(id)sender {
  if (historyScrolling){
    [historyGridView setContentOffset:historyGridView.contentOffset animated:NO];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(queueSelected:) userInfo:nil     repeats:NO];
    return;

  }
  current_mode = 1;
  historyScrolling = NO;
  queueScrolling = NO;
  [currentButton setSelected:NO];
  [queueButton setSelected:YES];
  [historyButton setSelected:NO];
  [shareButton setHidden:YES];
  [gridView setHidden:NO];
  [historyGridView setHidden:YES];
  [profileView setHidden:YES];
  [profileBackgroundView setHidden:YES];
  [self refresh];


}

-(IBAction)historySelected:(id)sender {
  if (queueScrolling){
    [gridView setContentOffset:gridView.contentOffset animated:NO];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(historySelected:) userInfo:nil     repeats:NO];
    return;
        
  }
  historyScrolling = NO;
  queueScrolling = NO;
  current_mode = 2;
  [shareButton setHidden:YES];
  [currentButton setSelected:NO];
  [queueButton setSelected:NO];
  [historyButton setSelected:YES];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height > 760){
  [profileView setHidden:NO];
    }
  //[profileBackgroundView setHidden:NO];
  // 64, 1, 960, 190
  //    [self.gridView setBounds:CGRectMake(940-400,1,400,190)];
    
  [gridView setHidden:YES];
  [historyGridView setHidden:NO];
  [self refresh];
}

-(void)refresh {
  NSLog(@"**REFRESH: %d %@", current_mode, currently_playing);
  if (current_mode == 0){
    [self.gridView setHidden:YES];
    [self.historyGridView setHidden:YES];
    NSString *info = [currently_playing objectForKey:@"name"];
    if (info == nil){
      info = [currently_playing objectForKey:@"title"];
    }
    if (info != NULL){
      [self.video_title setText:info];
      [self.video_source setText:[currently_playing objectForKey:@"t"]];
      //  NSLog(@"Current desc: %@", [currently_playing objectForKey:@"desc"]);
      NSString *myHTML = [currently_playing objectForKey:@"desc"];
      NSString *style = @"<style>body{ font-family:helvetica;}</style>";
      NSString *html = [NSString stringWithFormat:@"%@%@",myHTML,style];
      [self.infoTextView loadHTMLString:html baseURL:nil];
      //[self.infoTextView setText:[currently_playing objectForKey:@"desc"]];
      [self.author setText:[currently_playing objectForKey:@"author"]];
    }
    [self.infoView setHidden:NO];
  } else {
    if (current_mode == 1){
      [self.gridView setHidden:NO];
      [self.historyGridView setHidden:YES];
      [self.gridView reloadData];
    } else if (current_mode == 2){
      [self.historyGridView setHidden:NO];
      [self.gridView setHidden:YES];
      [self.historyGridView reloadData];
    }
    [self.infoView setHidden:YES];
    [self.mainView bringSubviewToFront:self.buttonView];
    [self.view bringSubviewToFront:self.buttonView];
    [self.mainView sendSubviewToBack:self.gridView];

        
  }
}


- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
  int ret;
  if (current_mode == 1){
    [queueLock lock];
    ret =[self.queue_items count]+1;
    [queueLock unlock];
    return ret;
  } else if (current_mode ==2){
    //        NSLog(@"num play items %d", [self.played_items count]);
    if (profile_view_tab == 1){
      return [self.following_items count];
    }else if (profile_view_tab == 2){
      return [self.followers_items count];
    } else {
      return [self.played_items count];
    }
  } else {
    return 0; // info panel
  }

}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
     CGRect screenBounds = [[UIScreen mainScreen] bounds];
     if (screenBounds.size.height > 760){
         return CGSizeMake(288,162);
     } else {
         return CGSizeMake(160.0,90.0);
     }
}

-(GMGridViewCell *)create_add_video {
    UIImage* img = [UIImage imageNamed:@"more_videos@2x.png"];
    GMGridViewCell *cell = [[GMGridViewCell alloc] init];
    UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
    cell.contentView = view;
    [((UIButton *)view) setImage:img forState:UIControlStateNormal];
    ((UIButton *)view).contentMode = UIViewContentModeScaleAspectFit; //   UIViewContentModeScaleAspectFill;
    ((UIButton *)view).contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    ((UIButton *)view).contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    [((UIButton *)view) addTarget:self action:@selector(showFinder:) forControlEvents:UIControlEventTouchDown];
    return cell;
}

- (NSString *)timeFormatted:(int)totalSeconds
{
  //    NSLog(@"Format time %d", totalSeconds);
  int seconds = totalSeconds % 60;
  int minutes = (totalSeconds / 60) % 60;
  int hours = totalSeconds / 3600;
  if (hours > 0){
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
  } else {
    return [NSString stringWithFormat:@"%02d:%02d",minutes, seconds];
  }
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gview cellForItemAtIndex:(NSInteger)index
{


  CGRect screenBounds = [[UIScreen mainScreen] bounds];
  NSString *thumb;
  NSString *title;
  NSString *friend = nil;
  NSString *duration = @"0";
  int start_mode = current_mode;
  UIView *friend_view = nil; 
  NSString *friend_name = nil;
  if (current_mode == 1){
    //        NSLog(@"Load count: %d %d", [self.queue_items count]);
    if (index == [self.queue_items count]){
      return [self create_add_video];
    } else {
      [queueLock lock];
      thumb = [[self.queue_items objectAtIndex:index] objectForKey:@"poster"];
      title = [[self.queue_items objectAtIndex:index] objectForKey:@"name"];
      friend = [[[self.queue_items objectAtIndex:index] objectForKey:@"from"] objectForKey:@"profile_image"];
      friend_name = [[[self.queue_items objectAtIndex:index] objectForKey:@"from"] objectForKey:@"user"];
      NSString *time = [[self.queue_items objectAtIndex:index] objectForKey:@"duration"];
      duration = [self timeFormatted:[time intValue]];
      [queueLock unlock];
    }
  } else if (current_mode == 2){
    if (profile_view_tab == 1){
      thumb = [[self.following_items objectAtIndex:index] objectForKey:@"poster"];
      title = [[self.following_items objectAtIndex:index] objectForKey:@"name"];
      // friend = [[[self.following_items objectAtIndex:index] objectForKey:@"friend"] objectForKey:@"profile_image"];
    }
    else if (profile_view_tab == 2){
      thumb = [[self.followers_items objectAtIndex:index] objectForKey:@"poster"];
      title = [[self.followers_items objectAtIndex:index] objectForKey:@"name"];
      //friend = [[[self.followers_items objectAtIndex:index] objectForKey:@"friend"] objectForKey:@"profile_image"];
    } else {
      thumb = [[self.played_items objectAtIndex:index] objectForKey:@"poster"];
      title = [[self.played_items objectAtIndex:index] objectForKey:@"name"];
      friend = [[[self.played_items objectAtIndex:index] objectForKey:@"from"] objectForKey:@"profile_image"];
      friend_name = [[[self.played_items objectAtIndex:index] objectForKey:@"from"] objectForKey:@"user"];
      //  duration = [[self.played_items objectAtIndex:index] objectForKey:@"duration"];
      NSString *time = [[self.played_items objectAtIndex:index] objectForKey:@"duration"];
      duration = [self timeFormatted:[time intValue]];

    }
  }


 // CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = nil; //[gview dequeueReusableCell];
  UIButton *view;
  if (cell == nil){
    cell = [[GMGridViewCell alloc] init];
//    NSLog(@"CREATE new cell");
    view = [UIButton buttonWithType:UIButtonTypeCustom];
    cell.contentView = view;
  } else {
    view = cell.contentView;
    [((UIButton *)view) removeTarget:nil action:NULL forControlEvents:UIControlEventTouchDown];        
  }
  //    UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
  //    cell.contentView = view;
    
  if (friend != nil){
     friend_view = [[UIView alloc] initWithFrame:CGRectMake(0,0,220.0f,40.0f)];
    //CGRect a = CGRectMake(0,5.0f,90.0f, 90.0f);
    //[friend_view setBounds:a];
    //friend_view.alpha = 1.0;
    //[friend_view setFrame:a];

    UILabel *_label = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 100, 40)];
    _label.backgroundColor = [UIColor blackColor];
    _label.textAlignment = UITextAlignmentCenter;
    _label.font = [UIFont fontWithName:@"Helvetica" size:14]; //[label.font fontWithSize:14];
    [_label setTextColor:[UIColor whiteColor]];
    [_label setText:[NSString stringWithFormat:@"from %@", friend_name]];
    [friend_view addSubview:_label];
    //[view addSubview:friend_view];
  }
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      if (current_mode != start_mode){
        //NSLog(@"initial mode changed ignore this?");
        return;
      }

      NSData *imageData = nil;
      if (friend != nil){
        NSURL *imageURL = [NSURL URLWithString:friend];
        //          NSLog(@"load friend profile; %@", friend);
          NSLog(@"set image for friend %@", friend);
        NSError* error = nil;
        imageData = [NSData dataWithContentsOfURL:imageURL options:NSDataReadingMappedIfSafe error:&error];
      }

      

      // NSLog(@"get url: %@", url);
      if (current_mode != start_mode){
        //NSLog(@"pre urlmode changed ignore this?");
        if (imageData != nil){
          //[imageData release];
        }
        return;
      }
      NSError* error = nil;
      NSURL *url = [NSURL URLWithString:thumb];
      NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&error];
      dispatch_async(dispatch_get_main_queue(),^{
          UIImage *img = [[UIImage alloc] initWithData:data];
          NSLog(@"set friend image: %@", img);
          [((UIButton *)view) setImage:img forState:UIControlStateNormal];
          if (imageData){
            NSLog(@"create friend button");
            UIImage *image = [UIImage imageWithData:imageData];
            UIImageView *myImageView = [[UIImageView alloc] initWithImage:image];
            myImageView.contentMode = UIViewContentModeScaleAspectFit; //   UIViewContentModeScaleAspectFill;

            [myImageView setFrame:CGRectMake(0, 0, 40, 40)];
            [friend_view addSubview:myImageView];
            //[myImageView release];
            //[((UIButton *)friend_view) setImage:img2 forState:UIControlStateNormal];
            // [image release];
          }
          /*if (current_mode != start_mode){
              //NSLog(@"mode changed ignore this?");
              // [img release];
              //                [data release];
              img = nil;
              return;
          }*/
        });
    });
  CGRect r;
//    NSLog(@"%@", NSStringFromCGRect(screenBounds));

    UIView *lview, *dview;
  if (screenBounds.size.height > 760){
    r = CGRectMake(0, 0, 288.0f, 162.0f);
       lview = [[UIView alloc] initWithFrame:CGRectMake(0,122,288.0f,40.0f)];
      dview = [[UIView alloc] initWithFrame:CGRectMake(220,0,68.0f,40.0f)];
  } else {
    r = CGRectMake(0,5.0f,120.0f, 90.0f);
       lview = [[UIView alloc] initWithFrame:CGRectMake(0,122,120.0f,40.0f)];
      dview = [[UIView alloc] initWithFrame:CGRectMake(122,5,38.0f,20.0f)];
  }
  [view setBounds:r];
  [view setFrame:r];
        
  view.tag = index;
   
  ((UIButton *)view).contentMode = UIViewContentModeScaleAspectFit; //   UIViewContentModeScaleAspectFill;
  ((UIButton *)view).contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
  ((UIButton *)view).contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
   
 
  [lview setAlpha:.9];
  [lview setBackgroundColor:[UIColor darkGrayColor]];
    
  UILabel *label = [[UILabel alloc] initWithFrame:lview.bounds];
  label.backgroundColor = [UIColor clearColor];
  label.textAlignment = UITextAlignmentCenter;
  label.font = [UIFont fontWithName:@"Helvetica" size:14]; //[label.font fontWithSize:14];
  [label setTextColor:[UIColor whiteColor]];
  [label setText:title];
  [lview addSubview:label];
  [view addSubview:lview];
    
  
  [dview setAlpha:.9];
  [dview setBackgroundColor:[UIColor blackColor]];
    
  UILabel *dl = [[UILabel alloc] initWithFrame:dview.bounds];
  dl.backgroundColor = [UIColor clearColor];
  dl.textAlignment = UITextAlignmentCenter;
    if (screenBounds.size.height > 760){
         label.font = [UIFont fontWithName:@"Helvetica" size:14]; //[label.font fontWithSize:14];
  dl.font = [UIFont fontWithName:@"Helvetica" size:14]; //[label.font fontWithSize:14];
    } else {
         label.font = [UIFont fontWithName:@"Helvetica" size:10]; //[label.font fontWithSize:14];
        dl.font = [UIFont fontWithName:@"Helvetica" size:10]; //[label.font fontWithSize:14];

    }
  [dl setTextColor:[UIColor whiteColor]];
  //    NSLog(@"set duration %@", duration);
  [dl setText:duration];
  [dview addSubview:dl];
  [view addSubview:dview];
    
  [((UIButton *)view) addTarget:self action:@selector(videoSelected:) forControlEvents:UIControlEventTouchDown];
  [[view layer] setBorderWidth:2.0f];
  [[view layer] setBorderColor:[UIColor grayColor].CGColor];
  if (friend != nil){
    // ((UIButton *)friend_view).contentMode = UIViewContentModeScaleAspectFit; //   UIViewContentModeScaleAspectFill;
    //((UIButton *)friend_view).contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    //((UIButton *)friend_view).contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    [view addSubview:friend_view];
  }

  return cell;
}


- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
  return NO;
}

- (void)GMGridView:(GMGridView *)gridView didStartMovingCell:(GMGridViewCell *)cell
{

  if (current_mode == 1){
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
        cell.contentView.backgroundColor = [UIColor orangeColor];
        cell.contentView.layer.shadowOpacity = 0.7;
      }
    completion:nil
     ];
  }
}

- (void)GMGridView:(GMGridView *)gridView didEndMovingCell:(GMGridViewCell *)cell
{
  if (current_mode == 1){
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
        //   cell.contentView.backgroundColor = [UIColor redColor];
        cell.contentView.layer.shadowOpacity = 0;
      }
    completion:nil
     ];
  }
}

- (BOOL)GMGridView:(GMGridView *)gridView shouldAllowShakingBehaviorWhenMovingCell:(GMGridViewCell *)cell atIndex:(NSInteger)index
{
  return YES;
}

- (void)GMGridView:(GMGridView *)gridView moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex
{
  //NSLog(@"Move item at index");
  //    NSObject *object = [_currentData objectAtIndex:oldIndex];
  //    [_currentData removeObject:object];
  //    [_currentData insertObject:object atIndex:newIndex];
}

- (void)GMGridView:(GMGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2
{
  // [_currentData exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
}

-(void)setBackground {
  background = YES;
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
  [self dismissModalViewControllerAnimated:YES];

}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  //    NSLog(@"ACTION sheet %d", buttonIndex);
  NSString *name = [currently_playing valueForKey:@"name"];
  // NSString *video_id = [currently_playing valueForKey:@"video_id"];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      //        NSLog(@"call get shorty");
      NSString *shorty = [self getShorty];
      //        NSLog(@"shorty %@", shorty);
      dispatch_async(dispatch_get_main_queue(),^{
          if (buttonIndex == 1){
            if([TWTweetComposeViewController canSendTweet]) {
              TWTweetComposeViewController *controller = [[TWTweetComposeViewController alloc] init];
              [controller setInitialText:[NSString stringWithFormat:@"Check out %@ via @addtocouch #Couch", name]];
              //[controller setInitialText:[NSString stringWithFormat:@"#addtocouch %@",name]];
              [controller addURL:[NSURL URLWithString:shorty]];
              [self presentViewController:controller animated:YES completion:nil];
            } else {
              //                NSLog(@"DCan't send tweet");
            
            }
          }else if (buttonIndex == 0){
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            NSString *subject = [NSString stringWithFormat:@"%@ wants you to see “%@” on Couch",
                                          [self.profileName text],name];
            [picker setSubject:subject];

            NSString *emailBody =
              [NSString stringWithFormat:@"%@ is using <a href='http://addtocouch.com'>Couch</a> to save and watch great videos from around the web. %@", [self.profileName text],shorty];
                
            [picker setMessageBody:emailBody isHTML:YES]; // depends. Mostly YES, unless you want to send it as plain text (boring)
                
            picker.navigationBar.barStyle = UIBarStyleBlack; // choose your style, unfortunately, Translucent colors behave quirky.
                
            [self presentModalViewController:picker animated:YES];
            //[picker release];
                
          }
          else if (buttonIndex == 2) {
            [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:true];
          }
        });
    });
}

-(IBAction)share:(id)sender {
  if (currently_playing != nil){
    //    NSLog(@"Share %@", currently_playing);
    // hit the server and get the URL for this video_id

    // popup a dialog with a share links
    UIActionSheet *sheet = [[UIActionSheet alloc]
                              initWithTitle:@"Share the Couch"
                                   delegate:self
                             cancelButtonTitle:nil
                             destructiveButtonTitle:nil
                             otherButtonTitles:nil];
      
    [sheet addButtonWithTitle:@"Email"];
    [sheet addButtonWithTitle:@"Tweet"];
    [sheet addButtonWithTitle:@"Cancel"];
      
    // sheet.cancelButtonIndex = sheet.numberOfButtons-1;
      
    [sheet showInView:self.view];
    //[sheet release];
  }
}



@end
