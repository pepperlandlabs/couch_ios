//
//  LBYouTubePlayerController.m
//  LBYouTubeView
//
//  Created by Laurin Brandner on 29.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LBYouTubePlayerController.h"

@interface LBYouTubePlayerController () 

@property (nonatomic, strong) MPMoviePlayerController* videoController;
@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) AVPlayerLayer *avPlayerLayer;


-(void)_setup;

@end
@implementation LBYouTubePlayerController

@synthesize videoController,avPlayer,avPlayerLayer;

#pragma mark Initialization

-(id)init {
    self = [super init];
    if (self) {
        [self _setup];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _setup];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _setup];
    }
    return self;
}

-(void)_setup {
    self.backgroundColor = [UIColor blackColor];
}

#pragma mark -
#pragma mark Other Methods

-(void)loadVideo:(NSURL *)URL{
  
 // NSLog(@"LOAD VIDEO %@", URL);
    if (self.videoController) {
        [self.videoController stop];
        [self.videoController.view removeFromSuperview];
        self.videoController = nil;
        //[self.videoController setContentURL:URL];
    }
        self.videoController = [[MPMoviePlayerController alloc] init] ; //]initWithContentURL:URL];
        [self.videoController setMovieSourceType:MPMovieSourceTypeStreaming];
    [self.videoController setContentURL:URL];
    self.videoController.useApplicationAudioSession = NO;
        [self.videoController setAllowsAirPlay:YES];
        self.videoController.view.frame = self.bounds;
    //    self.videoController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.videoController.view];
       
    [self.videoController prepareToPlay];
   
    //    NSLog(@"DONE LOAD VIDEO");
      
}



-(void)loadYouTubeVideo:(NSURL *)URL {

    if (self.videoController) { [self.videoController stop];
        [self.videoController.view removeFromSuperview];
        self.videoController = nil;
    }

    self.videoController = [[MPMoviePlayerController alloc] init] ; //]initWithContentURL:URL];
    [self.videoController setMovieSourceType:MPMovieSourceTypeStreaming];

    [self.videoController setContentURL:URL];
    [self.videoController prepareToPlay];
    self.videoController.useApplicationAudioSession = NO;
    [self.videoController setAllowsAirPlay:YES];
    self.videoController.view.frame = self.bounds;
    
    self.videoController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.videoController.view];
   /* [[NSNotificationCenter defaultCenter] addObserver:self
                                        selector:@selector(playbackStateChanged)
                                        name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];*/

}



#pragma mark -

@end
