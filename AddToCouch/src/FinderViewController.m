//
//  FinderViewController.m
//  AddToCouch
//
//  Created by Rich Schiavi on 11/24/12.
//  Copyright (c) 2012 MOG. All rights reserved.
//

#import "FinderViewController.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "ASIFormDataRequest.h"
#import "SVProgressHUD.h"
@interface FinderViewController ()

@end

@implementation FinderViewController


@synthesize doneButton;
@synthesize gridView;
@synthesize popularGridView;
@synthesize hot_queue;
@synthesize hot_dict;
@synthesize popular_queue,friend_queue;
@synthesize popular_dict,friend_dict;
@synthesize friendGridView;

UIPopoverController *popover;
UIViewController *controller;
NSString *user_name;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   // [SVProgressHUD show];
    
    self.title = @"Add Videos";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];

    self.hot_queue = [NSMutableArray array];
    self.hot_dict = [NSMutableDictionary dictionary];
    self.popular_queue = [NSMutableArray array];
    self.popular_dict = [NSMutableDictionary dictionary];
    self.friend_queue = [NSMutableArray array];
    self.friend_dict = [NSMutableDictionary dictionary];


    
    [self setUpGrid:gridView];
    [self setUpGrid:popularGridView];
    [self setUpGrid:friendGridView];


    //    [self.view sendSubviewToBack:self.gridView];

    NSLog(@"Finder LOAD");
    [self getHot];
 //   [self getPopular];
    

}

-(void)setUpGrid:(GMGridView *)gridView1 {
    gridView1.centerGrid = YES;
    gridView1.minEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    gridView1.actionDelegate = self;
    gridView1.sortingDelegate = self;
    gridView1.dataSource = self;
    gridView1.clipsToBounds = YES;
    gridView1.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutHorizontal];
    gridView1.contentSize = CGSizeMake(gridView1.contentSize.width,182.0);
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height < 760){
      gridView1.minEdgeInsets = UIEdgeInsetsMake(1, 1, 1, 1);
      gridView1.itemSpacing = 1;
    }

}

-(void)getHot {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *u = @"http://dev.werhi.com/tag/hot";
        NSLog(@"=====>get hot %@", u);
        NSURLRequest *request = [NSURLRequest requestWithURL:
                                        [NSURL URLWithString:u]];
        [[NSURLConnection alloc] initWithRequest:request delegate:self];
        NSURLResponse *theResponse =[[NSURLResponse alloc]init];
        NSError *errorReturned = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&theResponse error:&errorReturned];
        if (errorReturned) {
            NSLog(@"get hot ERROR %@", errorReturned);
            [self getPopular];

        }
        else {
          NSLog(@"=====>GOT HOT RESULTS");
          NSError *jsonParsingError = nil;
          NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonParsingError];
          NSArray *data = [res objectForKey:@"data"];
           int found_new = NO;
          NSEnumerator *e = [data objectEnumerator];   
          id object;
          NSLog(@"GOT HOT RESULTS PARSED");
          while (object = [e nextObject]){
            NSString *video_id = [object objectForKey:@"video_id"];
            NSString *type = [object objectForKey:@"t"];
            NSObject *e = [hot_dict objectForKey:video_id];
            if (video_id){
              if ((!e) && (!([type isEqualToString:@"undefined"]))){
                [hot_queue addObject:object];
                found_new = YES;
                [hot_dict setObject:object forKey:video_id];

              }
            }
          }
          dispatch_async(dispatch_get_main_queue(),^{
                [SVProgressHUD dismiss];
               [self.gridView reloadData]; 
              [self getPopular];


            });
        }
      });
}


