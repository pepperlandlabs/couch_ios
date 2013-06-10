//
//  LBYouTubePlayerController.m
//  LBYouTubeView
//
//  Created by Marco Muccinelli on 11/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LBYouTubePlayerViewController.h"
#import "LBYouTubeExtractor.h"

@interface LBYouTubePlayerViewController ()

@property (nonatomic, strong) LBYouTubePlayerController* view;
@property (nonatomic, strong) LBYouTubeExtractor* extractor;

-(void)_setupWithYouTubeURL:(NSURL*)URL quality:(LBYouTubeVideoQuality)quality;

-(void)_loadVideoWithURL:(NSURL *)videoURL;

-(void)_didSuccessfullyExtractYouTubeURL:(NSURL*)videoURL;
-(void)_failedExtractingYouTubeURLWithError:(NSError*)error;

@end
@implementation LBYouTubePlayerViewController

@synthesize view, delegate, extractor;

#pragma mark

-(LBYouTubePlayerController*)view {
    if (view) {
        return view;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(movieFinishedCallback:) 
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
 
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackStateChanged)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    self.view = [LBYouTubePlayerController new];
    return view;
}

-(void)end {
//  NSLog(@"end controller");
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) dealloc {
  //NSLog(@"REMOVE LB TUBE OBSERVER");
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  //[super dealloc];
}

#pragma mark -
#pragma mark Initialization

-(id)initWithYouTubeURL:(NSURL *)URL quality:(LBYouTubeVideoQuality)quality {
    self = [super init];
    if (self) {
        [self _setupWithYouTubeURL:URL quality:quality];
    }
    return self;
}

-(id)initWithYouTubeID:(NSString *)youTubeID quality:(LBYouTubeVideoQuality)quality {
    self = [super init];
    if (self) {
        [self _setupWithYouTubeURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", youTubeID]] quality:quality];
    }
    
    return self;
}

-(id)initWithString:(NSString *)video_url {
//  NSLog(@"---->INIT WITH STRING %@", video_url);
    self = [super init];
    if (self){
        if (self.view == nil){
//            self.view = [LBYouTubePlayerController alloc];
//            self.view.videoController = [MP]
        }
  
        [self.view loadYouTubeVideo:[NSURL URLWithString:video_url]];
        //        NSLog(@"B %@", self.view.videoController);
            //[self.view.videoController  setContentURL:[NSURL URLWithString:video_url]];
        /*        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(movieFinishedCallback:) 
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:nil];
 
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playbackStateChanged)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];*/
    }
    return self;
}

-(void)pause {
  if (self.view != nil){
    [self.view.videoController pause];
  }

}
-(void)play {
  if (self.view != nil){
    [self.view.videoController play];
  }
}

-(void)_setupWithYouTubeURL:(NSURL *)URL quality:(LBYouTubeVideoQuality)quality {
  //NSLog(@"************_SETUP WITH YOUTUBE URL************");
    self.view = nil;
    self.delegate = nil;
    
    self.extractor = [[LBYouTubeExtractor alloc] initWithURL:URL quality:quality];
    self.extractor.delegate = self;
    [self.extractor startExtracting];
    /*    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(movieFinishedCallback:) 
                                             name:MPMoviePlayerPlaybackDidFinishNotification
                                           object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackStateChanged)
                                             name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];*/
}

- (void) movieFinishedCallback:(NSNotification*) aNotification {
    MPMoviePlayerController *player = [aNotification object];

    if ([self.delegate respondsToSelector:@selector(youTubePlayerViewController:movieFinished:)]){
    //  NSLog(@"-----> movie finished %@",player);
//        NSLog(@"---->call movie finished delegate");
        [self.delegate youTubePlayerViewController:self movieFinished:self.view.videoController];
    }
}

- (void) playbackStateChanged {
    
   // NSLog(@"VIDEO CHANGE: %d", self.view.videoController.playbackState);
//    NSLog(@"VIDEO: %d", self.view.videoController.isFullscreen);
//    NSLog(@"VIDEO airplay? %d", self.view.videoController.isAirPlayVideoActive);
//    [self videoStateChanged:self.view];
//    NSLog(@"---------->[LBYouTube] Video state changed");
    if ([self.delegate respondsToSelector:@selector(youTubePlayerViewController:videoStateChanged:)]){
        [self.delegate youTubePlayerViewController:self videoStateChanged:self.view.videoController];
    }

    
}

#pragma mark - 
#pragma mark Private

-(void)_loadVideoWithURL:(NSURL *)videoURL {
    [self.view loadYouTubeVideo:videoURL];
}

#pragma mark -
#pragma mark Delegate Calls

-(void)_didSuccessfullyExtractYouTubeURL:(NSURL *)videoURL {
    if ([self.delegate respondsToSelector:@selector(youTubePlayerViewController:didSuccessfullyExtractYouTubeURL:)]) {
        [self.delegate youTubePlayerViewController:self didSuccessfullyExtractYouTubeURL:videoURL];
    }
}

-(void)_failedExtractingYouTubeURLWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(youTubePlayerViewController:failedExtractingYouTubeURLWithError:)]) {
        [self.delegate youTubePlayerViewController:self failedExtractingYouTubeURLWithError:error];
    }
}

#pragma mark -
#pragma mark LBYouTubeExtractorDelegate

-(void)youTubeExtractor:(LBYouTubeExtractor *)extractor didSuccessfullyExtractYouTubeURL:(NSURL *)videoURL {
    [self _didSuccessfullyExtractYouTubeURL:videoURL];
    [self _loadVideoWithURL:videoURL];
}

-(void)youTubeExtractor:(LBYouTubeExtractor *)extractor failedExtractingYouTubeURLWithError:(NSError *)error {
    [self _failedExtractingYouTubeURLWithError:error];
}

-(void)youTubeExtractor:(LBYouTubeExtractor *)extractor videoStateChanged:(MPMoviePlayerController *)c {
// [self.view.videoController]
//    NSLog(@"---------->Video state changed");
    if (self.delegate){
        if ([self.delegate respondsToSelector:@selector(youTubePlayerViewController:videoStateChanged:)]){
            [self.delegate youTubePlayerViewController:self videoStateChanged:c];
        }
    }
}

-(void)youTubeExtractor:(LBYouTubeExtractor *)extractor movieFinished:(MPMoviePlayerController *)c  {
  //    NSLog(@"---------->movie finished");
    if (self.delegate){
        if ([self.delegate respondsToSelector:@selector(youTubePlayerViewController:movieFinished:)]){
            [self.delegate youTubePlayerViewController:self movieFinished:c];
        }
    }
}
#pragma mark -

@end
