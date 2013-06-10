//
//  LBYouTubePlayerController.h
//  LBYouTubeView
//
//  Created by Laurin Brandner on 29.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVPlayerLayer.h>
#import <AVFoundation/AVPlayerItem.h>

@interface LBYouTubePlayerController : UIView {
    MPMoviePlayerController* videoController;
    AVPlayer *avPlayer;
    AVPlayerLayer *avPlayerLayer;
}

@property (nonatomic, strong, readonly) MPMoviePlayerController* videoController;
@property (nonatomic, strong, readonly) AVPlayer* avPlayer;
@property (nonatomic, strong, readonly) AVPlayerLayer* avPlayerLayer;


-(void)loadYouTubeVideo:(NSURL*)URL;
-(void)loadVideo:(NSURL *)URL;

@end