-(void)getPopular {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *u = @"http://dev.werhi.com/popular";
        NSLog(@"get popular %@", u); //
      
        NSURLRequest *request = [NSURLRequest requestWithURL:
                                        [NSURL URLWithString:u]];
        [[NSURLConnection alloc] initWithRequest:request delegate:self];
        NSURLResponse *theResponse =[[NSURLResponse alloc]init];
        NSError *errorReturned = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&theResponse error:&errorReturned];
        if (errorReturned) {
            NSLog(@"ERROR ON POPULAR %@", errorReturned);
        }
        else {
            NSLog(@"got results popular");
          NSError *jsonParsingError = nil;
          NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonParsingError];
          NSArray *data = [res objectForKey:@"data"];
          int found_new = NO;
          NSEnumerator *e = [data objectEnumerator];   
          id object;
          //NSLog(@"popular array %d", [data count]);
          while (object = [e nextObject]){
            NSString *video_id = [object objectForKey:@"video_id"];
            NSString *type = [object objectForKey:@"t"];
            NSObject *e = [popular_dict objectForKey:video_id];

            if (video_id){
              if ((!e) && (!([type isEqualToString:@"undefined"]))){
                [popular_queue addObject:object];
                found_new = YES;
                [popular_dict setObject:object forKey:video_id];

              }
            }
          }
          
          //NSLog(@"popular new %d", found_new);
          dispatch_async(dispatch_get_main_queue(),^{
              [SVProgressHUD dismiss];
                  [self.popularGridView reloadData];
          });

        }
      });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setPopover:(UIPopoverController *)p {
  /*  if (self.popover) {
        [self.popover release];
    }*/
  //NSLog(@"set popover %@", popover);
   // popover = [p retain];
}

-(void)setController:(UIViewController *)v{
    //controller = [v retain];
}

- (IBAction)dismiss
{
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

-(IBAction)close:(id)sender {
    [popover dismissPopoverAnimated:YES];
    //[controller popoverControllerDidDismissPopover:sender];
}

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{

  if (gridView == self.gridView){
    NSMutableDictionary *obj = [hot_queue objectAtIndex:position];
    //    NSLog(@"--->Found object %@", [obj class]);
    // add to queue
    [hot_queue removeObjectAtIndex:position];
    NSString *url = [NSString stringWithFormat:@"http://dev.werhi.com/%@/queue/%@",
                              user_name,
                             [obj objectForKey:@"video_id"]];
    //    NSLog(@"post queue %@", url);
    [self postQueue:url];
    [self.gridView reloadData];
  }
  else if (gridView == self.friendGridView){
      NSMutableDictionary *obj = [friend_queue objectAtIndex:position];

      //      NSLog(@"--->Found object %@", [obj class]);
      // add to queue
      [friend_queue removeObjectAtIndex:position];
      NSString *url = [NSString stringWithFormat:@"http://dev.werhi.com/%@/queue/%@",
                       user_name,
                       [obj objectForKey:@"video_id"]];
      //      NSLog(@"post queue %@", url);
      [self postQueue:url];
      [self.friendGridView reloadData];

  } else {
    NSMutableDictionary *obj = [popular_queue objectAtIndex:position];
    //    NSLog(@"--->Found object %@", [obj class]);
    // add to queue
    [popular_queue removeObjectAtIndex:position];
    NSString *url = [NSString stringWithFormat:@"http://dev.werhi.com/%@/queue/%@",
                              user_name,
                             [obj objectForKey:@"video_id"]];
    //    NSLog(@"post queue %@", url);
    [self postQueue:url];
    [self.popularGridView reloadData];
  }
}

-(IBAction)videoSelected:(id)sender{
}

- (void)GMGridViewDidTapOnEmptySpace:(GMGridView *)gridView {}
- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
  //    NSLog(@"items in gridview");
  if (gridView == self.gridView){
    return [hot_queue count];
  } else if (gridView == self.friendGridView){
    //      NSLog(@" items in friend grid: %d", [friend_queue count]);
      return [friend_queue count];
  } else {
    return [popular_queue count];
  }
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
     CGRect screenBounds = [[UIScreen mainScreen] bounds];
     if (screenBounds.size.height > 760){
       return CGSizeMake(288,162);
     } else {
         return CGSizeMake(180.0,100.0);
     }
}

