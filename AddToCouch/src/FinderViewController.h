//
//  FinderViewController.h
//  AddToCouch
//
//  Created by Rich Schiavi on 11/24/12.
//  Copyright (c) 2012 MOG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMGridViewLayoutStrategies.h"
#import "GMGridView.h"

@interface FinderViewController : UIViewController {
    IBOutlet UIButton *doneButton;
    IBOutlet GMGridView *gridView;
    IBOutlet GMGridView *popularGridView;
    IBOutlet GMGridView *friendGridView;


   
}
@property (nonatomic, retain) NSMutableArray *hot_queue;
@property (nonatomic, retain) NSMutableDictionary *hot_dict;
@property (nonatomic, retain) NSMutableArray *popular_queue;
@property (nonatomic, retain) NSMutableDictionary *popular_dict;
@property (nonatomic, retain) NSMutableArray *friend_queue;
@property (nonatomic, retain) NSMutableDictionary *friend_dict;


@property (nonatomic, retain) IBOutlet GMGridView *gridView;
@property (nonatomic, retain) IBOutlet GMGridView *popularGridView;
@property (nonatomic, retain) IBOutlet GMGridView *friendGridView;


@property (nonatomic, retain) IBOutlet UIButton *doneButton;
//@property (nonatomic, retain) UIPopoverController *popover;

-(IBAction)close:(id)sender;
-(void)setPopover:(UIPopoverController *)p;
-(void)setController:(UIViewController *)v;
-(void)setUser:(NSString *)u;
-(void)initTwitter;
@end