- (GMGridViewCell *)GMGridView:(GMGridView *)lgridView cellForItemAtIndex:(NSInteger)index
{
  NSDictionary *video;
  UIView *friend_view = nil; 
  NSString *friend_name = nil;
  NSString *friend = nil;
  if (lgridView == self.gridView){
    video = [hot_queue objectAtIndex:index];
  } else if (lgridView == self.friendGridView){
      video = [friend_queue objectAtIndex:index];
      //      NSLog(@"FRIEND QUEUE: %@", video);
      friend = [[video objectForKey:@"from"] objectForKey:@"profile_image"];
      friend_name = [[video objectForKey:@"from"] objectForKey:@"user"];
      //      NSLog(@"found friend %@", friend_name);
  } else {
    video = [popular_queue objectAtIndex:index];
  }
  CGRect screenBounds = [[UIScreen mainScreen] bounds];
  NSString *thumb;
  NSString *title;

  NSString *duration = @"0";
    

  thumb = [video objectForKey:@"poster"];
  title = [video objectForKey:@"name"];
  NSString *time = [video objectForKey:@"duration"];
  duration = [self timeFormatted:[time intValue]];

  //CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
  GMGridViewCell *cell = [gridView dequeueReusableCell];
  //GMGridViewCell *cell = [[GMGridViewCell alloc] init];
    UIView *view = nil;
  if (cell == nil){
    cell = [[GMGridViewCell alloc] init];
   // NSLog(@"CREATE new cell");
    view = [UIButton buttonWithType:UIButtonTypeCustom];
    cell.contentView = view;
  } else {
    view = cell.contentView;
    [((UIButton *)view) removeTarget:nil action:NULL forControlEvents:UIControlEventTouchDown];        
  }
//  UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImageView *addView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add_to_queue"]];
   addView.frame = CGRectMake(238.0, 0.0, 50.0,50.0);
//  cell.contentView = view;
    if (friend != nil){
      if (screenBounds.size.height > 760){
        friend_view = [[UIView alloc] initWithFrame:CGRectMake(0,0,220.0f,40.0f)];
      } else {
        friend_view = [[UIView alloc] initWithFrame:CGRectMake(0,5,120.0f,40.0f)];
      }


        UILabel *_label = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 100, 40)];
        _label.backgroundColor = [UIColor blackColor];
        _label.textAlignment = UITextAlignmentCenter;
        _label.font = [UIFont fontWithName:@"Helvetica" size:14]; //[label.font fontWithSize:14];
        [_label setTextColor:[UIColor whiteColor]];
        [_label setText:[NSString stringWithFormat:@"from %@", friend_name]];
        [friend_view addSubview:_label];
        [view addSubview:friend_view];
    }
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = nil;
      if (friend != nil){
          NSURL *imageURL = [NSURL URLWithString:friend];
          //          NSLog(@"load friend profile; %@", friend);
          imageData = [NSData dataWithContentsOfURL:imageURL];
        }
       NSURL *url = [NSURL URLWithString:thumb];
      NSData *data = [NSData dataWithContentsOfURL:url];
      UIImage *img = [[UIImage alloc] initWithData:data];
        UIImage *img2 = nil;
        if (friend != nil){
            img2 = [[UIImage alloc] initWithData:imageData];
        }
      dispatch_async(dispatch_get_main_queue(),^{
          [((UIButton *)view) setImage:img forState:UIControlStateNormal];
           if (imageData){
              //              NSLog(@"create friend button");
              UIImage *image = [UIImage imageWithData:imageData];
              UIImageView *myImageView = [[UIImageView alloc] initWithImage:image];
              myImageView.contentMode = UIViewContentModeScaleAspectFit; //   UIViewContentModeScaleAspectFill;
                [myImageView setFrame:CGRectMake(0, 0, 40, 40)];

                
              [friend_view addSubview:myImageView];
              //[myImageView release];
              //[((UIButton *)friend_view) setImage:img2 forState:UIControlStateNormal];

            }
         });
    });
  CGRect r;
  if (screenBounds.size.height > 760){
    r = CGRectMake(0, 0, 288.0f, 162.0f);
  } else {
    r = CGRectMake(0,5.0f,120.0f, 90.0f);
  }
  [view setBounds:r];
  [view setFrame:r];
        
  view.tag = index;
   
  ((UIButton *)view).contentMode = UIViewContentModeScaleAspectFit;
  ((UIButton *)view).contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
  ((UIButton *)view).contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
   
  UIView *lview = [[UIView alloc] initWithFrame:CGRectMake(0,122,288.0f,40.0f)];
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
    
  UIView *dview = [[UIView alloc] initWithFrame:CGRectMake(174,0,68.0f,50.0f)];
  [dview setAlpha:.9];
  [dview setBackgroundColor:[UIColor blackColor]];
    
  UILabel *dl = [[UILabel alloc] initWithFrame:dview.bounds];
  dl.backgroundColor = [UIColor clearColor];
  dl.textAlignment = UITextAlignmentCenter;
  dl.font = [UIFont fontWithName:@"Helvetica" size:16]; //[label.font fontWithSize:14];
  [dl setTextColor:[UIColor whiteColor]];
  [dl setText:duration];
  [dview addSubview:dl];
  //  [dview addSubview:addView];
  if (screenBounds.size.height > 760){
  [view addSubview:dview];
    [view addSubview:addView];
  }
    
  //  [((UIButton *)view) addTarget:self action:@selector(videoSelected:) forControlEvents:UIControlEventTouchDown];
  [[view layer] setBorderWidth:2.0f];
  [[view layer] setBorderColor:[UIColor grayColor].CGColor];

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

-(void)postQueue:(NSString *)urlString {
   NSURL* url = [[NSURL alloc] initWithString:urlString];
   NSLog(@"post queue: %@", url);
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    ASIFormDataRequest *requestP = [[ASIFormDataRequest alloc] initWithURL:url]; 
    [requestP startSynchronous];
    NSError *error = [requestP error];
    if (!error) {
        NSString *response = [requestP responseString];
        NSLog(@"RESPONSE: %@", response);
    }
   
}

-(void)getFriends {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *u = [NSString stringWithFormat:@"http://dev.werhi.com/%@/suggest/network", user_name];
        NSLog(@"------>get friends %@", u); //
        NSURLRequest *request = [NSURLRequest requestWithURL:
                                 [NSURL URLWithString:u]];
        [[NSURLConnection alloc] initWithRequest:request delegate:self];
        NSURLResponse *theResponse =[[NSURLResponse alloc]init];
        NSError *errorReturned = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&theResponse error:&errorReturned];
        if (errorReturned) {
            NSLog(@"error on friend: %@", errorReturned);
        }
        else {
            NSError *jsonParsingError = nil;
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonParsingError];
            NSArray *data = [res objectForKey:@"data"];
            int found_new = NO;
            NSEnumerator *e = [data objectEnumerator];
            id object;
            NSLog(@"friends array %d", [data count]);
            while (object = [e nextObject]){
                NSString *video_id = [object objectForKey:@"video_id"];
                NSString *type = [object objectForKey:@"t"];
                NSObject *e = [friend_dict objectForKey:video_id];
                
                if (video_id){
                    if ((!e) && (!([type isEqualToString:@"undefined"]))){
                        [friend_queue addObject:object];
                        found_new = YES;
                        [friend_dict setObject:object forKey:video_id];
                        
                    }
                }
            }
            
            NSLog(@"friends new %d", found_new);
            dispatch_async(dispatch_get_main_queue(),^{
                if (found_new) { NSLog(@"friend grid reload");[self.friendGridView reloadData]; }
            });
        }
    });
    
}

-(void)setUser:(NSString *)u {
    user_name = u; //[u retain];
    NSLog(@"SET USER: %@", user_name);
    [self getFriends];
 // [self getHot];
}


@end
